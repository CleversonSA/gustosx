#! /bin/bash

# ============================================
# Automation to simulate a disk insertion into
# emulator.
#
# This program will check these folders:
# 
# /mnt/storage1
# /mnt/storage2
#
# The first diska folder or dsk file found in 
# these storages, will be mounted.
#
# If a diska.dsk file and a diska folder is 
# present, the DSK file will have the priority.
#
# Same with hda.dsk file and a hda folder.
#
# =============================================
#
#  @Author: Cleverson S A

SOCKET_PATH="/tmp/openmsx-"${USER}
# Check if disquette is already mounted
DISKA_MOUNTED=`./openmsx-disk-mount.py --check-mounted-storage diska --dir ${SOCKET_PATH}`

# Check for lost link or unmounted devices
if [ "${DISKA_MOUNTED}" == "true" ]; then

   LAST_MOUNT_FILE_LONG=`./openmsx-disk-mount.py --check-mounted-storage diska --get-storage-info --dir ${SOCKET_PATH} | awk -F '{' '{ print $2 }' | awk -F '}' '{ print $1 }' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`

   LAST_MOUNT_FILE_SHORT=`./openmsx-disk-mount.py --check-mounted-storage diska --get-storage-info --dir ${SOCKET_PATH} | awk -F ':' '{ print $2 }' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`

   if [ -z "${LAST_MOUNT_FILE_LONG}" ]; then
   	LAST_MOUNT_FILE="${LAST_MOUNT_FILE_SHORT}"
   else
	LAST_MOUNT_FILE="${LAST_MOUNT_FILE_LONG}"
   fi

   
   LAST_MOUNT_DIR=`./openmsx-disk-mount.py --check-mounted-storage diska --get-storage-info --dir ${SOCKET_PATH} | grep "dirasdisk" | awk -F ':' '{ print $2 }' | awk -F ' ' '{ print $1 }'`

   if [ -z "${LAST_MOUNT_DIR}" ]; then
      LAST_MOUNT=${LAST_MOUNT_FILE}
   else
      LAST_MOUNT=${LAST_MOUNT_DIR}
   fi

   if [ "$LAST_MOUNT" == "" ]; then
	#If nothing is mounted
	echo "No mounted disks, exiting..."
   elif [ -d "$LAST_MOUNT" ]; then
	#Dir as disk
	echo "Mount ok..."
   elif [ -e "$LAST_MOUNT" ]; then
     # Mounted, do nothing
     echo "Mount ok..."
   else
     echo "Last mount ${LAST_MOUNT} was not available, unmounting..."
     ./openmsx-disk-umount.py --drive a --dir ${SOCKET_PATH}
     exit 0
   fi
fi

# Find the possible first dsk file
DISKA_FILE_FOUND=`find /mnt -maxdepth 2 -iname "diska.dsk" | head -n 1`

# Find the possible first diska dir
DISKA_DIR_FOUND=`find /mnt -maxdepth 2 -type d -iname "diska" | head -n 1`

# Find the possible first hda dsk file
HDA_FILE_FOUND=`find /mnt -maxdepth 2 -iname "hda.dsk" | head -n 1`

# Find the possible first hda dir
HDA_DIR_FOUND=`find /mnt -maxdepth 2 -type d -iname "hda" | head -n 1`


# Unmount drive
if [[ -n "${DISKA_FILE_FOUND}" || -n "${DISKA_DIR_FOUND}" ]]; then

    # Try avoid unmount the same dsk or dir with the same mountpount
    
    MOUNT_FILE_CHECK=`./openmsx-disk-mount.py --check-mounted-storage diska --with-storage ${DISKA_FILE_FOUND} --dir ${SOCKET_PATH} 2>/dev/null`
    MOUNT_DIR_CHECK=`./openmsx-disk-mount.py --check-mounted-storage diska --with-storage ${DISKA_DIR_FOUND} --dir ${SOCKET_PATH} 2>/dev/null`

    if [[ -n "${DISKA_FILE_FOUND}" && ${MOUNT_FILE_CHECK} == "true" ]]; then
       echo "Already mounted"
       exit 0
    fi

    if [[ -n "${DISKA_DIR_FOUND}" && ${MOUNT_DIR_CHECK} == "true" ]]; then
       echo "Already mounted"
       exit 0
    fi

    ./openmsx-disk-umount.py --drive a --dir ${SOCKET_PATH}

fi


# If there is a DSK file, mount it first
if [ -n "${DISKA_FILE_FOUND}" ]; then
  
  ./openmsx-disk-mount.py --drive a --disk-path ${DISKA_FILE_FOUND} --dir ${SOCKET_PATH}
  exit 0

fi

# If there is a DISK FOLDER, mount it
if [ -n "${DISKA_DIR_FOUND}" ]; then
  
  ./openmsx-disk-mount.py --drive a --disk-path ${DISKA_DIR_FOUND} --dir ${SOCKET_PATH}
  exit 0

fi

exit 0
