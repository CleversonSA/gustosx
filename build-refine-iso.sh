#!/bin/bash

xorriso -dev gustomsx-live-$1.iso \
	-map ./config/includes.chroot/etc/xdg/autostart/uosxpi.desktop \
       /etc/xdg/autostart/uosxpi.desktop \
	-commit -boot_image "any" "keep"       
