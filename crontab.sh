#!/bin/bash


# логи 
# tail -n 50 /root/scripts/hemi_min_free_2h.log
# bash <(curl -s https://raw.githubusercontent.com/RomanTsibii/nodes/main/hemi/crontab.sh)
# видалити кронтаб
crontab -l | grep -v '/root/scripts/hemi_min_free_2h.log' | crontab -

# Створюємо папку scripts, якщо її не існує
mkdir -p /root/scripts

# Скачуємо файл і перейменовуємо його

curl -o /root/scripts/hemi_min_free_2h.py https://raw.githubusercontent.com/kingmaxbd/nodes/refs/heads/main/avarage_fee.py
# Надаємо права на виконання файлу
chmod +x /root/scripts/hemi_min_free_2h.py

# Додаємо завдання в crontab для запуску кожні 2 години на випадковій хвилині
# Випадкове число від 0 до 59 для хвилин
minute=$((RANDOM % 60))

# Записуємо завдання в crontab
(crontab -l 2>/dev/null; echo "$minute */2 * * * python3 /root/scripts/hemi_min_free_2h.py >> /root/scripts/hemi_min_free_2h.log 2>&1") | crontab -
python3 /root/scripts/hemi_min_free_2h.py >> /root/scripts/hemi_min_free_2h.log
