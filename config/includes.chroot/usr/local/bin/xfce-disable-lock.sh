#!/bin/bash

# =====================================================
# Autosuficiencia
# =====================================================
export HOME="${HOME:-/home/gustosx}"
export USER="${USER:-gustosx}"
export PATH="${PATH}:/opt/openMSX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export UOSXPI_DIR="${UOSXPI_DIR:-/opt/uosxpi}"
export LD_LIBRARY_PATH=/usr/local/lib


for i in $(seq 1 120); do
   xfconf-query -c xfce4-session -l  >/dev/null 2>&1 && break
   sleep 1
done


pkill light-locker 2>/dev/null || true
pkill xfce4-screensaver 2>/dev/null || true

xfconf-query -c xfce4-session -p /general/LockCommand -s "" --create -t string
xfconf-query -c xfce4-session -p /general/LockScreen -s false --create -t bool

xset s off
xset -dpms
xset s noblank

