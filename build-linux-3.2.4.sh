#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Configurações
# ==============================
WX_VERSION="3.2.4"
OS=linux
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

# -----------------------------
# Blocos comuns / componíveis
# -----------------------------
COMMON_CORE=(
    --with-cxx=17
    --disable-monolithic
    --disable-universal
    --disable-mediactrl
    --enable-aui
    --enable-exceptions
    --enable-gui
    --enable-html
    --enable-richtext
    --enable-unicode
    --enable-xrc
    --with-regex=sys
    --with-opengl
)
# --without-odbc

GTK2_BASE=(--with-gtk=2)
GTK3_BASE=(--with-gtk=3)

DEBUG_BASE=(--enable-debug)
RELEASE_BASE=(--disable-debug)

STATIC_BASE=(--disable-shared)
SHARED_BASE=(--enable-shared)

# -----------------------------------------
# Presets recriados por composição (iguais)
# -----------------------------------------
# Debug
GCCBuildDebugGTK3Unicode=(
    "${GTK3_BASE[@]}"
    "${DEBUG_BASE[@]}"
    "${STATIC_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildDebugSharedGTK3Unicode=(
    "${GTK3_BASE[@]}"
    "${DEBUG_BASE[@]}"
    "${SHARED_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildDebugGTK2Unicode=(
    "${GTK2_BASE[@]}"
    "${DEBUG_BASE[@]}"
    "${STATIC_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildDebugSharedGTK2Unicode=(
    "${GTK2_BASE[@]}"
    "${DEBUG_BASE[@]}"
    "${SHARED_BASE[@]}"
    "${COMMON_CORE[@]}"
)

# Release
GCCBuildReleaseGTK3Unicode=(
    "${GTK3_BASE[@]}"
    "${RELEASE_BASE[@]}"
    "${STATIC_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildReleaseSharedGTK3Unicode=(
    "${GTK3_BASE[@]}"
    "${RELEASE_BASE[@]}"
    "${SHARED_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildReleaseGTK2Unicode=(
    "${GTK2_BASE[@]}"
    "${RELEASE_BASE[@]}"
    "${STATIC_BASE[@]}"
    "${COMMON_CORE[@]}"
)

GCCBuildReleaseSharedGTK2Unicode=(
    "${GTK2_BASE[@]}"
    "${RELEASE_BASE[@]}"
    "${SHARED_BASE[@]}"
    "${COMMON_CORE[@]}"
)

# ======== ESCOLHA EXATAMENTE UMA LINHA A SEGUIR ========
# GCC_OPT=("${GCCBuildDebugGTK3Unicode[@]}")
# GCC_OPT=("${GCCBuildDebugSharedGTK3Unicode[@]}")
# GCC_OPT=("${GCCBuildDebugGTK2Unicode[@]}")
# GCC_OPT=("${GCCBuildDebugSharedGTK2Unicode[@]}")
# GCC_OPT=("${GCCBuildReleaseGTK3Unicode[@]}")
GCC_OPT=("${GCCBuildReleaseSharedGTK3Unicode[@]}")
# GCC_OPT=("${GCCBuildReleaseGTK2Unicode[@]}")
# GCC_OPT=("${GCCBuildReleaseSharedGTK2Unicode[@]}")
# ======== FIM DA ESCOLHA ========

(
    cd "${WX_SRC_DIR}"

    echo "[INFO] Configurando build..."

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        ./configure \
        --prefix="${WX_PREFIX_DIR}" \
        ${GCC_OPT[*]}

    echo "[INFO] Compilando..."

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        make -j"$(nproc)"

    echo "[INFO] Instalando em ${WX_PREFIX_DIR}..."
    make install
)

# ==============================
# Opções extras possíveis:
#   --with-x11
#   --with-expat
#   --with-libcurl
#   --with-x
# ==============================

echo "[INFO] wxWidgets ${WX_VERSION} instalado com sucesso."

# git clone https://github.com/vslavik/bakefile
# cd bakefile/
# git checkout origin/legacy-0.2-branch
# git switch -c legacy-0.2-branch
# pyenv local 2.7.18
# sed '14d' -i Makefile.am
# sed '35d' -i configure.in

# ./bootstrap  #<------------------- RODE no modo WITHOUTBREW

# ./configure --prefix=/home/ivan/wx/linux-wx-3.2.4
# make
# make install
