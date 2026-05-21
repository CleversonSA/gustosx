#!/usr/bin/env bash
set -euo pipefail

# Encontra um dispositivo de TECLADO em /dev/input/by-path
find_kbd() {
  for p in /dev/input/by-path/*-event-kbd; do
    [ -e "$p" ] && readlink -f "$p"
  done | head -n1
}

DEV="$(find_kbd || true)"
[ -n "${DEV:-}" ] || { echo -1 > /home/umsxpi/f10-pressed.flag; exit 0; }

echo $DEV
# Ouve por no máximo 5s e “agarra” o device (não deixa vazar a tecla) nesse intervaloi
timeout 10s /usr/bin/bash -c "/bin/evtest --grab '$DEV'"

if timeout 10s /usr/bin/bash -c "/bin/evtest --grab '$DEV' 2>/dev/null | grep -m1 '(KEY_F10), value'" >/dev/null; then
  echo 1 > /home/umsxpi/f10-pressed.flag
else
  echo 0 > /home/umsxpi/f10-pressed.flag
fi

cat /home/umsxpi/f10-pressed.flag
exit 0
