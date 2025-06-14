#!/bin/bash

# Опции для панели с иконками
options=" Выключение\n Перезагрузка\n Выход из сессии\n Блокировка\n Спящий режим"

# Показываем панель Wofi
selection=$(echo -e "$options" | wofi --dmenu --prompt "Действие:" --style "/home/tetto/.config/wofi/style.css")

# Удаляем иконку из выбора
selection=$(echo "$selection" | sed 's/^[^ ]* //')

# Обрабатываем выбор пользователя
case "$selection" in
    "Выключение")
        systemctl poweroff
        ;;
    "Перезагрузка")
        systemctl reboot
        ;;
    "Выход из сессии")
        hyprctl dispatch exit
        ;;
    "Блокировка")
        i3lock
        ;;
    "Спящий режим")
        systemctl suspend
        ;;
    *)
        exit 0
        ;;
esac

