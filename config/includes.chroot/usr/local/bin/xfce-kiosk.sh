#!/bin/bash

# =====================================================
# Autosuficiencia
# =====================================================
export HOME="${HOME:-/home/gustosx}"
export USER="${USER:-gustosx}"
export PATH="${PATH}:/opt/openMSX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

for i in $(seq 1 120); do
   pgrep xfdesktop >/dev/null && break
   sleep 1
done

for i in $(seq 1 120); do
   xfconf-query -c xfce4-desktop -l  >/dev/null 2>&1 && break
   sleep 1
done

xfce4-panel --quit >/dev/null 2>&1 || true

xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0 --create -t int
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s false --create -t bool
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s false --create -t bool
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s false --create -t bool

xfdesktop --reload >/dev/null 2>&1 || true

