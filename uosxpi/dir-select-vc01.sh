#!/usr/bin/env bash
# dir-select.sh
# Gerenciador de seleção de PASTAS baseado em catálogo + cursor

set -u  # erro em variáveis não definidas

# ---------- Funções utilitárias ----------

die() {
    echo "Erro: $*" >&2
    exit 1
}

DIR_ROOT=""
CATALOG_FILE=""
CURSOR_FILE=""

invalidate_state() {
    # Invalida catálogo e cursor desta pasta
    if [[ -n "${CATALOG_FILE:-}" ]]; then
        rm -f "$CATALOG_FILE" 2>/dev/null || true
    fi
    if [[ -n "${CURSOR_FILE:-}" ]]; then
        rm -f "$CURSOR_FILE" 2>/dev/null || true
    fi
    die "$1 (estado invalidado: catálogo e cursor removidos)"
}

ensure_root_dir() {
    if [[ ! -d "$DIR_ROOT" ]]; then
        invalidate_state "Diretório raiz '$DIR_ROOT' não existe ou não está acessível"
    fi
}

load_catalog() {
    ensure_root_dir
    if [[ ! -f "$CATALOG_FILE" ]]; then
        die "Catálogo não encontrado em '$CATALOG_FILE'. Execute com --refresh primeiro."
    fi

    mapfile -t CATALOG < "$CATALOG_FILE"

    if (( ${#CATALOG[@]} == 0 )); then
        die "Catálogo vazio: nenhuma subpasta encontrada em '$DIR_ROOT'. Execute --refresh e verifique."
    fi
}

load_cursor() {
    if [[ ! -f "$CURSOR_FILE" ]]; then
        invalidate_state "Arquivo de cursor não encontrado em '$CURSOR_FILE'"
    fi

    read -r CURSOR < "$CURSOR_FILE" || CURSOR=""

    if ! [[ "$CURSOR" =~ ^[0-9]+$ ]]; then
        invalidate_state "Valor de cursor inválido: '$CURSOR'"
    fi

    if (( CURSOR < 0 || CURSOR >= ${#CATALOG[@]} )); then
        invalidate_state "Cursor fora da faixa: $CURSOR (tamanho do catálogo = ${#CATALOG[@]})"
    fi
}

ensure_current_dir_exists() {
    local dname full
    dname="${CATALOG[CURSOR]}"
    full="$DIR_ROOT/$dname"
    if [[ ! -d "$full" ]]; then
        invalidate_state "Diretório atual não existe mais: '$full'"
    fi
}

print_usage() {
    cat <<EOF
Uso: $0 --dskDir /caminho/para/raiz [ação]

Ações (use exatamente uma):
  --refresh   : recria o catálogo (.dir-select-catalog) na pasta raiz e reposiciona o cursor
  --first     : move o cursor para a primeira subpasta e imprime o nome (sem caminho)
  --last      : move o cursor para a última subpasta e imprime o nome (sem caminho)
  --next      : move o cursor para a próxima subpasta e imprime o nome (sem caminho)
  --previous  : move o cursor para a subpasta anterior e imprime o nome (sem caminho)
  --current   : imprime o nome da subpasta onde o cursor está (sem caminho)
  --select    : imprime o caminho completo da subpasta onde o cursor está

Exemplos:
  $0 --dskDir /mnt/dskdirs --refresh
  $0 --dskDir /mnt/dskdirs --first
  $0 --dskDir /mnt/dskdirs --next
  $0 --dskDir /mnt/dskdirs --current
  $0 --dskDir /mnt/dskdirs --select
EOF
}

# ---------- Parse de argumentos ----------

ACTION=""

if (( $# == 0 )); then
    print_usage
    exit 1
fi

while (( $# > 0 )); do
    case "$1" in
        --dskDir)
            [[ $# -ge 2 ]] || die "Faltando argumento para --dskDir"
            DIR_ROOT="$2"
            shift 2
            ;;
        --refresh|--first|--last|--next|--previous|--current|--select)
            ACTION="${1#--}"  # remove o prefixo "--"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            die "Parâmetro desconhecido: $1"
            ;;
    esac
done

if [[ -z "$DIR_ROOT" ]]; then
    die "Você deve informar --dskDir /caminho/para/raiz"
fi

CATALOG_FILE="$DIR_ROOT/.dir-select-catalog"
CURSOR_FILE="$DIR_ROOT/.dir-select-cursor"

if [[ -z "$ACTION" ]]; then
    die "Você deve informar uma ação (por exemplo, --refresh, --next, --current, ...)"
fi

# ---------- Implementação das ações ----------

do_refresh() {
    ensure_root_dir

    (
        cd "$DIR_ROOT" || exit 1

        # Lista apenas subdiretórios imediatos (não recursivo), sem ponto final / no catálogo
        shopt -s nullglob
        dirs=( */ )
        shopt -u nullglob

        if (( ${#dirs[@]} > 0 )); then
            # Remove a barra final e ordena
            for d in "${dirs[@]}"; do
                echo "${d%/}"
            done | sort > ".dir-select-catalog"
        else
            : > ".dir-select-catalog"  # catálogo vazio
        fi
    )

    # Define cursor:
    if [[ -s "$CATALOG_FILE" ]]; then
        echo "0" > "$CURSOR_FILE"
    else
        echo "-1" > "$CURSOR_FILE"
    fi

    count=$(wc -l < "$CATALOG_FILE")
    echo "Catálogo de pastas recriado em '$CATALOG_FILE' com $count diretório(s)." >&2
}

do_first() {
    load_catalog
    CURSOR=0
    ensure_current_dir_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_last() {
    load_catalog
    CURSOR=$(( ${#CATALOG[@]} - 1 ))
    ensure_current_dir_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_next() {
    load_catalog
    load_cursor

    if (( CURSOR < ${#CATALOG[@]} - 1 )); then
        CURSOR=$(( CURSOR + 1 ))
    fi

    ensure_current_dir_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_previous() {
    load_catalog
    load_cursor

    if (( CURSOR > 0 )); then
        CURSOR=$(( CURSOR - 1 ))
    fi

    ensure_current_dir_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_current() {
    load_catalog
    load_cursor
    ensure_current_dir_exists
    echo "${CATALOG[CURSOR]}"
}

do_select() {
    load_catalog
    load_cursor
    ensure_current_dir_exists
    echo "$DIR_ROOT/${CATALOG[CURSOR]}"
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
    *)
        die "Ação desconhecida: $ACTION"
        ;;
esac

