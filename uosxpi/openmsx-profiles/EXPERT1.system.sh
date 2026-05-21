#! /bin/bash
WAYLAND_DISPLAY=wayland-1 wlr-randr --output HDMI-A-1 --custom-mode 800x600@60Hz

openmsx \
  -command "set fullscreen on" \
  -command "set scanline 0" \
  -command "set scale_factor 2" \
  -command "set mute off" \
  -command "set blur 0" \
  -command "set auto_enable_reverse off" \
  -machine Gradiente_Expert_GPC-1 \
  -cart ${UOSXPI_DIR}/systemDisk/sysmsga.rom >${UOSXPI_DIR}/openmsx.stdout 2>${UOSXPI_DIR}/openmsx.stderr
 

exit 0
