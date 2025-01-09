#!/bin/bash

# Обновление системы и установка зависимостей
sudo apt update -y
sudo apt install xfce4 xfce4-goodies libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libsecret-1-0 -y
sudo apt install tigervnc-standalone-server tigervnc-common -y

# Создание файла .zshrc
cat <<EOF > ~/.zshrc
# Основной файл конфигурации Zsh
export ZSH_THEME="robbyrussell"
export PATH=\$PATH:/usr/local/bin
alias ll="ls -la"
EOF

# Настройка VNC
sudo mkdir -p /root/.vnc && sudo bash -c 'cat <<EOF > /root/.vnc/xstartup
xrdb "$HOME/.Xresources"
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x /root/.vnc/xstartup'

# Установка пароля VNC
vncpasswd <<EOF
htm_zqc5EPV*qwk9abz
htm_zqc5EPV*qwk9abz
EOF

# Запуск VNC сервера
vncserver -kill :1 2>/dev/null || true
vncserver :1 -localhost no -geometry 1920x1080 -depth 24

# Скачивание и установка OpenLedger Node
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
unzip -o openledger-node-1.0.0-linux.zip
sudo dpkg -i openledger-node-1.0.0.deb
