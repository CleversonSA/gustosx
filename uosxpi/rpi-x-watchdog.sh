#! /bin/bash
if [ -e /boot/firmware/.stopwatchdog ]; then
  exit 0
fi

# =====================================================
# Globals
# =====================================================
STORAGE_DIR=""
STORAGES_DIR=(
	"/mnt/storage1"
	"/mnt/storage2"
	"/mnt/storage3"
)
MAGIC_EXPORT_DIR="/msxhd"
export USER="${USER:-gustosx}"

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
# MAIN LOOP
# =====================================================
sleep 10
while [ 1 == 1  ];
do
    PROCESS_CMD=`ps -ef | grep openmsx | grep -v "grep"`
    /bin/sleep 1
    if [ "$PROCESS_CMD" == "" ]; then
	
	# =====================================================
	# DELETE OLD TEMP FILES
	# =====================================================
	sudo rm -f /tmp/openmsx-${USER}/*
 	
	# =====================================================
	# COPY PROFILE MACHINES TO STORAGE IF AVAILABLE (ONLY FOR LIVE)
	# =====================================================
	if grep -qw 'gustosx.mode=live' /proc/cmdline; then

		get_external_storage
		EXISTING_MACHINE_PROFILES=$(find "${STORAGE_DIR}/.gustosx/openmsx-profiles" -maxdepth 1 -iname "*.sh")	
		if [ "${EXISTING_MACHINE_PROFILES}" == "" ]; then
	   		sudo mkdir -p ${STORAGE_DIR}/.gustosx/openmsx-profiles
		fi
		sudo cp ${UOSXPI_DIR}/openmsx-profiles/*.sh ${STORAGE_DIR}/.gustosx/openmsx-profiles/
	fi
       
	# =====================================================
	# SHUTDOWN SYSTEM
	# =====================================================
	sudo shutdown -h now
	#pkill -9 wayfire

        exit 0

    fi 

    # ==================================================
    # XFCE Extras
    # ==================================================
    #xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0
 
    # ==================================================
    # Memory listeners
    # ==================================================
    cd ${UOSXPI_DIR}
    ./umsxpi-profile-listener.sh
    cd ${UOSXPI_DIR}
    
    # ==================================================
    # Virtual disk listeners
    # ==================================================
    cd ${UOSXPI_DIR}
    ./umsxpi-check-external-storage.sh
    ./umsxpi-disk-listener.sh
    get_external_storage
    if [ ! "${STORAGE_DIR}" == "" ]; then

    	./umsxpi-dsk-selector-listener.sh --initial-dir ${STORAGE_DIR}

    fi
    cd ${UOSXPI_DIR}
    
    # ==================================================
    # Export trigger
    # ==================================================
    cd ${UOSXPI_DIR}
    get_external_storage
    ./umsxpi-hd-export.sh --dst ${STORAGE_DIR}${MAGIC_EXPORT_DIR} --msxmode
    cd ${UOSXPI_DIR}
    

done
