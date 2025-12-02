#!/bin/bash
# Script para empacotar compilações do wxWidgets com suas dependências

set -e

OUTPUT_DIR="wxwidgets-packages"
MANIFEST_FILE="$OUTPUT_DIR/manifest.json"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Preparando pacotes do wxWidgets ===${NC}"

# Cria diretório de saída
mkdir -p "$OUTPUT_DIR"

# Array para armazenar informações dos pacotes
declare -a packages

# Função para verificar se arquivos/diretórios existem
check_exists() {
    local item=$1
    if [ ! -e "$item" ]; then
        echo -e "${RED}ERRO: $item não encontrado!${NC}"
        return 1
    fi
    return 0
}

# Função para empacotar uma compilação completa
# Argumentos: script instalacao fonte archive_name
package_build() {
    local script=$1
    local install_dir=$2
    local source_dir=$3
    local archive_name=$4

    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Empacotando: $archive_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Verifica existência dos componentes
    local all_exist=true

    if ! check_exists "$script"; then
        echo -e "  ${RED}✗${NC} Script: $script"
        all_exist=false
    else
        echo -e "  ${GREEN}✓${NC} Script: $script"
    fi

    if ! check_exists "$install_dir"; then
        echo -e "  ${RED}✗${NC} Instalação: $install_dir"
        all_exist=false
    else
        echo -e "  ${GREEN}✓${NC} Instalação: $install_dir"
    fi

    if ! check_exists "$source_dir"; then
        echo -e "  ${RED}✗${NC} Fonte: $source_dir"
        all_exist=false
    else
        echo -e "  ${GREEN}✓${NC} Fonte: $source_dir"
    fi

    if [ "$all_exist" = false ]; then
        echo -e "${RED}Pulando $archive_name devido a componentes faltando${NC}"
        return 1
    fi

    # Verifica links quebrados na instalação
    echo -e "${BLUE}Verificando links simbólicos...${NC}"
    local broken_count=$(find "$install_dir" -xtype l 2>/dev/null | wc -l)

    if [ $broken_count -gt 0 ]; then
        echo -e "  ${YELLOW}⚠${NC}  Encontrados $broken_count link(s) quebrado(s)"
        echo -e "  ${BLUE}ℹ${NC}  Os arquivos fonte resolverão estes links"
    else
        echo -e "  ${GREEN}✓${NC} Nenhum link quebrado"
    fi

    # Cria o arquivo tar.gz
    echo -e "${BLUE}Criando arquivo...${NC}"
    tar -czf "$OUTPUT_DIR/$archive_name" \
        --transform "s|^|wxwidgets-package/|" \
        "$script" "$install_dir" "$source_dir"

    # Obtém informações do pacote
    local size=$(du -h "$OUTPUT_DIR/$archive_name" | cut -f1)
    local hash=$(sha256sum "$OUTPUT_DIR/$archive_name" | cut -d' ' -f1)

    echo -e "  ${GREEN}✓${NC} Tamanho: $size"
    echo -e "  ${GREEN}✓${NC} SHA256: ${hash:0:16}..."

    # Adiciona ao array de pacotes
    packages+=("$archive_name:$size:$hash:$script:$install_dir:$source_dir")

    return 0
}

echo ""
echo -e "${BLUE}Iniciando empacotamento...${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Linux 3.2.4
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-linux-3.2.4.sh" \
    "linux-wx-3.2.4" \
    "wxWidgets-3.2.4-linux" \
    "linux-wx-3.2.4.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Linux 3.3.1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-linux-3.3.1.sh" \
    "linux-wx-3.3.1" \
    "wxWidgets-3.3.1-linux" \
    "linux-wx-3.3.1.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Linux CMake 3.2.4
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-linux-cmake-3.2.4.sh" \
    "linux-cmake-wx-3.2.4" \
    "wxWidgets-3.2.4-linux-cmake" \
    "linux-cmake-wx-3.2.4.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Android 3.2.4 (Release)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-android-3.2.4.sh" \
    "android-wx-3.2.4-RELEASE" \
    "wxWidgets-3.2.4-android" \
    "android-wx-3.2.4-RELEASE.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Android 3.2.4 (Debug)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-android-3.2.4-debug.sh" \
    "android-wx-3.2.4-DEBUG" \
    "wxWidgets-3.2.4-android-debug" \
    "android-wx-3.2.4-DEBUG.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Android 3.3.1 (Release)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-android-3.3.1.sh" \
    "android-wx-3.3.1" \
    "wxWidgets-3.3.1-android" \
    "android-wx-3.3.1-RELEASE.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Android 3.3.1 (Debug)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
package_build \
    "build-android-3.3.1-debug.sh" \
    "android-debug-wx-3.3.1" \
    "wxWidgets-3.3.1-android-debug" \
    "android-wx-3.3.1-DEBUG.tar.gz"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Gera arquivo manifest.json
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ ${#packages[@]} -eq 0 ]; then
    echo ""
    echo -e "${RED}ERRO: Nenhum pacote foi criado com sucesso!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Gerando manifest.json...${NC}"

cat >"$MANIFEST_FILE" <<EOF
{
  "version": "1.0",
  "generated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "packages": [
EOF

first=true
for pkg_info in "${packages[@]}"; do
    IFS=':' read -r name size hash script install_dir source_dir <<<"$pkg_info"

    if [ "$first" = true ]; then
        first=false
    else
        echo "," >>"$MANIFEST_FILE"
    fi

    cat >>"$MANIFEST_FILE" <<EOF
    {
      "name": "$name",
      "size": "$size",
      "sha256": "$hash",
      "components": {
        "script": "$script",
        "install_dir": "$install_dir",
        "source_dir": "$source_dir"
      }
    }
EOF
done

cat >>"$MANIFEST_FILE" <<'EOF'

  ]
}
EOF

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Resumo final
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Pacotes criados com sucesso!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Total de pacotes: ${#packages[@]}${NC}"
echo ""
echo "Arquivos em: $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Upload para o servidor:"
echo "   rsync -avz --progress $OUTPUT_DIR/ usuario@servidor:/var/www/wxwidgets/"
echo ""
echo "2. Ou com scp:"
echo "   scp -r $OUTPUT_DIR/* wxwidgets.com.br:www/wxwidgets/"
echo ""
echo "3. Testar download:"
echo "   awx --base-url http://wxwidgets.com.br:8899/wxwidgets install linux 3.2.4"
echo ""
