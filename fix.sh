#!/usr/bin/env bash
set -euo pipefail
WX_LOCAL_DIR="${HOME}/.local/wxwidgets"

# se não existir o link simbólico, aborta
if [[ ! -L "$WX_LOCAL_DIR" ]]; then
    echo "Não existe: $WX_LOCAL_DIR" >&2
    exit 1
fi

WX_PACKAGE_DIR="${WX_LOCAL_DIR}/wxwidgets-package"
if [[ -e "$WX_PACKAGE_DIR" ]]; then
    echo "movendo: ${WX_PACKAGE_DIR} -> ${WX_LOCAL_DIR}"
    mv "${WX_PACKAGE_DIR}"/* "${WX_LOCAL_DIR}/"
    rm -rf "${WX_PACKAGE_DIR}"
fi

find "${WX_LOCAL_DIR}/" -xtype l | while read -r link; do
    target="$(readlink "$link")"

    case "$target" in
        wxwidgets-package/*)
            new_target="${target#wxwidgets-package/}"
            echo "corrigindo: $link"
            echo "  antes: $target"
            echo "  depois: $new_target"
            ln -sfn "$new_target" "$link"
            ;;
        *)
            echo "AVISO: link quebrado sem prefixo esperado: $link -> $target" >&2
            ;;
    esac
done
