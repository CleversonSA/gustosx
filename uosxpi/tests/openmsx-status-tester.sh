#! /bin/bash

timeout 30 ../openmsx-profiles/default.system.sh &
sleep 10
../openmsx-setstring.py --command 0xF0 --message ""
sleep 5
../openmsx-setstring.py --command 0xF0 --message "Aguarde, iniciando copia do SD para o HD..."
sleep 2
../openmsx-setstring.py --command 0xF0 --message "Copiando SD para o HD virtual...25%"
sleep 2
../openmsx-setstring.py --command 0xF0 --message "Copiando SD para o HD virtual...50%"
sleep 2
../openmsx-setstring.py --command 0xF0 --message "Copiando SD para o HD virtual...75%"
sleep 2
../openmsx-setstring.py --command 0xF0 --message "Copiando SD para o HD virtual...99%"
sleep 2
../openmsx-setstring.py --command 0xFF --message "Completado, aguarde o reinicio..."
sleep 2
exit 0

