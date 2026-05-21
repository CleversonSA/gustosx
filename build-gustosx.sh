#! /bin/bash
#

rm -rf config/includes.chroot/etc/skel/MSX
mkdir -p config/includes.chroot/opt/uosxpi
mkdir -p config/includes.chroot/opt/uosxpi/hd
mkdir -p config/includes.chroot/mnt/storage1
mkdir -p config/includes.chroot/mnt/storage2
mkdir -p config/includes.chroot/mnt/msxhd

cp -r msx/hd.dsk config/includes.chroot/opt/uosxpi/hd
cp -r ./uosxpi config/includes.chroot/opt/
rm -rf config/includes.chroot/opt/uosxpi/.git

rm -rf config/includes.chroot/etc/skel/.cache
rm -rf config/includes.chroot/etc/skel/.local/share/Trash
rm -rf config/includes.chroot/etc/skel/.bash_history
rm -rf config/includes.chroot/etc/skel/.sudo_as_admin_successful
rm -rf config/includes.chroot/etc/skel/.mozilla

echo "# ~/.bash_profile" > config/includes.chroot/etc/skel/.bash_profile
echo 'export UOSXPI_DIR=/opt/uosxpi' >> config/includes.chroot/etc/skel/.bash_profile
echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> config/includes.chroot/etc/skel/.bash_profile

echo 'export UOSXPI_DIR=/opt/uosxpi' >> config/includes.chroot/etc/skel/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> config/includes.chroot/etc/skel/.bashrc
echo 'export PATH=${PATH}:/opt/openMSX/bin' >> config/includes.chroot/etc/skel/.bashrc

mkdir -p config/includes.chroot/opt/openMSX
cp -r ./openmsx.binary.x86/* config/includes.chroot/opt/openMSX
cp ./openmsx.extensions/nextor.xml config/includes.chroot/opt/openMSX/share/extensions
rm -f config/includes.chroot/opt/openMSX/share/systemroms/*.rom

mkdir -p config/includes.chroot/usr/local/lib/
rsync -aHAX gcc13.binary.x86/gcc/ config/includes.chroot/usr/local/lib/gcc/
cp gcc13.binary.x86/libstdc++.so.6.0.32* config/includes.chroot/usr/local/lib/
cp -a gcc13.binary.x86/libstdc++.so.6 config/includes.chroot/usr/local/lib

mkdir -p config/includes.chroot/etc/ld.so.conf.d
echo "/usr/local/lib/gcc/i686-pc-linux-gnu/" > config/includes.chroot/etc/ld.so.conf.d/gcc-13.conf

sed -i 's|/home/user|/home/gustosx|g' config/includes.chroot/opt/uosxpi/startup.sh
sed -i 's|~/MSX|/opt/uosxpi/hd|g' config/includes.chroot/opt/openMSX/share/extensions/nextor.xml


cp ./uosxpi/background/background.png config/includes.chroot/usr/share/plymouth/themes/uosxpi/background.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-teal.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-verticals.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-blue.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-flower.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-leaves.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-shapes.png
cp ./uosxpi/background/background.png config/includes.chroot/usr/share/backgrounds/xfce/xfce-stripes.png
