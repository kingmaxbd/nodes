import requests
import json
import subprocess
from datetime import datetime

def get_recent_blocks(url):
    """Получаем последние блоки из указанного URL."""
    response = requests.get(url)
    response.raise_for_status()  # Проверка на ошибки запроса
    return response.json()

def calculate_average_fee(blocks):
    """Рассчитываем среднюю medianFee."""
    total_median_fee = 0
    block_count = 0

    for block in blocks:
        median_fee = block.get('extras', {}).get('medianFee')
        if median_fee is not None:
            total_median_fee += median_fee
            block_count += 1
        else:
            print(f"medianFee для блока {block.get('id')} не найдена или равна null")

    if block_count > 0:
        average_median_fee = total_median_fee / block_count
    else:
        average_median_fee = 0

    return round(average_median_fee)  # Округление результата до целого числа

def update_service_fee(new_fee):
    """Обновляем конфигурацию службы с новым значением комиссии."""
    config_file = '/etc/systemd/system/hemi.service'
    try:
        with open(config_file, 'r') as file:
            config_data = file.readlines()
        
        # Изменяем строку с Environment, если она найдена
        for i, line in enumerate(config_data):
            if 'Environment="POPM_STATIC_FEE=' in line:
                config_data[i] = f'Environment="POPM_STATIC_FEE={new_fee}"\n'
                break

        # Записываем изменения обратно в файл
        with open(config_file, 'w') as file:
            file.writelines(config_data)

        # Перезагрузка демон systemd и перезапуск сервис
        subprocess.run(['sudo', 'systemctl', 'daemon-reload'], check=True)
        subprocess.run(['sudo', 'systemctl', 'restart', 'hemi.service'], check=True)

    except Exception as e:
        print(f"Ошибка при обновлении конфигурации: {e}")

def main():
    url = 'https://mempool.space/testnet/api/v1/blocks'
    try:
        blocks = get_recent_blocks(url)

        # Рассчитываем среднюю medianFee
        average_fee = calculate_average_fee(blocks)

        # Обновляем службу с новым значением комиссии
        update_service_fee(average_fee)

        # Выводим результаты
        print(f"Установлено среднее значение комиссии для hemi: {average_fee} на {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    except Exception as e:
        print(f"Произошла ошибка: {e}")

if __name__ == '__main__':
    main()
