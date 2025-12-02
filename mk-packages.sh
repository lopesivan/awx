#!/usr/bin/env bash

# Script para compactar diretórios wxWidgets e gerar manifest.json

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Compactador wxWidgets"
echo "========================================="
echo

# Cria diretório de destino
mkdir -p wx-packpages

# Compacta os pacotes
echo -e "${YELLOW}Compactando pacotes...${NC}"
echo

V=3.2.4
OS=linux
script=build-${OS}-${V}.sh
build=${OS}-wx-${V}
source=wxWidgets-${V}-${OS}
echo "Compactando ${OS}-wx-${V}.tar.gz"
tar czf ${OS}-wx-${V}.tar.gz $script $build $source
mv ${OS}-wx-${V}.tar.gz wx-packpages

V=3.2.4
OS=linux-cmake
script=build-${OS}-${V}.sh
build=${OS}-wx-${V}
source=wxWidgets-${V}-${OS}
echo "Compactando ${OS}-wx-${V}.tar.gz"
tar czf ${OS}-wx-${V}.tar.gz $script $build $source
mv ${OS}-wx-${V}.tar.gz wx-packpages

V=3.3.1
OS=linux
script=build-${OS}-${V}.sh
build=${OS}-wx-${V}
source=wxWidgets-${V}-${OS}
echo "Compactando ${OS}-wx-${V}.tar.gz"
tar czf ${OS}-wx-${V}.tar.gz $script $build $source
mv ${OS}-wx-${V}.tar.gz wx-packpages

V=3.3.1
OS=linux-cmake
script=build-${OS}-${V}.sh
build=${OS}-wx-${V}
source=wxWidgets-${V}-${OS}
echo "Compactando ${OS}-wx-${V}.tar.gz"
tar czf ${OS}-wx-${V}.tar.gz $script $build $source
mv ${OS}-wx-${V}.tar.gz wx-packpages

echo
echo -e "${GREEN}✓ Pacotes compactados${NC}"
echo

# Gera o manifest.json
echo -e "${YELLOW}Gerando manifest.json${NC}"

current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cd wx-packpages

cat >manifest.json <<'EOF_START'
{
  "version": "1.0",
  "generated": "
EOF_START

echo -n "$current_date" >>manifest.json

cat >>manifest.json <<'EOF_MIDDLE'
",
  "packages": [
EOF_MIDDLE

# Array com os pacotes na ordem correta
packages=(
    "linux-wx-3.2.4.tar.gz:build-linux-3.2.4.sh:linux-wx-3.2.4:wxWidgets-3.2.4-linux"
    "linux-wx-3.3.1.tar.gz:build-linux-3.3.1.sh:linux-wx-3.3.1:wxWidgets-3.3.1-linux"
    "linux-cmake-wx-3.2.4.tar.gz:build-linux-cmake-3.2.4.sh:linux-cmake-wx-3.2.4:wxWidgets-3.2.4-linux-cmake"
    "linux-cmake-wx-3.3.1.tar.gz:build-linux-cmake-3.3.1.sh:linux-cmake-wx-3.3.1:wxWidgets-3.3.1-linux-cmake"
)

first=true
for pkg in "${packages[@]}"; do
    IFS=':' read -r name script install_dir source_dir <<<"$pkg"

    if [ ! -f "$name" ]; then
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
    cat >>manifest.json <<EOF_ENTRY
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
EOF_ENTRY
done

# Fecha o JSON
cat >>manifest.json <<'EOF_END'

  ]
}
EOF_END

cd ..

echo -e "${GREEN}✓ manifest.json criado${NC}"
echo

echo "========================================="
echo "Arquivos gerados em wx-packpages/:"
ls -lh wx-packpages/
echo "========================================="
