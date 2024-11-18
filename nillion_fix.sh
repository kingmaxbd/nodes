#!/bin/bash
docker stop nillion
cp -r /home/kingmaxbd/nillion* /root
docker run -d --name nillion --restart always -v /root/nillion/accuser:/var/tmp nillion/verifier:v1.0.1 verify --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com"
docker cp /root/nillion/verifier/credentials.json nillion:/var/tmp/credentials.json
docker restart nillion
