#!/bin/bash

# Запускаем CAVA и записываем в FIFO
cava > /tmp/cava.fifo &

while true; do
    ffmpeg -f rawvideo -pixel_format rgb24 -video_size 800x600 -i /tmp/cava.fifo -vf "scale=1920:1080:flags=lanczos" -y /tmp/cava.png
    swww img /tmp/cava.png --transition-type none
    sleep 0.1
done

