#!/bin/bash
set -e

# Default variable values
APT_KEY_URL="https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg"
APT_DOWNLOAD_URL="https://us-central1-apt.pkg.dev/projects/sonaric-platform"
NODE_NAME="$1"
ENCRYPTION_PASSWORD="$2"
DEVNULL="/dev/null"

# Function to display script usage
usage() {
 echo "Usage: $0 <node-name> <encryption-password>"
 echo "Example: $0 myNode myPassword"
}

if [ -z "$NODE_NAME" ] || [ -z "$ENCRYPTION_PASSWORD" ]; then
  usage
  exit 1
fi

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser privileges." >&2
  exit 1
fi

print_message() {
  echo ""
  echo "$@"
  echo ""
}

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

echo "Detecting OS..."

lsb_dist=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
dist_version=$(lsb_release -sr)

if [ "$lsb_dist" != "ubuntu" ] || [ "$dist_version" != "22.04" ]; then
  echo "ERROR: This script only supports Ubuntu 22.04"
  exit 1
fi

do_install() {
  print_message "Installing Sonaric..."

  apt-get update -qq > $DEVNULL
  apt-get install -y apt-transport-https ca-certificates curl > $DEVNULL

  curl -fsSL "$APT_KEY_URL" | gpg --dearmor --yes -o /etc/apt/keyrings/sonaric.gpg > $DEVNULL 2>&1
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/sonaric.gpg] $APT_DOWNLOAD_URL sonaric-releases-apt main" > /etc/apt/sources.list.d/sonaric.list
  apt-get update -qq > $DEVNULL

  apt-get install -y sonaric > $DEVNULL

  print_message "Starting Sonaric..."
  systemctl start sonaricd
  systemctl enable sonaricd

  print_message "Setting node name to '$NODE_NAME'..."
  echo "y" | sonaric node-rename "$NODE_NAME"

  print_message "Saving Sonaric identity..."
  echo "y" | sonaric identity-export --password "$ENCRYPTION_PASSWORD"
  
  echo "Sonaric installation completed."
}

do_install
