#!/bin/bash

# Захватите комбинацию клавиш
while true; do
    xdotool key --delay 200 --clearmodifiers "ctrl+alt+w"
    if [ $? -eq 0 ]; then
        /path/to/change_wallpaper.sh
    fi
    sleep 0.2
done

