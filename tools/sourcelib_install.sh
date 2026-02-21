#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

MANIFEST_FILE="sourcelib_packages"
INSTALLED_META=".sourcelib_installed"
MISSING=()

if [ ! -f "$MANIFEST_FILE" ]; then
    echo "Sourcelib manifest missing: $MANIFEST_FILE"
    exit 1
fi

mapfile -t PACKAGES < "$MANIFEST_FILE"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (or via sudo)"
    exit 1
fi

apt-get update

# Fix up any broken package dependencies and then install apt-utils to shut
#     any complaining packages
apt-get -f install -y
apt-get install apt-utils

for pkg in "${PACKAGES[@]}"; do
    dpkg -s "$pkg" &>/dev/null || MISSING+=("$pkg")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing missing packages: ${MISSING[*]}"
    apt-get install -y "${MISSING[@]}"
else
    echo "All required packages already installed"
fi

# Create gdb symlink if needed
if command -v gdb-multiarch >/dev/null 2>&1; then
    ln -sf "$(command -v gdb-multiarch)" /usr/local/bin/arm-none-eabi-gdb
fi

# Check for JLink instead of installing it
if ! command -v JLinkExe >/dev/null 2>&1; then
    echo "Warning: JLinkExe not found in PATH."
    echo "Mount or install SEGGER JLink manually."
fi

printf "%s\n" "${MISSING[@]}" >> "$INSTALLED_META"
sort -u "$INSTALLED_META" -o "$INSTALLED_META"

echo "sourcelib install complete."
