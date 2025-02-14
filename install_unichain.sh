#!/bin/bash

function colors {
  GREEN="\e[32m"
  YELLOW="\e[33m"
  RED="\e[39m"
  NORMAL="\e[0m"
}


function install_docker {
    if ! type "docker" > /dev/null; then
        echo -e "${YELLOW}Устанавливаем докер${NORMAL}"
        bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh)
    else
        echo -e "${YELLOW}Докер уже установлен. Переходим на следующий шаг${NORMAL}"
    fi
}


sudo apt update # && sudo apt upgrade -y

install_docker
docker --version
cd /root
git clone https://github.com/Uniswap/unichain-node
cd /root/unichain-node
sed -i '/^OP_NODE_L1_ETH_RPC/c\OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com' .env.sepolia
sed -i '/^OP_NODE_L1_BEACON/c\OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com' .env.sepolia

sed -i 's/      start_interval: 5s/      interval: 5s/g' docker-compose.yml
sed -i 's/      - 8545:8545\/tcp/      - 8547:8545\/tcp/g' docker-compose.yml
sed -i 's/      - 8546:8546\/tcp/      - 8548:8546\/tcp/g' docker-compose.yml

docker-compose up -d
echo "You Private Key"
echo $(cat /root/unichain-node/geth-data/geth/nodekey)
