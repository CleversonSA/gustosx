#! /bin/bash
# ========================================
# Starts GUI with wayland
#
# Author: Cleverson S A
# ========================================

# Check for a bug when RPi is started and no mouse
# or neither keyboard has found, avoiding stop the
# wayland load and user waits forever for nothing.
#
# Of course, when OpenMSX is started and a later keyboard
# is puggled, the Console menu will not operate properly
# but MSX image will be usable with no problem
#
#
/usr/bin/wayfire -c /home/umsxpi/.config/wayfire.ini

LIBINPUT_ERROR=`journalctl -b | grep "wayland" -A2 | grep "no input device"`

if [ ! "${LIBINPUT_ERROR}" == "" ]; then

   export WLR_LIBINPUT_NO_DEVICES=1
   /usr/bin/wayfire -c /home/umsxpi/.config/wayfire.ini

fi

exit 0
