#!/usr/bin/env bash

# Script para compactar diretórios wxWidgets e gerar manifest.json

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "Compactador wxWidgets"
echo "========================================="
echo

# Cria diretório de destino
mkdir -p wx-packpages

# Define os pacotes a serem criados
declare -a PACKAGES=(
    "3.2.4:linux"
    "3.2.4:linux-cmake"
    "3.2.4:android-arm64-v8a"
    "3.3.1:linux"
    "3.3.1:linux-cmake"
    "3.3.1:android-arm64-v8a"
)

# Loop para compactar cada pacote
echo -e "${YELLOW}Compactando pacotes...${NC}"
echo

for pkg in "${PACKAGES[@]}"; do
    IFS=':' read -r V OS <<<"$pkg"

    script="build-${OS}-${V}.sh"
    build="${OS}-wx-${V}"
    source="wxWidgets-${V}-${OS}"
    tarfile="${OS}-wx-${V}.tar.gz"

    # Verifica se o tar já existe
    if [ -f "wx-packpages/${tarfile}" ]; then
        echo -e "${GREEN}✓ ${tarfile} já existe, pulando...${NC}"
        continue
    fi

    # Verifica se os componentes existem
    missing=false
    for component in "$script" "$build" "$source"; do
        if [ ! -e "$component" ]; then
            echo -e "${RED}✗ ${component} não encontrado, pulando ${tarfile}${NC}"
            missing=true
            break
        fi
    done

    if [ "$missing" = true ]; then
        continue
    fi

    # Compacta o pacote
    echo -e "${YELLOW}Compactando ${tarfile}...${NC}"
    tar czf "${tarfile}" "$script" "$build" "$source"

    if [ $? -eq 0 ]; then
        mv "${tarfile}" wx-packpages/
        size=$(du -h "wx-packpages/${tarfile}" | cut -f1)
        echo -e "${GREEN}✓ ${tarfile} criado (${size})${NC}"
    else
        echo -e "${RED}✗ Erro ao criar ${tarfile}${NC}"
    fi
    echo
done

echo -e "${GREEN}✓ Compactação concluída${NC}"
echo

# Gera o manifest.json
echo -e "${YELLOW}Gerando manifest.json${NC}"

current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cd wx-packpages

# Início do JSON
cat >manifest.json <<EOF
{
  "version": "1.0",
  "generated": "$current_date",
  "packages": [
EOF

first=true
for pkg in "${PACKAGES[@]}"; do
    IFS=':' read -r V OS <<<"$pkg"

    script="build-${OS}-${V}.sh"
    install_dir="${OS}-wx-${V}"
    source_dir="wxWidgets-${V}-${OS}"
    name="${OS}-wx-${V}.tar.gz"

    # Verifica se o arquivo existe
    if [ ! -f "$name" ]; then
        echo -e "${YELLOW}⚠ ${name} não encontrado, não será incluído no manifest${NC}"
        continue
    fi

    # Adiciona vírgula se não for o primeiro
    if [ "$first" = false ]; then
        echo "," >>manifest.json
    fi
    first=false

    # Calcula SHA256 e tamanho
    sha256=$(sha256sum "$name" | awk '{print $1}')
    size=$(du -h "$name" | cut -f1)

    # Adiciona entrada ao JSON
    cat >>manifest.json <<EOF
    {
      "name": "$name",
      "size": "$size",
      "sha256": "$sha256",
      "components": {
        "script": "$script",
        "install_dir": "$install_dir",
        "source_dir": "$source_dir"
      }
    }
EOF
done

# Fecha o JSON
cat >>manifest.json <<'EOF'

  ]
}
EOF

cd ..

echo -e "${GREEN}✓ manifest.json criado${NC}"
echo

echo "========================================="
echo "Arquivos gerados em wx-packpages/:"
ls -lh wx-packpages/
echo "========================================="

exit 0
