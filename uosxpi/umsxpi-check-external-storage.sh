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
# Check for devices on monitored folders
STORAGE1=`lsblk | grep /mnt/storage1`
STORAGE2=`lsblk | grep /mnt/storage2`

# Verify if the monitored folders are actually mountpoints
# even unplugged
MOUNTPOINT1=`mountpoint /mnt/storage1 | grep "is a mountpoint"`
MOUNTPOINT2=`mountpoint /mnt/storage2 | grep "is a mountpoint"`

# So let's check if a mountpoint is actually mounted or
# lost link
if [[ "${STORAGE1}" == "" && "${MOUNTPOINT1}" != "" ]]; then
	
  echo "${MOUNTPOINT1} link was lost!"
  ./openmsx-disk-umount.py --drive a --dir ${SOCKET_PATH}
  sudo umount /mnt/storage1

fi

if [[ "${STORAGE2}" == "" && "${MOUNTPOINT2}" != "" ]]; then
	
  echo "${MOUNTPOINT2} link was lost!"
  ./openmsx-disk-umount.py --drive a --dir ${SOCKET_PATH}
  sudo umount /mnt/storage2

fi

# Reinfoces refresh mount points
sudo mount -a

exit 0

