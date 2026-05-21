#!/usr/bin/env bash
set -euo pipefail

# Garanta um TERM válido para tput no console do kernel
export TERM=${TERM:-linux}
F10_SEQ="$(tput kf10 2>/dev/null || printf '\e[21~')"  # fallback padrão do console

TTY="/dev/tty"  # o systemd vai amarrar isto à /dev/tty1 pra nós

# Salva e silencia o console (sem eco, leitura byte a byte)
oldstty=$(stty -F "$TTY" -g || true)
cleanup() { stty -F "$TTY" "$oldstty" 2>/dev/null || true; }
trap cleanup EXIT
stty -F "$TTY" -echo -icanon time 0 min 0

# Lê diretamente da TTY vinculada ao serviço
exec 3<"$TTY"

# Drena qualquer lixo já no buffer (ex.: teclas seguradas antes)
while IFS= read -rsn1 -t 0.001 -u 3 _; do :; done

deadline=$((SECONDS + 5))
buf=""
pressed=0

while [ $SECONDS -lt $deadline ]; do
  if IFS= read -rsn1 -t 0.1 -u 3 ch; then
    buf+="$ch"
    if [[ "$buf" == "$F10_SEQ" ]]; then pressed=1; break; fi
    [[ "$F10_SEQ" == "$buf"* ]] || buf=""
  fi
done

# Restaura a TTY antes de qualquer saída
cleanup
exec 3<&-

# Marca flag (lido pelo seu serviço principal depois)
if [ "$pressed" -eq 1 ]; then
  echo 1 > /home/umsxpi/f10-pressed.flag
else
  echo 0 > /home/umsxpi/f10-pressed.flag
fi

exit 0

