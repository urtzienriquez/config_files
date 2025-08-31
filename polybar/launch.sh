#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if [[ $m == "eDP-1" ]]; then
      MONITOR=$m polybar --reload primary &
    else
      MONITOR=$m polybar --reload secondary &
    fi
  done
else
  polybar --reload primary &
fi
