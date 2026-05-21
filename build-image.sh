#!/bin/bash

sudo lb config \
	--iso-application "GustoSX" \
	--iso-publisher "CleversonSA" \
	--iso-volume "GUSTOSX" \
	--distribution bookworm \
	--parent-distribution bookworm \
	--parent-debian-installer-distribution bookworm \
	--architecture i386 \
	--bootloader grub-pc \
	--binary-images iso-hybrid \
	--debian-installer false\
	--archive-areas "main contrib non-free non-free-firmware" \
	--system live
