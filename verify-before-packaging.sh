#!/usr/bin/env bash
# Script para verificar estrutura antes de empacotar

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Verificação pré-empacotamento ===${NC}"
echo ""

total_errors=0
total_warnings=0

# Função para verificar um conjunto de arquivos
verify_set() {
    local script=$1
    local install_dir=$2
    local source_dir=$3
    local name=$4

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Verificando: $name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local errors=0
    local warnings=0

    # Verifica script
    if [ -f "$script" ]; then
        echo -e "  ${GREEN}✓${NC} Script: $script"
        if [ ! -x "$script" ]; then
            echo -e "    ${YELLOW}⚠${NC}  Aviso: Script não é executável"
            warnings=$((warnings + 1))
        fi
    else
        echo -e "  ${RED}✗${NC} Script não encontrado: $script"
        errors=$((errors + 1))
    fi

    # Verifica diretório de instalação
    if [ -d "$install_dir" ]; then
        echo -e "  ${GREEN}✓${NC} Instalação: $install_dir"

        # Verifica estrutura básica
        local has_lib=false
        local has_include=false

        [ -d "$install_dir/lib" ] && has_lib=true
        [ -d "$install_dir/include" ] && has_include=true

        if $has_lib; then
            echo -e "    ${GREEN}✓${NC} lib/"
        else
            echo -e "    ${RED}✗${NC} lib/ não encontrado"
            errors=$((errors + 1))
        fi

        if $has_include; then
            echo -e "    ${GREEN}✓${NC} include/"
        else
            echo -e "    ${RED}✗${NC} include/ não encontrado"
            errors=$((errors + 1))
        fi

    else
        echo -e "  ${RED}✗${NC} Instalação não encontrada: $install_dir"
        errors=$((errors + 1))
    fi

    # Verifica diretório fonte
    if [ -d "$source_dir" ]; then
        echo -e "  ${GREEN}✓${NC} Fonte: $source_dir"
    else
        echo -e "  ${RED}✗${NC} Fonte não encontrada: $source_dir"
        errors=$((errors + 1))
    fi

    # Verifica links simbólicos
    if [ -d "$install_dir" ]; then
        echo -e "  ${BLUE}Verificando links simbólicos...${NC}"

        local total_links=$(find "$install_dir" -type l 2>/dev/null | wc -l)
        local broken_links=$(find "$install_dir" -xtype l 2>/dev/null | wc -l)

        echo -e "    Total de links: $total_links"

        if [ $broken_links -gt 0 ]; then
            echo -e "    ${YELLOW}⚠${NC}  Links quebrados: $broken_links"
            echo -e "    ${BLUE}ℹ${NC}  Listando links quebrados:"

            find "$install_dir" -xtype l 2>/dev/null | while read -r link; do
                local target=$(readlink "$link")
                echo -e "      ${RED}→${NC} $link"
                echo -e "         aponta para: $target"

                # Verifica se o alvo existe no diretório fonte
                if [[ "$target" == *"$source_dir"* ]]; then
                    if [ -e "$target" ]; then
                        echo -e "         ${GREEN}✓${NC} Será resolvido pelo código fonte"
                    else
                        echo -e "         ${RED}✗${NC} Alvo não existe nem no fonte!"
                        errors=$((errors + 1))
                    fi
                else
                    echo -e "         ${RED}✗${NC} Aponta para fora do fonte!"
                    errors=$((errors + 1))
                fi
            done

            warnings=$((warnings + broken_links))
        else
            echo -e "    ${GREEN}✓${NC} Nenhum link quebrado"
        fi
    fi

    # Calcula tamanhos
    if [ -d "$install_dir" ] && [ -d "$source_dir" ]; then
        echo -e "  ${BLUE}Tamanhos:${NC}"
        local install_size=$(du -sh "$install_dir" 2>/dev/null | cut -f1)
        local source_size=$(du -sh "$source_dir" 2>/dev/null | cut -f1)
        echo -e "    Instalação: $install_size"
        echo -e "    Fonte: $source_size"
    fi

    echo ""
    if [ $errors -gt 0 ]; then
        echo -e "  ${RED}✗ $errors erro(s) encontrado(s)${NC}"
    else
        echo -e "  ${GREEN}✓ Pronto para empacotar${NC}"
    fi

    if [ $warnings -gt 0 ]; then
        echo -e "  ${YELLOW}⚠ $warnings aviso(s)${NC}"
    fi

    echo ""

    total_errors=$((total_errors + errors))
    total_warnings=$((total_warnings + warnings))
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Verificações
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

verify_set \
    "build-linux-3.2.4.sh" \
    "linux-wx-3.2.4" \
    "wxWidgets-3.2.4-linux" \
    "Linux 3.2.4"

verify_set \
    "build-linux-3.3.1.sh" \
    "linux-wx-3.3.1" \
    "wxWidgets-3.3.1-linux" \
    "Linux 3.3.1"

verify_set \
    "build-linux-cmake-3.2.4.sh" \
    "linux-cmake-wx-3.2.4" \
    "wxWidgets-3.2.4-linux-cmake" \
    "Linux CMake 3.2.4"

verify_set \
    "build-android-3.2.4.sh" \
    "android-wx-3.2.4-RELEASE" \
    "wxWidgets-3.2.4-android" \
    "Android 3.2.4 Release"

verify_set \
    "build-android-3.2.4-debug.sh" \
    "android-wx-3.2.4-DEBUG" \
    "wxWidgets-3.2.4-android-debug" \
    "Android 3.2.4 Debug"

verify_set \
    "build-android-3.3.1.sh" \
    "android-wx-3.3.1" \
    "wxWidgets-3.3.1-android" \
    "Android 3.3.1 Release"

verify_set \
    "build-android-3.3.1-debug.sh" \
    "android-debug-wx-3.3.1" \
    "wxWidgets-3.3.1-android-debug" \
    "Android 3.3.1 Debug"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Resumo final
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Resumo da Verificação${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $total_errors -gt 0 ]; then
    echo -e "${RED}✗ Total de erros: $total_errors${NC}"
    echo -e "${RED}Corrija os erros antes de empacotar!${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Nenhum erro encontrado!${NC}"
fi

if [ $total_warnings -gt 0 ]; then
    echo -e "${YELLOW}⚠ Total de avisos: $total_warnings${NC}"
    echo -e "${YELLOW}Os avisos não impedem o empacotamento, mas verifique-os.${NC}"
fi

echo ""
echo -e "${GREEN}Tudo pronto para executar:${NC}"
echo -e "  ${BLUE}./prepare-wxwidgets-packages.sh${NC}"
echo ""
