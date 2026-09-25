#!/usr/bin/env bash
# ==============================================================================
# Script de compilación de pico-fido2 para RP2350 emulando Nitrokey 3
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PICO_SDK_PATH="${PICO_SDK_PATH:-${SCRIPT_DIR}/../pico-sdk}"

if [ ! -d "${PICO_SDK_PATH}" ]; then
    echo "Error: No se encuentra pico-sdk en ${PICO_SDK_PATH}" >&2
    echo "Ejecuta primero ./install_dependencies_arch.sh" >&2
    exit 1
fi

BUILD_DIR="${SCRIPT_DIR}/build_rp2350_nitro3"
RELEASE_DIR="${SCRIPT_DIR}/release"

echo "==> Configurando compilación con CMake..."
echo "    - Placa: RP2350 (pico2)"
echo "    - Emulación: Nitrokey 3 (VID: 0x20A0, PID: 0x42B2)"
echo "    - Criptografía: EdDSA (Ed25519) + SHA256 hardware RP2350"

mkdir -p "${BUILD_DIR}"
mkdir -p "${RELEASE_DIR}"

cmake -B "${BUILD_DIR}" -S "${SCRIPT_DIR}" \
    -DPICO_BOARD=pico2 \
    -DVIDPID=Nitro3 \
    -DENABLE_EDDSA=1

echo "==> Compilando..."
cmake --build "${BUILD_DIR}" -j"$(nproc)"

echo "==> Copiando binarios a ${RELEASE_DIR}..."
cp "${BUILD_DIR}/pico_fido2.uf2" "${RELEASE_DIR}/pico_fido2_rp2350_nitro3.uf2"
cp "${BUILD_DIR}/pico_fido2.elf" "${RELEASE_DIR}/pico_fido2_rp2350_nitro3.elf"

echo ""
echo "=============================================================================="
echo " Compilación completada con éxito."
echo " Binario UF2 listo para flashear:"
echo "   $(realpath "${RELEASE_DIR}/pico_fido2_rp2350_nitro3.uf2")"
echo "=============================================================================="
