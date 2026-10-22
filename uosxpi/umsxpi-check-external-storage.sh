#! /bin/bash
#=================================================
#
#   Check for unplugged and mounted storages, leading
#   kernel to understand that a file yet exists, but
#   not a real one.
#
#   Author: Cleverson S A
#
#=================================================

SOCKET_PATH="/tmp/openmsx-"${USER}

# Pool de pontos de montagem
STORAGES=(
    "/mnt/storage1"
    "/mnt/storage2"
    "/mnt/storage3"
)

for CANDIDATE_DIR in ${STORAGES[@]}; do

	# Check for devices on monitored folders
	STORAGE=`lsblk | grep ${CANDIDATE_DIR}`

	# Verify if the monitored folders are actually mountpoints
	# even unplugged
	MOUNTPOINT=`mountpoint ${CANDIDATE_DIR} | grep "is a mountpoint"`

	# So let's check if a mountpoint is actually mounted or
	# lost link
	if [[ "${STORAGE}" == "" && "${MOUNTPOINT}" != "" ]]; then
	
  		echo "${MOUNTPOINT} link was lost!"
  		./openmsx-disk-umount.py --drive a --dir ${SOCKET_PATH}
  		sudo umount ${CANDIDATE_DIR}

	fi

done

# Reinfoces refresh mount points
sudo mount -a

exit 0

