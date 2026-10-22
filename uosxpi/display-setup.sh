#!/bin/sh

OUTPUT=$(xrandr --query | awk '$2 == "connected" {print $1; exit}')

[ -n "$OUTPUT" ] || exit 0

xrandr --output "$OUTPUT" \
	--mode 640x480 \
	--rate 60 \
	--primary

exit 0
