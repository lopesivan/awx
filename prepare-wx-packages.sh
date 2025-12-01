#!/bin/bash
# Script para empacotar compilações do wxWidgets para distribuição

set -e

OUTPUT_DIR="wxwidgets-packages"
MANIFEST_FILE="$OUTPUT_DIR/manifest.json"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Preparando pacotes do wxWidgets ===${NC}"

# Cria diretório de saída
mkdir -p "$OUTPUT_DIR"

# Array para armazenar informações dos pacotes
declare -a packages

# Função para empacotar um diretório
package_dir() {
    local dir=$1
    local archive_name="${dir}.tar.gz"
    
    if [ ! -d "$dir" ]; then
        echo "Aviso: Diretório $dir não encontrado, pulando..."
        return
    fi
    
    echo -e "${GREEN}Empacotando: $dir → $archive_name${NC}"
    
    # Cria o arquivo tar.gz
    tar -czf "$OUTPUT_DIR/$archive_name" "$dir"
    
    # Obtém informações do pacote
    local size=$(du -h "$OUTPUT_DIR/$archive_name" | cut -f1)
    local hash=$(sha256sum "$OUTPUT_DIR/$archive_name" | cut -d' ' -f1)
    
    echo "  Tamanho: $size"
    echo "  SHA256: ${hash:0:16}..."
    
    # Adiciona ao array de pacotes
    packages+=("$archive_name:$size:$hash")
}

# Empacota cada compilação
echo ""
echo "Empacotando compilações Linux..."
package_dir "linux-wx-3.2.4"
package_dir "linux-wx-3.3.1"
package_dir "linux-cmake-wx-3.2.4"
package_dir "linux-cmake-wx-3.3.1"

echo ""
echo "Empacotando compilações Windows..."
package_dir "windows-wx-3.2.4"
package_dir "windows-wx-3.3.1"

echo ""
echo "Empacotando compilações Android..."
package_dir "android-wx-3.2.4-DEBUG"
package_dir "android-wx-3.2.4-RELEASE"

# Gera arquivo manifest.json
echo ""
echo "Gerando manifest.json..."
cat > "$MANIFEST_FILE" << 'EOF'
{
  "version": "1.0",
  "generated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "packages": [
EOF

first=true
for pkg_info in "${packages[@]}"; do
    IFS=':' read -r name size hash <<< "$pkg_info"
    
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$MANIFEST_FILE"
    fi
    
    cat >> "$MANIFEST_FILE" << EOF
    {
      "name": "$name",
      "size": "$size",
      "sha256": "$hash"
    }
EOF
done

cat >> "$MANIFEST_FILE" << 'EOF'

  ]
}
EOF

echo ""
echo -e "${GREEN}✓ Todos os pacotes criados com sucesso!${NC}"
echo ""
echo "Arquivos gerados em: $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"

echo ""
echo "Para fazer upload para o servidor, execute:"
echo "  rsync -avz $OUTPUT_DIR/ usuario@servidor:/path/to/wxwidgets/"
echo ""
echo "Ou com scp:"
echo "  scp -r $OUTPUT_DIR/* usuario@servidor:/path/to/wxwidgets/"
