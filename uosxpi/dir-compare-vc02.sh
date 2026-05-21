#!/usr/bin/env bash

ONLYDIR=false
NOSRCSUFFIX=false

# --- PARSE ARGS ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --src)
            SRC="$2"
            shift 2
        ;;
        --dst)
            DST="$2"
            shift 2
        ;;
        --onlyDir)
            ONLYDIR=true
            shift 1
        ;;
        --noSrcDirSuffix)
            NOSRCSUFFIX=true
            shift 1
        ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
        ;;
    esac
done

# --- VALIDATIONS ---
if [[ -z "$SRC" || -z "$DST" ]]; then
    echo "Usage: $0 --src <source_dir> --dst <destination_dir> [--onlyDir] [--noSrcDirSuffix]"
    exit 1
fi

if [[ ! -d "$SRC" ]]; then
    echo "Source directory not found: $SRC"
    exit 1
fi

if [[ ! -d "$DST" ]]; then
    echo "Destination directory not found: $DST"
    exit 1
fi


# =============================
# === MODE: ONLY FOLDERS    ===
# =============================
if [[ "$ONLYDIR" = true ]]; then
    find "$SRC" -type d | while read -r DIR_SRC; do
        # Caminho relativo em relação à origem
        REL_PATH="${DIR_SRC#$SRC/}"

        # Não considerar a raiz da origem
        if [[ -z "$REL_PATH" ]]; then
            continue
        fi

        DIR_DST="$DST/$REL_PATH"

        # Se a pasta correspondente NÃO existir na destino
        if [[ ! -d "$DIR_DST" ]]; then
            if [[ "$NOSRCSUFFIX" = true ]]; then
                # Só o caminho relativo
                echo "$REL_PATH"
            else
                # Caminho completo da origem
                echo "$DIR_SRC"
            fi
        fi
    done

    exit 0
fi


# =============================
# === MODE: FILES (DEFAULT) ===
# =============================
find "$SRC" -type f | while read -r FILE_SRC; do
    REL_PATH="${FILE_SRC#$SRC/}"
    FILE_DST="$DST/$REL_PATH"

    if [[ ! -f "$FILE_DST" ]]; then
        if [[ "$NOSRCSUFFIX" = true ]]; then
            # Só o caminho relativo (sem prefixo da origem)
            echo "$REL_PATH"
        else
            # Caminho completo da origem
            echo "$FILE_SRC"
        fi
    fi
done

