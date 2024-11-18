import requests
import subprocess
import re
from datetime import datetime

def fetch_average_fee():
    """Получение средней комиссии с API."""
    try:
        response = requests.get("https://mempool.space/testnet/api/v1/fees/recommended")
        response.raise_for_status()  # Проверка на ошибки запроса
        return response.json().get('hourFee')
    except Exception as e:
        print(f"Ошибка при получении средней комиссии: {e}")
        return None

def update_service_fee(new_fee):
    """Обновление конфигурации службы с новым значением комиссии."""
    config_file = '/etc/systemd/system/hemi.service'

    try:
        with open(config_file, 'r') as file:
            config_data = file.readlines()

        # Обновление строки с новой комиссией
        for i, line in enumerate(config_data):
            if re.search(r'Environment="POPM_STATIC_FEE=', line):
                config_data[i] = f'Environment="POPM_STATIC_FEE={new_fee}"\n'
                break

        # Запись обновленных данных обратно в файл
        with open(config_file, 'w') as file:
            file.writelines(config_data)

        # Перезагрузка демона и службы
        subprocess.run(['sudo', 'systemctl', 'daemon-reload'], check=True)
        subprocess.run(['sudo', 'systemctl', 'restart', 'hemi.service'], check=True)

    except Exception as e:
        print(f"Ошибка при обновлении конфигурации: {e}")

def main():
    average_fee = fetch_average_fee()

    if average_fee is not None:
        update_service_fee(average_fee)
        print(f"Установлено среднее значение комиссии для hemi: {average_fee} на {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    else:
        print("Не удалось обновить комиссию из-за ошибки.")

if __name__ == '__main__':
    main()
