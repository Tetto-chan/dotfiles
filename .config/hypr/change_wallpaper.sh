#!/bin/bash

# Директория с обоями
WALLPAPER_DIR="/path/to/your/wallpapers"

# Выберите случайный файл из директории
FILE=$(ls $WALLPAPER_DIR | shuf -n 1)

# Установите обои
feh --bg-scale "$WALLPAPER_DIR/$FILE"

