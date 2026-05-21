#! /bin/bash
#--------------------------------------------------------------------
#
# DSK Selector to imitate GoTek functionality inside OpenMSX
#
# @Author: CleversonSA
# -------------------------------------------------------------------

# -------------------------------------------
# GLOBAL VARIABLES
# -------------------------------------------
STORAGE1_DIR="/mnt/storage1"
STORAGE2_DIR="/mnt/storage2"
STORAGE_DIR=""
INTERNAL_DSK=${UOSXPI_DIR}'/diskA'
SOCKET_PATH="/tmp/openmsx-"${USER}
OPENMSX_READ_MEM_CMD=`./openmsx-getstring.py --dir ${SOCKET_PATH}`
DSK_SELECT_CMD='./dsk-select.sh'
DIR_SELECT_CMD='./dir-select.sh'
OPENMSX_MESSAGE_STATUS_CMD='./openmsx-send-message.py --dir '${SOCKET_PATH}
OPENMSX_DISK_MOUNT_CMD='./openmsx-disk-mount.py --dir '${SOCKET_PATH}
OPENMSX_DISK_UMOUNT_CMD='./openmsx-disk-umount.py --dir '${SOCKET_PATH}
OPENMSX_SET_MESSAGE_CMD='./openmsx-setstring.py --dir '${SOCKET_PATH}
LAST_SELECTED_FOLDER_FILE='/tmp/umsxpi-last-selected-folder.info'


# -------------------------------------------
# OPENMSX COMMAND READ INTEGRATION
# -------------------------------------------
COMMAND=`echo ${OPENMSX_READ_MEM_CMD} | awk '{ print $1 }'`
ACTION=`echo ${OPENMSX_READ_MEM_CMD} | awk '{ print $2 }'`

# -------------------------------------------
# ARGS PARSER
# -------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      CLI_ACTION="$2"; shift 2;;
    --initial-dir)
      INITIAL_DIR="$2"; shift 2;;
    *)
      # Allow passing through unknown args (ignored) to keep compatibility
      shift;;
  esac
done

if [[ -z "$INITIAL_DIR" ]]; then
  echo "ERROR: --initial-dir required"
  exit 2
fi

if [[ ! -e "${LAST_SELECTED_FOLDER_FILE}" ]]; then
  LAST_SELECTED_FOLDER=${INITIAL_DIR}
else
  LAST_SELECTED_FOLDER=`cat ${LAST_SELECTED_FOLDER_FILE}`
fi

# -------------------------------------------
# HELPERS
# -------------------------------------------
select_internal_dsk() {

  ${OPENMSX_DISK_UMOUNT_CMD} --drive a 
  ${OPENMSX_DISK_MOUNT_CMD} --drive a --disk-path "${INTERNAL_DSK}" --debug 

  exit 0
}

select_dsk() {
  if [[ "${CURRENT_FILE}" == "" ]]; then
     ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) NO DSK to select!" 
    echo "empty"
    exit 0
  fi


  if [[ ! -e "${CURRENT_FILE}" ]]; then
    ${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --refresh >/dev/null 2>/dev/null
    ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Error: no more valid dsk!"
    echo "empty"
    exit 0
  fi

  echo ${CURRENT_FILE}
  ${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --refresh >/dev/null 2>/dev/null
  ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) DSK SELECTED: ${CURRENT_FILE}"

  ${OPENMSX_DISK_UMOUNT_CMD} --drive a 
  ${OPENMSX_DISK_MOUNT_CMD} --drive a --disk-path "${CURRENT_FILE}" --debug 
  exit 0
}


select_folder() {
  if [[ "${CURRENT_DIR}" == "" ]]; then
     ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) NO FOLDER to select!" 
    echo "empty"
    exit 0
  fi


  if [[ ! -d "${CURRENT_DIR}" ]]; then
    ${DIR_SELECT_CMD} --dskDir ${CURRENT_DIR} --refresh >/dev/null 2>/dev/null
    ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Error: no more valid folder!"
    echo "empty"
    exit 0
  fi

  echo ${CURRENT_DIR}
  ${DSK_SELECT_CMD} --dskDir ${CURRENT_DIR} --refresh >/dev/null 2>/dev/null
  ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) FOLDER SELECTED: ${CURRENT_DIR}"

  echo ${CURRENT_DIR} > ${LAST_SELECTED_FOLDER_FILE}
  exit 0
}

check_folder() {
  if [[ "${CURRENT_DIR}" == "" ]]; then
     ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) NO FOLDER to select!" 
    echo "empty"
    exit 0
  fi

  if [[ "${CURRENT_DIR}" == "(root)" ]]; then
    ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Current folder: (ROOT)"
    echo "(root)"
    ${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --refresh >/dev/null 2>/dev/null
    ${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --root >/dev/null 2>/dev/null

    exit 0
  fi

  if [[ ! -d "${INITIAL_DIR}/${CURRENT_DIR}" ]]; then
    ${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --refresh >/dev/null 2>/dev/null
    ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Error: no more valid folder!"
    echo "empty"
    exit 0
  fi


}

check_file() {
  if [[ "${CURRENT_FILE}" == "" ]]; then
     ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) NO DSK File  to select!" 
    echo "empty"
    exit 0
  fi


  if [[ ! -e "${LAST_SELECTED_FOLDER}/${CURRENT_FILE}" ]]; then
    ${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --refresh >/dev/null 2>/dev/null
    ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Error: no more valid dsk file!"
    echo "empty"
    exit 0
  fi

}


show_folder_status() {
  echo ${CURRENT_DIR}
  ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Current Folder: ${CURRENT_DIR}"
}

show_dsk_status() {
  echo ${CURRENT_FILE}
  ${OPENMSX_MESSAGE_STATUS_CMD} --message "(DISK SELECTOR) Current DSK FILE: ${CURRENT_FILE}"
}

clear_shared_mem() {
  ${OPENMSX_SET_MESSAGE_CMD} --command 0xF0
}



# -------------------------------------------
# ACTION SELECTOR
# -------------------------------------------

if [[ ! -z "$CLI_ACTION" ]]; then
  ACTION=${CLI_ACTION}
  COMMAND="0xF2"
fi

if [ "${COMMAND}" != "0xF2" ]; then
  echo "Not my command..."
  exit 0
fi


case "${ACTION}" in
  
   "DIRFIRST")   
     	${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --root >/dev/null 2>/dev/null
	CURRENT_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --current`

	clear_shared_mem
	check_folder    
	show_folder_status
	exit 0
	;;

   "DIRPREVIOUS")
       	${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --previous >/dev/null 2>/dev/null
	CURRENT_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --current`

	clear_shared_mem
	check_folder    
	show_folder_status
	exit 0
      ;;

    "DIRNEXT")
	LAST_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --current`
	if [[ "$LAST_DIR" == "(root)" ]]; then
	   ${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --first >/dev/null 2>/dev/null
	else
       	   ${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --next >/dev/null 2>/dev/null
	fi

	CURRENT_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --current`

	clear_shared_mem
	check_folder    
	show_folder_status
	exit 0
 	;;        

    "DIRLAST")
       	${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --last >/dev/null 2>/dev/null
	CURRENT_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --current`

	clear_shared_mem
	check_folder    
	show_folder_status
	exit 0
      ;;

    "DIRSELECT")
      	CURRENT_DIR=`${DIR_SELECT_CMD} --dskDir ${INITIAL_DIR} --select`

	clear_shared_mem
	select_folder
	exit 0
	;;


    "DSKFIRST")
    	${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --first >/dev/null 2>/dev/null
	CURRENT_FILE=`${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --current`

	clear_shared_mem
	check_file
	show_dsk_status
	exit 0
    
	;;

    "DSKPREVIOUS")
     	${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --previous >/dev/null 2>/dev/null
	CURRENT_FILE=`${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --current`

	clear_shared_mem
	check_file
	show_dsk_status
	exit 0
      ;;

    "DSKNEXT")
     	${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --next >/dev/null 2>/dev/null
	CURRENT_FILE=`${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --current`

	clear_shared_mem
	check_file
	show_dsk_status
	exit 0
      ;;

    "DSKLAST")
       	${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --last >/dev/null 2>/dev/null
	CURRENT_FILE=`${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --current`

	clear_shared_mem
	check_file
	show_dsk_status
	exit 0
	;;

    "DSKSELECT")
       	CURRENT_FILE=`${DSK_SELECT_CMD} --dskDir "${LAST_SELECTED_FOLDER}" --select`

	clear_shared_mem
	select_dsk
	exit 0
	;;

    "DSKEJECT")
	${OPENMSX_DISK_UMOUNT_CMD} --drive a >/dev/null 2>/dev/null
	clear_shared_mem
	exit 0
	;;

    "DSKINTERNAL")
	clear_shared_mem
	select_internal_dsk
	exit 0
	;;


    *)
      ;;

 esac


