#!/usr/bin/env bash
# dir-select.sh
# Directory selector based on catalog + cursor, with "root" virtual position.

set -u  # error on unset variables

# ---------- Utilities ----------

die() {
    echo "Error: $*" >&2
    exit 1
}

ROOT_DIR=""
CATALOG_FILE=""
CURSOR_FILE=""

# Global arrays/vars initialized later
CATALOG=()
CURSOR=""

invalidate_state() {
    # Invalidate catalog and cursor for this root folder
    if [[ -n "${CATALOG_FILE:-}" ]]; then
        rm -f "$CATALOG_FILE" 2>/dev/null || true
    fi
    if [[ -n "${CURSOR_FILE:-}" ]]; then
        rm -f "$CURSOR_FILE" 2>/dev/null || true
    fi
    die "$1 (state invalidated: catalog and cursor removed)"
}

ensure_root_dir() {
    if [[ ! -d "$ROOT_DIR" ]]; then
        invalidate_state "Root directory '$ROOT_DIR' does not exist or is not accessible"
    fi
}

print_usage() {
    cat <<EOF
Usage: $0 --dskDir /path/to/root [action]

Actions (use exactly one):
  --refresh   : rebuild catalog (.dir-select-catalog) in the root dir and reposition cursor
  --first     : move cursor to the first subdirectory and print its name (no path)
  --last      : move cursor to the last subdirectory and print its name (no path)
  --next      : move cursor to the next subdirectory and print its name (no path)
  --previous  : move cursor to the previous subdirectory and print its name (no path)
  --current   : print the current cursor target: "(root)" if at root, otherwise the subdir name
  --select    : print the full path: ROOT if at "(root)", else ROOT/<subdir>
  --root      : set cursor to the virtual root position (like index = -1)

Examples:
  $0 --dskDir /mnt/sets --refresh
  $0 --dskDir /mnt/sets --root
  $0 --dskDir /mnt/sets --current
  $0 --dskDir /mnt/sets --select
  $0 --dskDir /mnt/sets --next
EOF
}

# ---------- Catalog & Cursor I/O ----------

load_catalog() {
    ensure_root_dir
    if [[ ! -f "$CATALOG_FILE" ]]; then
        die "Catalog not found at '$CATALOG_FILE'. Run --refresh first."
    fi
    mapfile -t CATALOG < "$CATALOG_FILE"
}

save_cursor() {
    echo "$CURSOR" > "$CURSOR_FILE"
}

load_cursor_number_only() {
    # Read numeric cursor (may be -1 for root). No range validation here.
    if [[ ! -f "$CURSOR_FILE" ]]; then
        invalidate_state "Cursor file not found at '$CURSOR_FILE'"
    fi
    read -r CURSOR < "$CURSOR_FILE" || CURSOR=""
    # Allow -1 (root) or non-negative integers
    if ! [[ "$CURSOR" =~ ^-?[0-9]+$ ]]; then
        invalidate_state "Invalid cursor value: '$CURSOR'"
    fi
    # Only allow -1 or >= 0
    if (( CURSOR < -1 )); then
        invalidate_state "Invalid cursor value: '$CURSOR'"
    fi
}

ensure_cursor_in_range_if_needed() {
    # Requires CATALOG loaded if CURSOR != -1
    if (( CURSOR == -1 )); then
        return 0
    fi
    local size=${#CATALOG[@]}
    if (( size == 0 )); then
        invalidate_state "Catalog is empty but cursor points to a subdirectory"
    fi
    if (( CURSOR < 0 || CURSOR >= size )); then
        invalidate_state "Cursor out of bounds: $CURSOR (catalog size = $size)"
    fi
}

ensure_current_target_exists() {
    # When at root: make sure ROOT_DIR still exists.
    if (( CURSOR == -1 )); then
        ensure_root_dir
        return 0
    fi
    # When at a subdir: ensure it still exists.
    local dname full
    dname="${CATALOG[CURSOR]}"
    full="$ROOT_DIR/$dname"
    if [[ ! -d "$full" ]]; then
        invalidate_state "Current directory no longer exists: '$full'"
    fi
}

# ---------- Arg parsing ----------

ACTION=""

if (( $# == 0 )); then
    print_usage
    exit 1
fi

while (( $# > 0 )); do
    case "$1" in
        --dskDir)
            [[ $# -ge 2 ]] || die "Missing value for --dskDir"
            ROOT_DIR="$2"
            shift 2
            ;;
        --refresh|--first|--last|--next|--previous|--current|--select|--root)
            ACTION="${1#--}"  # strip "--"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            die "Unknown parameter: $1"
            ;;
    esac
done

if [[ -z "$ROOT_DIR" ]]; then
    die "You must provide --dskDir /path/to/root"
fi

CATALOG_FILE="$ROOT_DIR/.dir-select-catalog"
CURSOR_FILE="$ROOT_DIR/.dir-select-cursor"

if [[ -z "$ACTION" ]]; then
    die "You must provide one action (e.g., --refresh, --next, --current, ...)"
fi

# ---------- Actions ----------

do_refresh() {
    ensure_root_dir

    (
        cd "$ROOT_DIR" || exit 1

        # List immediate subdirectories (non-recursive), no trailing slash in catalog
        shopt -s nullglob
        dirs=( */ )
        shopt -u nullglob

        if (( ${#dirs[@]} > 0 )); then
            for d in "${dirs[@]}"; do
                echo "${d%/}"
            done | sort > ".dir-select-catalog"
        else
            : > ".dir-select-catalog"  # empty catalog
        fi
    )

    # Cursor policy after refresh:
    # - if there are items, set to 0 (first)
    # - if empty, set to -1 (root)
    if [[ -s "$CATALOG_FILE" ]]; then
        CURSOR=0
    else
        CURSOR=-1
    fi
    save_cursor

    count=$(wc -l < "$CATALOG_FILE")
    echo "Directory catalog rebuilt at '$CATALOG_FILE' with $count entries." >&2
}

do_root() {
    # Move cursor to the virtual ROOT position (-1)
    ensure_root_dir
    CURSOR=-1
    save_cursor
    # By design, --root prints nothing but sets state. Use --current/--select next.
}

do_first() {
    load_catalog
    CURSOR=0
    ensure_current_target_exists
    save_cursor
    echo "${CATALOG[CURSOR]}"
}

do_last() {
    load_catalog
    CURSOR=$(( ${#CATALOG[@]} - 1 ))
    ensure_current_target_exists
    save_cursor
    echo "${CATALOG[CURSOR]}"
}

do_next() {
    load_catalog
    load_cursor_number_only

    # From root (-1), next goes to first (0); otherwise increment until last.
    if (( CURSOR < ${#CATALOG[@]} - 1 )); then
        CURSOR=$(( CURSOR + 1 ))
    elif (( CURSOR == -1 )) && (( ${#CATALOG[@]} > 0 )); then
        CURSOR=0
    fi

    ensure_current_target_exists
    save_cursor

    if (( CURSOR == -1 )); then
        echo "(root)"
    else
        echo "${CATALOG[CURSOR]}"
    fi
}

do_previous() {
    load_catalog
    load_cursor_number_only
    ensure_cursor_in_range_if_needed

    # At root (-1), there is no "previous" — stay at root.
    if (( CURSOR > 0 )); then
        CURSOR=$(( CURSOR - 1 ))
    fi

    ensure_current_target_exists
    save_cursor

    if (( CURSOR == -1 )); then
        echo "(root)"
    else
        echo "${CATALOG[CURSOR]}"
    fi
}

do_current() {
    # Current must work even if at root without requiring a catalog.
    load_cursor_number_only

    if (( CURSOR == -1 )); then
        ensure_root_dir
        echo "(root)"
        return
    fi

    load_catalog
    ensure_cursor_in_range_if_needed
    ensure_current_target_exists
    echo "${CATALOG[CURSOR]}"
}

do_select() {
    # Select must work at root (prints ROOT_DIR) or on a subdir (prints full path).
    load_cursor_number_only

    if (( CURSOR == -1 )); then
        ensure_root_dir
        echo "$ROOT_DIR"
        return
    fi

    load_catalog
    ensure_cursor_in_range_if_needed
    ensure_current_target_exists
    echo "$ROOT_DIR/${CATALOG[CURSOR]}"
}

# ---------- Dispatcher ----------

case "$ACTION" in
    refresh)   do_refresh   ;;
    first)     do_first     ;;
    last)      do_last      ;;
    next)      do_next      ;;
    previous)  do_previous  ;;
    current)   do_current   ;;
    select)    do_select    ;;
    root)      do_root      ;;
    *)
        die "Unknown action: $ACTION"
        ;;
esac

