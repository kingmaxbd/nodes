#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # Сброс цвета

# Проверка наличия аргументов для EVM кошелька и имени ноды
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Ошибка: не указаны EVM кошелёк или имя ноды.${NC}"
    echo -e "${YELLOW}Использование: $0 <EVM_WALLET_ADDRESS> <NODE_NAME>${NC}"
    exit 1
fi

WALLET=$1
NODE_NAME=$2

# Установка зависимостей
echo -e "${BLUE}Установка зависимостей...${NC}"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y wget

# Создание папки и скачивание бинарника
echo -e "${BLUE}Скачивание бинарника InitVerse...${NC}"
mkdir -p $HOME/initverse
cd $HOME/initverse
wget https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64
chmod +x iniminer-linux-x64
cd

# Создание файла .env
echo -e "${BLUE}Создание конфигурационного файла...${NC}"
echo "WALLET=$WALLET" > "$HOME/initverse/.env"
echo "NODE_NAME=$NODE_NAME" >> "$HOME/initverse/.env"

# Определение имени пользователя и домашней директории
USERNAME=$(whoami)
HOME_DIR=$(eval echo ~$USERNAME)

# Создание сервиса
echo -e "${BLUE}Настройка сервиса InitVerse...${NC}"
sudo bash -c "cat <<EOT > /etc/systemd/system/initverse.service
[Unit]
Description=InitVerse Miner Service
After=network.target

[Service]
User=$USERNAME
WorkingDirectory=$HOME_DIR/initverse
EnvironmentFile=$HOME_DIR/initverse/.env
ExecStart=/bin/bash -c 'source $HOME_DIR/initverse/.env && $HOME_DIR/initverse/iniminer-linux-x64 --pool stratum+tcp://${WALLET}.${NODE_NAME}@pool-a.yatespool.com:31588 --cpu-devices 1 --cpu-devices 2'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

# Запуск сервиса
echo -e "${BLUE}Запуск сервиса InitVerse...${NC}"
sudo systemctl daemon-reload
sudo systemctl restart systemd-journald
sudo systemctl enable initverse
sudo systemctl start initverse

# Заключительное сообщение
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Команда для проверки логов:${NC}"
echo "sudo journalctl -fu initverse.service"
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
echo -e "${GREEN}InitVerse нода успешно установлена и запущена!${NC}"
