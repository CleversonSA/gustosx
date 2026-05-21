#!/bin/bash

# =====================================================
# Autosuficiencia
# =====================================================
export HOME="${HOME:-/home/gustosx}"
export USER="${USER:-gustosx}"
export PATH="${PATH}:/opt/openMSX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "Phase 1" >~/startup.log
cd /usr/local/bin
./xfce-kiosk.sh

echo "Phase 2" >~/startup.log
./xfce-disable-lock.sh

echo "Phase 3" >~/startup.log
cd /opt/uosxpi
./startup.sh
