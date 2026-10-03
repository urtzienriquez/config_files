#!/bin/bash
# Build the qtile Wayland session stack without root:
#   - wlroots 0.20 + the newer deps it needs (Debian trixie's are too old)
#     into ~/.local/opt/wlroots-0.20
#   - qtile with its C Wayland backend into the venv ~/.local/share/qtile-wl-$QTILE_VERSION
#     (linked to that prefix via rpath)
# start-wayland.sh launches qtile from that venv.
#
# Build deps (apt): meson ninja-build bison libinput-dev libseat-dev
#   libdisplay-info-dev libliftoff-dev hwdata libgbm-dev libegl-dev libgles-dev
#   libvulkan-dev glslang-tools liblcms2-dev libxcb-*-dev xwayland libcairo2-dev
#
# --libs-only: only (re)build the wlroots prefix, keep the qtile venv. Safe to
# run from a live Wayland session (see build()); the next login uses it.
set -euo pipefail

LIBS_ONLY=0
[ "${1:-}" = "--libs-only" ] && LIBS_ONLY=1

QTILE_VERSION=0.37.1
WLROOTS=0.20.2
WAYLAND=1.25.0            # wlroots needs >= 1.24; protocols 1.49 need the 1.25 scanner
WAYLAND_PROTOCOLS=1.49    # >= 1.47
LIBDRM=2.4.134            # >= 2.4.129
PIXMAN=0.46.4             # >= 0.46
XKBCOMMON=1.13.2          # >= 1.8

P="$HOME/.local/opt/wlroots-0.20"
V="$HOME/.local/share/qtile-wl-${QTILE_VERSION%.*}"
SRC="${SRC:-$HOME/.cache/qtile-wayland-build}"
LIB="$P/lib/x86_64-linux-gnu"

mkdir -p "$SRC" "$P"
cd "$SRC"
export PATH="$P/bin:$PATH"
export PKG_CONFIG_PATH="$LIB/pkgconfig:$P/share/pkgconfig"
export LDFLAGS="-Wl,-rpath,$LIB -L$LIB"

fetch() { [ -f "$2" ] || curl -fsSL -o "$2" "$1"; tar xf "$2"; }
build() { # dir, meson args...
    local dir=$1; shift
    rm -rf "$dir/build"
    # release: meson's default is an unoptimized debug build (-O0)
    meson setup "$dir/build" "$dir" --prefix="$P" --libdir=lib/x86_64-linux-gnu \
        --buildtype=release "$@"
    ninja -C "$dir/build"
    # Unlink the installed shared libraries first: installing copies over the
    # existing file, which would corrupt it under a running compositor that
    # has it mapped. Unlinked, the running one keeps its copy.
    meson introspect --installed "$dir/build" | python3 -c '
import json, os, sys
for path in json.load(sys.stdin).values():
    if ".so" in os.path.basename(path) and os.path.isfile(path) and not os.path.islink(path):
        os.unlink(path)'
    ninja -C "$dir/build" install
}

echo "### wayland $WAYLAND"
fetch "https://gitlab.freedesktop.org/wayland/wayland/-/archive/$WAYLAND/wayland-$WAYLAND.tar.gz" wayland.tar.gz
build "wayland-$WAYLAND" -Dtests=false -Ddocumentation=false

echo "### wayland-protocols $WAYLAND_PROTOCOLS"
fetch "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/$WAYLAND_PROTOCOLS/wayland-protocols-$WAYLAND_PROTOCOLS.tar.gz" wp.tar.gz
build "wayland-protocols-$WAYLAND_PROTOCOLS" -Dtests=false

echo "### libdrm $LIBDRM"
fetch "https://dri.freedesktop.org/libdrm/libdrm-$LIBDRM.tar.xz" libdrm.tar.xz
build "libdrm-$LIBDRM" -Dtests=false -Dman-pages=disabled -Dvalgrind=disabled -Dcairo-tests=disabled

echo "### pixman $PIXMAN"
fetch "https://cairographics.org/releases/pixman-$PIXMAN.tar.xz" pixman.tar.xz
build "pixman-$PIXMAN" -Dtests=disabled -Ddemos=disabled -Dgtk=disabled -Dlibpng=disabled

echo "### libxkbcommon $XKBCOMMON"
fetch "https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$XKBCOMMON.tar.gz" xkb.tar.gz
build "libxkbcommon-xkbcommon-$XKBCOMMON" -Denable-docs=false -Denable-tools=false \
    -Denable-x11=false -Denable-wayland=false -Denable-xkbregistry=false \
    -Dxkb-config-root=/usr/share/X11/xkb -Dx-locale-root=/usr/share/X11/locale

echo "### wlroots $WLROOTS"
fetch "https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/$WLROOTS/wlroots-$WLROOTS.tar.gz" wlroots.tar.gz
build "wlroots-$WLROOTS" --wrap-mode=nofallback -Dexamples=false -Dxwayland=enabled \
    -Dbackends=drm,libinput,x11 -Drenderers=gles2,vulkan

[ "$LIBS_ONLY" = 1 ] && { echo "### OK: libraries in $P"; exit 0; }

echo "### qtile $QTILE_VERSION -> $V"
python3 -m venv --system-site-packages "$V"
QTILE_WLROOTS_PATH="$P/include/wlroots-0.20" \
QTILE_PIXMAN_PATH="$P/include/pixman-1" \
QTILE_LIBDRM_PATH="$P/include/libdrm" \
CFLAGS="-I$P/include" \
    "$V/bin/pip" install --no-cache-dir --no-binary qtile \
    --config-settings backend=wayland "qtile==$QTILE_VERSION"

"$V/bin/python" -c "import libqtile.backend.wayland.core" && echo "### OK: $V/bin/qtile"
