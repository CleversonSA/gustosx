#!/bin/bash

if [ "$1" == "" ]; then
   echo "Informe uma versão (ex: 1.0.0)"
   exit -1
fi

lb clean
./build-image.sh
./build-gustosx.sh
lb build
mv live-image-i386.hybrid.iso gustosx-live-$1.iso
rm -f live-image*
rm -f ./dist/*
mv gustosx-live-$1.iso ./dist
rm -rf config/includes.chroot/opt/openMSX
rm -rf config/includes.chroot/opt/uosxpi
rm -rf config/includes.chroot/usr/local/lib/*
