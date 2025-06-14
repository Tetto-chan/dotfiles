#!/bin/bash

# Функция для получения номера обоев из файла
get_number() {
  if [[ -f "file.txt" ]]; then
    # Чтение содержимого файла и удаление лишних символов
    wp_num=$(tr -d '\0' < file.txt | tr -d '[:space:]')
    
    # Проверка, что содержимое - это число
    if ! [[ "$wp_num" =~ ^[0-9]+$ ]]; then
      wp_num=1  # Если в файле не число, сбрасываем на 1
    fi
  else
    wp_num=1  # Если файла нет, начинаем с 1
  fi
}

# Основная логика скрипта
get_number

# Если номер обоев больше 16, сбрасываем его на 1
if (( wp_num > 43 )); then
  wp_num=1
fi

# Вывод команды для смены обоев
swww img ~/.config/hypr/wallpapers/wall${wp_num}.jpg --transition-type random --transition-fps 255

# Увеличиваем номер обоев на 1
((wp_num++))

# Записываем новый номер в файл
echo $wp_num > file.txt

