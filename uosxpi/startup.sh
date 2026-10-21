#! /bin/bash
# For 4 inch lcd
#WAYLAND_DISPLAY=wayland-1 wlr-randr --output HDMI-A-1 --custom-mode 480x800@60Hz --transform=90
# For 3.5 HDMI LCD
WAYLAND_DISPLAY=wayland-1 wlr-randr --output HDMI-A-1 --custom-mode 800x600@60Hz

# =====================================================
# REFORCE ENVIROMENT VARIABLES
# =====================================================
export HOME="${HOME:-/home/gustomsx}"
export USER="${USER:-gustomsx}"
export PATH="${PATH}:/opt/openMSX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export UOSXPI_DIR="${UOSXPI_DIR:-/opt/uosxpi}"
export OPENMSX_DIR="${OPENMSX_DIR:-/opt/openMSX}"
export LD_LIBRARY_PATH=/usr/local/lib
export UOSXPI_DATA_DIR="${HOME}/.uosxpi"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# =====================================================
# PC ONLY - INSTALL
# =====================================================
if grep -qw 'gustosx.mode=install' /proc/cmdline; then
  /usr/bin/install-debian
  sudo reboot
  exit $?
fi

# Novo disco montado, reinicia o emulador, como um cartucho novo em um msx real
# No msx real voce desliga o aparelho antes de inserir o cartucho!		
WATCHDOG_PID=$(ps -ef | grep rpi-x-watchdog | grep -v "grep" | awk '{ print $2 }')
OPENMSX_PID=$(ps -ef | grep openmsx | grep -v "grep" | awk '{ print $2 }')

kill -9 ${WATCHDOG_PID} 2>/dev/null
kill -9 ${OPENMSX_PID} 2>/dev/null
		


# =====================================================
# Audio
# =====================================================
amixer sset Master unmute >/dev/null 2>&1 || true
amixer sset PCM unmute >/dev/null 2>&1 || true
amixer sset Master 80% >/dev/null 2>&1 || true
pactl set-sink-mute @DEFAULT_SINK@ 0 || true
pactl set-sink-volume @DEFAULT_SINK@ 80% || true

# =====================================================
# Globals
# =====================================================
STORAGES_DIR=(
	"/mnt/storage1"
	"/mnt/storage2"
	"/mnt/storage3"
)
STORAGE_DIR=""
MAGIC_MSX_HD_DIR="msxhd"
MAGIC_OPENMSX_STORAGE_DIR="systemroms"
SOCKET_PATH="/tmp/openmsx-"${USER}


# =====================================================
# PRESTARTS MOUNT POINTS
# =====================================================
sudo mount -a
sleep 2

# =====================================================
# Check for mounted first valid storage
# =====================================================
get_external_storage() {
   
   for CANDIDATE_DIR in "${STORAGES_DIR[@]}"; do
	
	if [[ -n $(find "$CANDIDATE_DIR" \
		\( -type d -name "systemroms" -o \
		   -type d -name "msxhd" -o \
		   -type d -name "extensions" -o \
		   -type f -name "hd.dsk" -o \
		   -type f -maxdepth 1 -iname "*.dsk" -o \
		   -type f -maxdepth 1 -iname "*.rom" \) \
		 -print -quit 2>/dev/null) ]]; then
		
		STORAGE_DIR=${CANDIDATE_DIR}
		break
	
	fi
   done	  

}

# =====================================================
# CHECK FOR ROM FILES TO COPY
# =====================================================
get_external_storage
EXISTING_ROM_FILES=$(find "${STORAGE_DIR}/${MAGIC_OPENMSX_STORAGE_DIR}/" -maxdepth 1 -iname "*.rom")	
 
if [ ! "${EXISTING_ROM_FILES}" == "" ]; then
    sudo cp ${STORAGE_DIR}/${MAGIC_OPENMSX_STORAGE_DIR}/*.rom ${OPENMSX_DIR}/share/systemroms/ >/dev/null 2>/dev/null
    sudo cp ${STORAGE_DIR}/${MAGIC_OPENMSX_STORAGE_DIR}/*.ROM ${OPENMSX_DIR}/share/systemroms/ >/dev/null 2>/dev/null
    echo "copiado"
fi
    
# =====================================================
# CHECK FOR PROFILE MACHINES TO COPY
# =====================================================
EXISTING_MACHINE_PROFILES=$(find "${STORAGE_DIR}/.gustosx/openmsx-profiles" -maxdepth 1 -iname "*.sh")	
if [ ! "${EXISTING_MACHINE_PROFILES}" == "" ]; then
   sudo cp ${STORAGE_DIR}/.gustosx/openmsx-profiles/*.sh ${UOSXPI_DIR}/openmsx-profiles
fi


# =====================================================
# CORE
# =====================================================

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorLVDS1/workspace0/last-image -s ${UOSXPI_DIR}/background/background.png

# =====================================================
# FORCE INITIAL REFRESH ON STORAGE DIR IF IS AUTOMOUNTED
# =====================================================
cd ${UOSXPI_DIR}	
./dir-select.sh --refresh --dskDir ${STORAGE_DIR}
	
cd ${UOSXPI_DIR}/openmsx-profiles/

EXISTING_OPENMSXROM_FILES=$(find "${OPENMSX_DIR}/share/systemroms" -maxdepth 1 -iname "*.rom")	
EXISTING_MSXHD_FILE=$(find "${STORAGE_DIR}/" -maxdepth 1 -iname "hd.dsk")	

if [ ! "${EXISTING_OPENMSXROM_FILES}" == "" ]; then
	
	# =====================================================
	# CHECK FOR SD CARD MSX HD (ONLY ON LIVE MODE)
	# =====================================================
	if grep -qw 'gustosx.mode=live' /proc/cmdline; then
 
		if [ ! "${EXISTING_MSXHD_FILE}" == "" ]; then
	   		sudo umount /mnt/msxhd
	   		REPLACE_STR_DISABLE="s|/opt/uosxpi/hd|#"${STORAGE_DIR}"|g"
	   		REPLACE_STR_ENABLE="s|/opt/uosxpi/hd|"${STORAGE_DIR}"|g"   
	   		sudo sed -i ${REPLACE_STR_DISABLE} /etc/fstab
	   		sudo sed -i ${REPLACE_STR_ENABLE} /opt/openMSX/share/extensions/nextor.xml
	   
	   		sudo systemctl daemon-reload
 	   		sudo mount -a
	   		sudo mount -o loop,gid=1000,uid=1000,umask=0022 -t auto ${STORAGE_DIR}/hd.dsk /mnt/msxhd
		fi

	elif grep -qw 'gustosx.mode=install' /proc/cmdline; then

		# Do nothing
		#
		echo "Nothing to do"
	
	else

	   	mkdir -p ${UOSXPI_DATA_DIR}/hd >/dev/null 2>/dev/null
		if [ ! -e ${UOSXPI_DATA_DIR}/hd/hd.dsk ]; then
			  
		  sudo cp ${UOSXPI_DIR}/hd/hd.dsk ${UOSXPI_DATA_DIR}/hd

		fi
		
		REPLACE_STR_ENABLE="s|/opt/uosxpi/hd|"${UOSXPI_DATA_DIR}"/hd|g"   
	   	sudo sed -i ${REPLACE_STR_ENABLE} /opt/openMSX/share/extensions/nextor.xml
		sudo chown gustosx:gustosx ${UOSXPI_DATA_DIR}/hd/hd.dsk

			
		sudo umount /mnt/msxhd
	   	sudo mount -o loop,gid=1000,uid=1000,umask=0022 -t auto ${UOSXPI_DATA_DIR}/hd/hd.dsk /mnt/msxhd
	fi

	# =====================================================
	# CHECK FOR FILES TO COPY
	# =====================================================
	cd ${UOSXPI_DIR}
	./umsxpi-hd-import.sh --src ${STORAGE_DIR}/${MAGIC_MSX_HD_DIR}
	
	# =====================================================
	# REMOVE TEMP FILES
	# =====================================================
	sudo rm -f /tmp/openmsx-${USER}/*
	
	# =====================================================
	# START DEFAULT PROFILE
	# =====================================================
	cd ${UOSXPI_DIR}/openmsx-profiles/
     	./default.sh &

else 
	# =====================================================
	# REMOVE TEMP FILES
	# =====================================================
	sudo rm -f /tmp/openmsx-${USER}/*
	
	# =====================================================
	# START CBIOS DEFAULT
	# =====================================================
  	cd ${UOSXPI_DIR}/openmsx-profiles/
	./default.cbios.sh &

fi

cd ${UOSXPI_DIR}
# Wait a little for OpenMSX start
for i in $(seq 1 30); do
  pgrep openmsx >/dev/null && break
  sleep 1
done

# Wait for online socket
for i in $(seq 1 60); do
  ls ${SOCKET_PATH}/socket.* >/dev/null 2>/dev/null && break
  sleep 1
done
echo "Socket is present"

./openmsx-start-binds.py --dir ${SOCKET_PATH}
./rpi-x-watchdog.sh &
UOSXPI_PID=$!


# =========================================================
# LIVES WHILE OPENMSX IS ALIVE BECAUSE SYSTEMD
# =========================================================
wait "$UOSXPI_PID"
