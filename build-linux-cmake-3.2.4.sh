#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Configurações
# ==============================
WX_VERSION="3.2.4"
OS=linux-cmake
WX_SRC_DIR="wxWidgets-${WX_VERSION}-${OS}"
WX_PREFIX_DIR="${HOME}/.local/wxwidgets/${OS}-wx-${WX_VERSION}"
WX_ZIP=wxWidgets-${WX_VERSION}.zip

# if exist path `_d' then remove.
_d=${OS}-wx-${WX_VERSION}
test -d $_d && rm -rf $_d
_d=wxWidgets-${WX_VERSION}-${OS}
test -d $_d && rm -rf $_d

# ==============================
# Extração do código-fonte
# ==============================
echo "[INFO] Extraindo ${WX_ZIP}..."
unzip ${WX_ZIP} -d ${WX_SRC_DIR}

# ==============================
# Configuração, compilação e instalação
# ==============================

CMAKE=/opt/cmake/cmake-3.19/bin/cmake

(
    cd "${WX_SRC_DIR}"

    echo "[INFO] Configurando build..."

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        ${CMAKE} -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${WX_PREFIX_DIR} \
        -DwxBUILD_SHARED=ON \
        -DwxBUILD_SAMPLES=OFF \
        -DwxBUILD_TESTS=OFF \
        -DwxBUILD_DEMOS=OFF \
        -DwxBUILD_TOOLKIT=gtk3 \
        \
        -DwxUSE_AUI=ON \
        -DwxUSE_STC=ON \
        -DwxUSE_XRC=ON \
        -DwxUSE_PROPGRID=ON \
        -DwxUSE_RIBBON=ON \
        -DwxUSE_MEDIACTRL=ON \
        -DwxUSE_WEBVIEW=ON \
        -DwxUSE_WEBVIEW_WEBKIT=ON \
        -DwxUSE_OPENGL=ON

    ${CMAKE} --build build --target install -j"$(nproc)"
    echo "[INFO] Compilando..."

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        ${CMAKE} --build build

    echo "[INFO] Instalando em ${WX_PREFIX_DIR}..."

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        ${CMAKE} --install build
)

echo "[INFO] wxWidgets ${WX_VERSION} instalado com sucesso."

exit 0
