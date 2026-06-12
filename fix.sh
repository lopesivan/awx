#!/usr/bin/env bash
set -euo pipefail

find . -type l | while read -r link; do
    target="$(readlink "$link")"

    case "$target" in
        wxwidgets-package/*)
            new_target="${target#wxwidgets-package/}"

            echo "corrigindo: $link"
            echo "  antes: $target"
            echo "  depois: $new_target"

            rm "$link"
            ln -s "$new_target" "$link"
            ;;
    esac
done
