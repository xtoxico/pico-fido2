#!/usr/bin/env bash
# ==============================================================================
# Script de instalación de dependencias para pico-fido2 en Arch Linux
# ==============================================================================
set -euo pipefail

echo "==> Comprobando privilegios..."
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "Error: Se requieren privilegios de superusuario y 'sudo' no está disponible." >&2
        exit 1
    fi
fi

echo "==> Actualizando bases de datos de pacman..."
$SUDO pacman -Sy --noconfirm

echo "==> Instalando dependencias del sistema y toolchain ARM embedded..."
$SUDO pacman -S --needed --noconfirm \
    base-devel \
    git \
    cmake \
    ninja \
    make \
    python \
    pkgconf \
    libusb \
    jsoncpp \
    arm-none-eabi-gcc \
    arm-none-eabi-newlib \
    arm-none-eabi-binutils

# Directorio de trabajo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PICO_SDK_DIR="${SCRIPT_DIR}/../pico-sdk"

echo "==> Verificando Raspberry Pi Pico SDK..."
if [ ! -d "${PICO_SDK_DIR}" ]; then
    echo "Clonando Raspberry Pi Pico SDK (v2.1.1)..."
    git clone --depth 1 --branch 2.1.1 https://github.com/raspberrypi/pico-sdk.git "${PICO_SDK_DIR}"
fi

echo "==> Inicializando submódulos de pico-sdk (TinyUSB, etc.)..."
git -C "${PICO_SDK_DIR}" submodule update --init

echo "==> Verificando submódulos de pico-fido2..."
if [ -f "${SCRIPT_DIR}/.gitmodules" ]; then
    git -C "${SCRIPT_DIR}" submodule update --init --recursive
fi

echo ""
echo "=============================================================================="
echo " Dependencias instaladas con éxito."
echo " SDK ubicado en: $(realpath "${PICO_SDK_DIR}")"
echo " Toolchain: $(arm-none-eabi-gcc --version | head -n 1)"
echo "=============================================================================="
