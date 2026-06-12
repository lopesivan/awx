#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Configurações
# ==============================
WX_VERSION="3.2.4"
WX_ARCH=arm64-v8a
OS=android-${WX_ARCH}
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
echo "[INFO] Código-fonte preparado em ${WX_SRC_DIR}"

# CMake / NDK / Qt
CMAKE_BIN="/home/ivan/Android/Sdk/cmake/3.22.1/bin/cmake"
ANDROID_NDK_ROOT="/home/ivan/Android/Sdk/ndk/android-ndk-r21e"
QT_ANDROID_ROOT="/home/ivan/.config/env/qt/5.15.2/android"

ANDROID_PLATFORM="android-28"
ANDROID_ABI="${WX_ARCH}"

# ==============================
# Configuração com CMake
# ==============================
echo "[INFO] Configurando CMake para ${ANDROID_ABI}..."

(
    cd "${WX_SRC_DIR}"

    PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig \
        "${CMAKE_BIN}" \
        -S . \
        -B build \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
        -DCMAKE_INSTALL_PREFIX="${WX_PREFIX_DIR}" \
        -DANDROID_PLATFORM="${ANDROID_PLATFORM}" \
        -DANDROID_ABI="${ANDROID_ABI}" \
        -DCMAKE_FIND_ROOT_PATH="${WX_PREFIX_DIR};${QT_ANDROID_ROOT}" \
        -DCMAKE_EXE_LINKER_FLAGS="-llog -Wl,-rpath-link=${WX_PREFIX_DIR}/lib" \
        -DCMAKE_MODULE_LINKER_FLAGS="-llog -Wl,-rpath-link=${WX_PREFIX_DIR}/lib" \
        -DCMAKE_SHARED_LINKER_FLAGS="-llog -Wl,-rpath-link=${WX_PREFIX_DIR}/lib" \
        -DCMAKE_FIND_DEBUG_MODE=ON \
        -DCMAKE_C_FLAGS="" \
        -DCMAKE_CXX_FLAGS="" \
        -DwxBUILD_TOOLKIT=qt \
        -DwxUSE_SECRETSTORE=OFF \
        -DwxUSE_LIBICONV=OFF \
        -DwxUSE_INTL=ON \
        -DwxUSE_OPENGL=OFF \
        -DwxUSE_REGEX=OFF

    # -DwxBUILD_TOOLKIT=qt \
    # -DwxUSE_SECRETSTORE=OFF \
    # -DwxUSE_LIBICONV=OFF \
    # -DwxUSE_INTL=ON \
    # -DwxUSE_OPENGL=OFF \
    # -DwxUSE_REGEX=OFF \
    # -DwxBUILD_DEBUG_LEVEL=0 \
    # -DwxUSE_LOG=OFF \
    # -DwxUSE_LOGGUI=OFF \
    # -DwxUSE_LOGWINDOW=OFF \
    # -DwxUSE_LOG_DIALOG=OFF

)

# ==============================
# Compilação e instalação
# ==============================
echo "[INFO] Compilando e instalando wxWidgets (${ANDROID_ABI}) em ${WX_PREFIX_DIR}..."

(
    cd "${WX_SRC_DIR}"
    "${CMAKE_BIN}" --build build --target install/strip
)

exit 0
