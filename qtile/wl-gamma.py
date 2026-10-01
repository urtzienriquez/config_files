#!/usr/bin/env python3
"""Per-output gamma for the qtile Wayland session.

Wayland equivalent of the `gamma` lines in the autorandr profiles: applies
the same ramp `xrandr --gamma R:G:B` would, via wlr-gamma-control. It must
keep running (the compositor resets gamma when the client disconnects) and it
re-applies the ramp when a monitor is plugged in again.
"""

import os
import subprocess
import sys
from pathlib import Path

# output name -> xrandr --gamma values (from ~/.config/autorandr/dual/config)
GAMMA = {
    "HDMI-A-1": (0.769, 0.909, 0.909),
}

HERE = Path(__file__).resolve().parent
XMLS = ["/usr/share/wayland/wayland.xml", HERE / "wayland/wlr-gamma-control-unstable-v1.xml"]
GEN = Path.home() / ".cache/qtile/wlproto"


def load_protocols():
    pkg = GEN / "protos"
    if not (pkg / "wlr_gamma_control_unstable_v1").exists():
        pkg.mkdir(parents=True, exist_ok=True)
        (pkg / "__init__.py").touch()
        subprocess.run(
            [sys.executable, "-m", "pywayland.scanner", "-o", str(pkg), "-i", *map(str, XMLS)],
            check=True,
            capture_output=True,
        )
    sys.path.insert(0, str(GEN))


load_protocols()
from pywayland.client import Display  # noqa: E402
from protos.wayland import WlOutput  # noqa: E402
from protos.wlr_gamma_control_unstable_v1 import ZwlrGammaControlManagerV1  # noqa: E402


def ramp_fd(size, gamma):
    """Same formula as xrandr: value = (i / (size-1)) ** (1 / gamma)."""
    data = bytearray()
    for g in gamma:
        exp = 1.0 / g
        for i in range(size):
            v = round(((i / (size - 1)) ** exp) * 65535)
            data += v.to_bytes(2, sys.byteorder)
    fd = os.memfd_create("gamma-ramp")
    os.write(fd, data)
    os.lseek(fd, 0, os.SEEK_SET)
    return fd


class GammaDaemon:
    def __init__(self):
        self.display = Display()
        self.display.connect()
        self.manager = None
        self.outputs = {}  # registry id -> {"output", "name", "control"}
        registry = self.display.get_registry()
        registry.dispatcher["global"] = self.on_global
        registry.dispatcher["global_remove"] = self.on_global_remove
        self.display.roundtrip()  # globals
        self.display.roundtrip()  # output names
        for info in self.outputs.values():
            self.apply(info)

    def on_global(self, registry, gid, interface, version):
        if interface == "zwlr_gamma_control_manager_v1":
            self.manager = registry.bind(gid, ZwlrGammaControlManagerV1, 1)
        elif interface == "wl_output":
            output = registry.bind(gid, WlOutput, min(version, 4))
            info = {"output": output, "name": None, "control": None}
            self.outputs[gid] = info
            output.dispatcher["name"] = lambda _o, name: info.update(name=name)
            output.dispatcher["done"] = lambda _o: self.apply(info)

    def on_global_remove(self, registry, gid):
        info = self.outputs.pop(gid, None)
        if info and info["control"]:
            info["control"].destroy()

    def apply(self, info):
        if not self.manager or info["control"] or info["name"] not in GAMMA:
            return
        gamma = GAMMA[info["name"]]
        control = self.manager.get_gamma_control(info["output"])
        info["control"] = control

        def on_size(_c, size):
            fd = ramp_fd(size, gamma)
            control.set_gamma(fd)
            os.close(fd)
            print(f"wl-gamma: {info['name']} gamma {gamma} ({size} steps)", flush=True)

        def on_failed(_c):
            print(f"wl-gamma: gamma control failed for {info['name']}", flush=True)
            control.destroy()
            info["control"] = None

        control.dispatcher["gamma_size"] = on_size
        control.dispatcher["failed"] = on_failed

    def run(self):
        while self.display.dispatch(block=True) != -1:
            pass


if __name__ == "__main__":
    GammaDaemon().run()
