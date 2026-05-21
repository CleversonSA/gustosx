#!/usr/bin/env bash
# dsk-select.sh
# Gerenciador de seleção de arquivos .dsk baseado em catálogo + cursor

set -u  # erro em variáveis não definidas

# ---------- Funções utilitárias ----------

die() {
    echo "Erro: $*" >&2
    exit 1
}

# Será configurado depois que --dskDir for lido
DSK_DIR=""
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

ensure_dir() {
    if [[ ! -d "$DSK_DIR" ]]; then
        invalidate_state "Diretório '$DSK_DIR' não existe ou não está acessível"
    fi
}

load_catalog() {
    ensure_dir
    if [[ ! -f "$CATALOG_FILE" ]]; then
        die "Catálogo não encontrado em '$CATALOG_FILE'. Execute com --refresh primeiro."
    fi

    mapfile -t CATALOG < "$CATALOG_FILE"

    if (( ${#CATALOG[@]} == 0 )); then
        die "Catálogo vazio: nenhum arquivo .dsk encontrado em '$DSK_DIR'. Execute --refresh e verifique."
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

ensure_current_file_exists() {
    local fname full
    fname="${CATALOG[CURSOR]}"
    full="$DSK_DIR/$fname"
    if [[ ! -f "$full" ]]; then
        invalidate_state "Arquivo atual não existe mais: '$full'"
    fi
}

print_usage() {
    cat <<EOF
Uso: $0 --dskDir /caminho/para/pasta_dsk [ação]

Ações (use exatamente uma):
  --refresh   : recria o catálogo (.dsk-select-catalog) na pasta e reposiciona o cursor
  --first     : move o cursor para o primeiro arquivo e imprime o nome (sem caminho)
  --last      : move o cursor para o último arquivo e imprime o nome (sem caminho)
  --next      : move o cursor para o próximo arquivo e imprime o nome (sem caminho)
  --previous  : move o cursor para o arquivo anterior e imprime o nome (sem caminho)
  --current   : imprime o nome do arquivo onde o cursor está (sem caminho)
  --select    : imprime o caminho completo do arquivo onde o cursor está

Exemplos:
  $0 --dskDir /mnt/dsk --refresh
  $0 --dskDir /mnt/dsk --first
  $0 --dskDir /mnt/dsk --next
  $0 --dskDir /mnt/dsk --current
  $0 --dskDir /mnt/dsk --select
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
            DSK_DIR="$2"
            shift 2
            ;;
        --refresh|--first|--last|--next|--previous|--current|--select)
            ACTION="${1#--}"  # tira o prefixo "--"
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

if [[ -z "$DSK_DIR" ]]; then
    die "Você deve informar --dskDir /caminho/para/pasta"
fi

CATALOG_FILE="$DSK_DIR/.dsk-select-catalog"
CURSOR_FILE="$DSK_DIR/.dsk-select-cursor"

if [[ -z "$ACTION" ]]; then
    die "Você deve informar uma ação (por exemplo, --refresh, --next, --current, ...)"
fi

# ---------- Implementação das ações ----------

do_refresh() {
    ensure_dir

    # Cria catálogo com todos arquivos *.dsk (case-insensitive), ordenados pelo nome
    (
        cd "$DSK_DIR" || exit 1

        shopt -s nullglob nocaseglob
        files=( *.dsk )
        shopt -u nocaseglob
        shopt -u nullglob

        if (( ${#files[@]} > 0 )); then
            printf '%s\n' "${files[@]}" | sort > ".dsk-select-catalog"
        else
            : > ".dsk-select-catalog"  # catálogo vazio
        fi
    )

    # Define cursor:
    # - se houver arquivos, posiciona no primeiro (0)
    # - se não houver, cursor = -1 (mas isso só é usado como "sem itens")
    if [[ -s "$CATALOG_FILE" ]]; then
        echo "0" > "$CURSOR_FILE"
    else
        echo "-1" > "$CURSOR_FILE"
    fi

    # Para --refresh não imprimimos nada "útil" em stdout, apenas mensagem informativa em stderr
    count=$(wc -l < "$CATALOG_FILE")
    echo "Catálogo recriado em '$CATALOG_FILE' com $count arquivo(s)." >&2
}

do_first() {
    load_catalog
    CURSOR=0
    ensure_current_file_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_last() {
    load_catalog
    CURSOR=$(( ${#CATALOG[@]} - 1 ))
    ensure_current_file_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_next() {
    load_catalog
    load_cursor

    if (( CURSOR < ${#CATALOG[@]} - 1 )); then
        CURSOR=$(( CURSOR + 1 ))
    fi

    ensure_current_file_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_previous() {
    load_catalog
    load_cursor

    if (( CURSOR > 0 )); then
        CURSOR=$(( CURSOR - 1 ))
    fi

    ensure_current_file_exists
    echo "$CURSOR" > "$CURSOR_FILE"
    echo "${CATALOG[CURSOR]}"
}

do_current() {
    load_catalog
    load_cursor
    ensure_current_file_exists
    echo "${CATALOG[CURSOR]}"
}

do_select() {
    load_catalog
    load_cursor
    ensure_current_file_exists
    echo "$DSK_DIR/${CATALOG[CURSOR]}"
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

