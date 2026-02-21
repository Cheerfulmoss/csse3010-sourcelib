#!/usr/bin/env bash
set -euo pipefail

INSTALLED_META=".sourcelib_installed"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (or via sudo)"
    exit 1
fi

if [ -f "$INSTALLED_META" ]; then
    mapfile -t PKGS < "$INSTALLED_META"

    if [ ${#PKGS[@]} -gt 0 ]; then
        echo "Removing packages: ${PKGS[*]}"
        apt-get remove -y "${PKGS[@]}"
    fi

    rm -f "$INSTALLED_META"
    apt-get autoremove -y
    apt-get -f install -y
else
    echo "No state file found, nothing to uninstall"
fi

if command -v gdb-multiarch >/dev/null 2>&1; then
    TARGET="$(command -v gdb-multiarch)"
    if [ -L /usr/local/bin/arm-none-eabi-gdb ] && \
       [ "$(readlink /usr/local/bin/arm-none-eabi-gdb)" = "$TARGET" ]; then
        echo "Removing gdb symlink..."
        rm -f /usr/local/bin/arm-none-eabi-gdb
    fi
fi

echo "Uninstall complete"

