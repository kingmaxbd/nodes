#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # Нет цвета (сброс цвета)

NAME=$1
PRIVATE_KEY=0x$2


# Загрузка Docker образа
docker pull --platform linux/amd64 gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.0.0

# Создание директории для базы данных
mkdir -p /root/hyperlane_db_base && chmod -R 777 /root/hyperlane_db_base

# Запуск Docker контейнера
docker run -d -it \
    --name hyperlane \
    --mount type=bind,source=/root/hyperlane_db_base,target=/hyperlane_db_base \
    gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.0.0 \
    ./validator \
    --db /hyperlane_db_base \
    --originChainName base \
    --reorgPeriod 1 \
    --validator.id "$NAME" \
    --checkpointSyncer.type localStorage \
    --checkpointSyncer.folder base  \
    --checkpointSyncer.path /hyperlane_db_base/base_checkpoints \
    --validator.key "$PRIVATE_KEY" \
    --chains.base.signer.key "$PRIVATE_KEY" \
    --chains.base.customRpcUrls https://base.llamarpc.com

# Заключительное сообщение
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Команда для проверки логов:${NC}"
echo "docker logs --tail 100 -f hyperlane"
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
