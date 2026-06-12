#!/bin/sh

set -xe

# ==============================
# Configurações
# ==============================
WX_VERSION="3.2.4"
OS=windows
WX_SRC_DIR="wxWidgets-${WX_VERSION}-${OS}"
WX_PREFIX_DIR="${HOME}/.local/wxwidgets/${OS}-wx-${WX_VERSION}"
WX_ZIP=wxWidgets-${WX_VERSION}.zip

# echo : ${WX_SRC_DIR} : wxWidgets-3.3.1-windows
# echo : $WX_PREFIX_DIR : /home/ivan/.local/wxwidgets/windows-wx-3.3.1
# ext 0

# if exist path `_d' then remove.
_d=${OS}-wx-${WX_VERSION}
test -d $_d && rm -rf $_d
_d=wxWidgets-${WX_VERSION}-$OS
test -d $_d && rm -rf $_d

# ==============================
# Extração do código-fonte
# ==============================
echo "[INFO] Extraindo ${WX_ZIP}..."
unzip ${WX_ZIP} -d ${WX_SRC_DIR}

# FIX:
#   $ cp /usr/x86_64-w64-mingw32/include/uxtheme.h{,.SAVED}
#   $ diff /usr/x86_64-w64-mingw32/include/uxtheme.h{,.SAVED}
#   196c196
#   <     WTA_NONCLIENT = 1
#   ---
#   >     WTA_NONCLIENT = 1
#   356c356
#   < THEMEAPI GetThemeSysFont(HTHEME hTheme,int iFontId,LOGFONTW *plf);
#   ---
#   > THEMEAPI GetThemeSysFont(HTHEME hTheme,int iFontId,LOGFONT *plf);
#   ^

(
    cd "${WX_SRC_DIR}"

    echo "[INFO] Configurando build..."

    PKG_CONFIG_PATH= \
        PKG_CONFIG_LIBDIR= \
        ./configure \
        --prefix="${WX_PREFIX_DIR}" \
        --host=x86_64-w64-mingw32 \
        --build=x86_64-linux-gnu \
        --disable-shared \
        --enable-unicode \
        CFLAGS="-m64" \
        CXXFLAGS="-m64" \
        LDFLAGS="-m64"

    echo "[INFO] Compilando..."
    PKG_CONFIG_PATH= \
        PKG_CONFIG_LIBDIR= \
        make -j"$(nproc)"

    echo "[INFO] Instalando em ${WX_PREFIX_DIR}..."
    make install
)

mv ${WX_SRC_DIR} /home/ivan/.local/wxwidgets
cp build-windows-3.2.4.sh /home/ivan/.local/wxwidgets

exit 0
