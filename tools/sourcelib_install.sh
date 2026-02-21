#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (or via sudo)"
    exit 1
fi

apt-get update

install_if_missing() {
    dpkg -s "$1" >/dev/null 2>&1 || apt-get install -y "$1"
}
install_if_missing apt-utils

apt-get update

install_if_missing gcc-arm-none-eabi
install_if_missing gdb-arm-none-eabi
install_if_missing libnewlib-arm-none-eabi
install_if_missing gdb-multiarch
install_if_missing python3-venv

# Create gdb symlink if needed
if [ -f /usr/bin/gdb-multiarch ] && [ ! -f /usr/local/bin/arm-none-eabi-gdb ]; then
    ln -s /usr/bin/gdb-multiarch /usr/local/bin/arm-none-eabi-gdb
fi

# Check for JLink instead of installing it
if ! command -v JLinkExe >/dev/null 2>&1; then
    echo "Warning: JLinkExe not found in PATH."
    echo "Mount or install SEGGER JLink manually."
fi

echo "sourcelib install complete."
