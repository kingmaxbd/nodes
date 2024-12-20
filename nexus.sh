#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null


NEXUS_HOME=$HOME/.nexus

git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ $GIT_IS_AVAILABLE != 0 ]; then
  echo Unable to find git. Please install it and try again.
  exit 1;
fi

PROVER_ID=fbYhDtPvfKVU6by3WMw6EMsBiCl1

REPO_PATH=$NEXUS_HOME/network-api
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating.";
  (cd $REPO_PATH && git stash save && git fetch --tags)
else
  mkdir -p $NEXUS_HOME
  (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi
(cd $REPO_PATH && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1))

cat <<EOF | sudo tee /etc/systemd/system/nexus.service >/dev/null
[Unit]
Description=Nexus prover
After=network-online.target
StartLimitIntervalSec=0

[Service]
User=root
Restart=always
RestartSec=30
LimitNOFILE=65535
Type=simple
WorkingDirectory=$REPO_PATH/clients/cli
ExecStart=cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
