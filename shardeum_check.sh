#! /bin/bash

function get_status() {
    STATUS=$(docker exec -it shardeum-validator operator-cli status | grep state | awk '{ print $2 }')
    echo "${STATUS}"
}

cd "$HOME" || exit
source .profile

while true
do
    printf "Check shardeum node status \n"
    NODE_STATUS=$(get_status)
    printf "Current status: ${NODE_STATUS}\n"
    sleep 5s
    if [[ "${NODE_STATUS}" =~ "stopped" ]]; then
        printf "Start shardeum node and wait 5 minutes\n"
        docker exec -it shardeum-validator operator-cli start
        sleep 5m
    else
        date=$(date +"%H:%M")
        echo "Last Update: ${date}"
        printf "Sleep 15 minutes\n"
        sleep 15m
    fi
done
