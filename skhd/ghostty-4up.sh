#!/bin/bash
# Open 4 Ghostty windows in a 2x2 grid on the current space

open_window() {
    osascript \
        -e 'tell application "Ghostty" to new window' \
        -e 'tell application "Ghostty" to activate'
    sleep 0.3
}

open_window
open_window
open_window
open_window

# Get IDs of the 4 most recently opened Ghostty windows on current space
SPACE=$(yabai -m query --spaces --space | python3 -c "import json,sys; print(json.load(sys.stdin)['index'])")

WIN_IDS=$(yabai -m query --windows | python3 -c "
import json, sys
wins = json.load(sys.stdin)
ghostty = [w for w in wins if w['app'] == 'Ghostty' and w['space'] == $SPACE]
ghostty.sort(key=lambda w: w['id'], reverse=True)
for w in ghostty[:4]:
    print(w['id'])
")

IDS=($WIN_IDS)

# 2x2 grid: top-left, top-right, bottom-left, bottom-right
yabai -m window "${IDS[0]}" --grid 2:2:0:0:1:1
yabai -m window "${IDS[1]}" --grid 2:2:1:0:1:1
yabai -m window "${IDS[2]}" --grid 2:2:0:1:1:1
yabai -m window "${IDS[3]}" --grid 2:2:1:1:1:1
