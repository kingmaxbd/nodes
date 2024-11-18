import requests
import subprocess
import re
import time
from datetime import datetime

def get_recent_blocks(url, retries=3, delay=5):
    """Получаем последние блоки из указанного URL с повторными попытками."""
    for attempt in range(retries):
        try:
            response = requests.get(url)
            response.raise_for_status()  # Проверка на ошибки запроса
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Ошибка при получении данных: {e}")
            if attempt < retries - 1:
                print(f"Повторная попытка через {delay} секунд...")
                time.sleep(delay)  # Ждем перед следующей попыткой
            else:
                print("Не удалось получить данные после нескольких попыток.")
                return None  # Возвращаем None, если не удалось после всех попыток

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
    """Обновление конфигурации службы с новым значением комиссии."""
    config_file = '/etc/systemd/system/hemi.service'
    try:
        with open(config_file, 'r') as file:
            config_data = file.readlines()

        # Изменение строки с Environment, если найдена
        for i, line in enumerate(config_data):
            if re.search(r'Environment="POPM_STATIC_FEE=', line):
                config_data[i] = f'Environment="POPM_STATIC_FEE={new_fee}"\n'
                break

        # Записываем изменения обратно в файл
        with open(config_file, 'w') as file:
            file.writelines(config_data)

        # Перезагрузка демона и перезапуск сервиса
        subprocess.run(['sudo', 'systemctl', 'daemon-reload'], check=True)
        subprocess.run(['sudo', 'systemctl', 'restart', 'hemi.service'], check=True)

    except Exception as e:
        print(f"Ошибка при обновлении конфигурации: {e}")

def main():
    url = 'https://mempool.space/testnet/api/v1/blocks'
    blocks = get_recent_blocks(url)

    if blocks is not None:
        # Рассчитываем среднюю medianFee
        average_fee = calculate_average_fee(blocks)

        # Проверка, если average_fee равен 0 или 1, не обновляем
        if average_fee in [0, 1]:
            print(f"Не обновлено: получено недопустимое значение комиссии: {average_fee}.")
        else:
            # Обновляем службу с новым значением комиссии
            update_service_fee(average_fee)
            print(f"Установлено среднее значение комиссии для hemi: {average_fee} на {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    else:
        print("Не удалось обновить комиссию из-за ошибки.")

if __name__ == '__main__':
    main()
