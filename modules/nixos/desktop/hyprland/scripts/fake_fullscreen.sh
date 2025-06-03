#!/usr/bin/env bash

# get monitor size and position
monitor_info=$(hyprctl activewindow -j | jq -r '.monitor')
monitor_geometry=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor_info\") | .x, .y, .width, .height")
read -r mx my mw mh <<< "$monitor_geometry"

# define gap size (e.g., 10px)
GAP=10

# calculate final window size and position
X=$((mx + GAP))
Y=$((my + GAP))
WIDTH=$((mw - 2 * GAP))
HEIGHT=$((mh - 2 * GAP))

# set the window to floating and resize/move it
hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact "$WIDTH" "$HEIGHT"
hyprctl dispatch moveactive exact "$X" "$Y"

