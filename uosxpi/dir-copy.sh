#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
    echo "Usage: $0 --filelist <file> --src <src_dir> --dst <dst_dir> [--command <shell_command>] [--command-ins-spa <shell_command>]"
    exit 1
}

# Parameters
FILE_LIST=""
SRC_DIR=""
DST_DIR=""
COMMAND=""
COMMAND_INS_SPA=""
COMMAND_FINISH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --filelist)
            FILE_LIST="$2"
            shift 2
            ;;
        --src)
            SRC_DIR="$2"
            shift 2
            ;;
        --dst)
            DST_DIR="$2"
            shift 2
            ;;
        --command)
            COMMAND="$2"
            shift 2
            ;;
	--command-ins-spa)
	    COMMAND_INS_SPA="$2"
	    shift 2
	    ;;
	--command-finish)
	    COMMAND_FINISH="$2"
	    shift 2
	    ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
done

# Basic validation
[[ -z "$FILE_LIST" || -z "$SRC_DIR" || -z "$DST_DIR" ]] && usage

if [[ ! -f "$FILE_LIST" ]]; then
    echo "File list not found: $FILE_LIST"
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Source directory not found: $SRC_DIR"
    exit 1
fi

if [[ ! -d "$DST_DIR" ]]; then
    echo "Destination directory not found: $DST_DIR"
    exit 1
fi

###############################################################################
# a) Sum all file sizes in bytes -> FILE_LIST_SIZE
###############################################################################
FILE_LIST_SIZE=0

while IFS= read -r REL_PATH || [[ -n "$REL_PATH" ]]; do
    [[ -z "$REL_PATH" ]] && continue

    SRC_FILE="$SRC_DIR/$REL_PATH"

    if [[ ! -f "$SRC_FILE" ]]; then
        echo "WARNING: source file not found, skipping: $SRC_FILE"
        continue
    fi

    FILE_SIZE=$(stat -c%s "$SRC_FILE")
    FILE_LIST_SIZE=$(( FILE_LIST_SIZE + FILE_SIZE ))
done < "$FILE_LIST"

###############################################################################
# b) Free disk space on --dst volume -> DST_FREE_SIZE (bytes)
###############################################################################
DST_FREE_SIZE=$(df -PB1 "$DST_DIR" | awk 'NR==2 {print $4}')

###############################################################################
# c) Compare FILE_LIST_SIZE vs DST_FREE_SIZE
###############################################################################
if (( DST_FREE_SIZE < FILE_LIST_SIZE )); then
    if [[ -n "${COMMAND_INS_SPA:-}" ]]; then
        # Run custom command without concatenation
        eval "$COMMAND_INST_SPA"
    else
        echo "INSUFFICIENT AVAILABLE DISK SPACE"
    fi
    exit 1
fi

###############################################################################
# d) Count number of lines in file list -> FILE_LIST_COUNT
###############################################################################
FILE_LIST_COUNT=$(wc -l < "$FILE_LIST")

if (( FILE_LIST_COUNT == 0 )); then
    if [[ -n "${COMMAND:-}" ]]; then
        # Run custom command without concatenation
        eval "$COMMAND"
    else
        echo "NO FILES"
    fi
    exit 0
fi

###############################################################################
# e) FILE_LINE_POS = 0
###############################################################################
FILE_LINE_POS=0

###############################################################################
# f) Copy loop with progress
###############################################################################
COPY_PROGRESS=0
NEXT_PROGRESS_MARK=25

while IFS= read -r REL_PATH || [[ -n "$REL_PATH" ]]; do
    [[ -z "$REL_PATH" ]] && continue

    FILE_LINE_POS=$(( FILE_LINE_POS + 1 ))

    SRC_FILE="$SRC_DIR/$REL_PATH"
    DST_FILE="$DST_DIR/$REL_PATH"

    # Ensure directory exists
    mkdir -p "$(dirname "$DST_FILE")"

    # Copy command
    cp -f "$SRC_FILE" "$DST_FILE"

    # Progress calculation
    COPY_PROGRESS=$(( FILE_LINE_POS * 100 / FILE_LIST_COUNT ))

    # Print progress at 25% intervals (25, 50, 75, 100)
    while (( COPY_PROGRESS >= NEXT_PROGRESS_MARK && NEXT_PROGRESS_MARK <= 100 )); do
        if [[ -n "${COMMAND:-}" ]]; then
            # Concatenate formatted percentage (e.g., "25%") to the command
            PROG_STR="${NEXT_PROGRESS_MARK}%"
            eval "$COMMAND\"$PROG_STR\""
        else
            echo "COPY PROGRESS: ${NEXT_PROGRESS_MARK}%"
        fi
        NEXT_PROGRESS_MARK=$(( NEXT_PROGRESS_MARK + 25 ))
    done

done < "$FILE_LIST"

if [[ -n "${COMMAND_FINISH:-}" ]]; then
   # Run custom command without concatenation
   eval "$COMMAND_FINISH"
fi
 
