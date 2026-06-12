#!/bin/sh

set -xe

# ==============================
# Configurações
# ==============================
WX_VERSION="3.3.1"
OS=windows
WX_SRC_DIR="wxWidgets-${WX_VERSION}-${OS}"
WX_PREFIX_DIR="${HOME}/.local/wxwidgets/${OS}-wx-${WX_VERSION}"
WX_TAR_BZ2=wxWidgets-${WX_VERSION}.tar.bz2

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
echo "[INFO] Extraindo ${WX_TAR_BZ2}..."
mkdir ${WX_SRC_DIR}
tar xvjf ${WX_TAR_BZ2} -C ${WX_SRC_DIR} --strip-components=1

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

exit 0
