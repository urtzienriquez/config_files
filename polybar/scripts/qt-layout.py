#!/bin/python3
from libqtile.command.client import InteractiveCommandClient
from libqtile.lazy import lazy

c = InteractiveCommandClient()

try:
    print(c.layout.info().get("name"))
except:
    print("")
