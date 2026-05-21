#! /bin/bash
if [ -e /boot/firmware/.stopwatchdog ]; then
  exit 0
fi

# =====================================================
# Globals
# =====================================================
STORAGE1_DIR="/mnt/storage1"
STORAGE2_DIR="/mnt/storage2"
STORAGE_DIR=""
MAGIC_EXPORT_DIR="/msxhd"
export USER="${USER:-gustomsx}"

# =====================================================
# Check for mounted storage. storage1 > storage2
# =====================================================
get_external_storage() {
   
   if [ -z "$(ls -A "$STORAGE1_DIR")" ]; then
	STORAGE_DIR=${STORAGE2_DIR}
   else
	STORAGE_DIR=${STORAGE1_DIR}
   fi

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
	# SHUTDOWN SYSTEM
	# =====================================================
	sudo shutdown -h now
	#pkill -9 wayfire

        exit 0

    fi 

    # ==================================================
    # XFCE Extras
    # ==================================================
    xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0
 
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
    ./umsxpi-dsk-selector-listener.sh --initial-dir ${STORAGE_DIR}
    cd ${UOSXPI_DIR}

    # ==================================================
    # Export trigger
    # ==================================================
    cd ${UOSXPI_DIR}
    get_external_storage
    ./umsxpi-hd-export.sh --dst ${STORAGE_DIR}${MAGIC_EXPORT_DIR} --msxmode
    cd ${UOSXPI_DIR}


done
