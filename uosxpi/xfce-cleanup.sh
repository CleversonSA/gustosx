#!/bin/bash

# =====================================================
# Autosuficiencia
# =====================================================
export HOME="${HOME:-/home/user}"
export USER="${USER:-user}"
export PATH="${PATH}:/opt/openMSX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

sleep 2
xfce4-panel --quit >/dev/null 2>&1 || true
xfdesktop --reload >/dev/null 2>&1 || true
