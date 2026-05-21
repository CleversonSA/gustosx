#!/usr/bin/env bash

ONLYDIR=false

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
        *)
            echo "Unknown parameter: $1"
            exit 1
        ;;
    esac
done

# --- VALIDATIONS ---
if [[ -z "$SRC" || -z "$DST" ]]; then
    echo "Usage: $0 --src <source_dir> --dst <destination_dir> [--onlyDir]"
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
        REL_PATH="${DIR_SRC#$SRC/}"
        DIR_DST="$DST/$REL_PATH"

        # Não mostrar a pasta raiz (".")
        if [[ "$REL_PATH" == "$SRC" || "$REL_PATH" == "" ]]; then
            continue
        fi

        # Se a pasta correspondente NÃO existir na destino
        if [[ ! -d "$DIR_DST" ]]; then
            echo "$DIR_SRC"
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
        echo "$FILE_SRC"
    fi
done

