#! /bin/bash
# =============================================================
# EXPORTA O HD VIRTUAL DO MSX PARA UMA PASTA NO STORAGE
# VISTO QUE O OPENMSX NÃO MANIPULA DIRETO OS DISPOSITIVOS
#
# OBS: A comparacao e feita somente pela existencia do arquivo
#      nao o tamanho, por enquanto
#
# Author: Cleverson SA
# =============================================================


# =============================================================
# GLOBAIS
# =============================================================
STORAGE_DST=""
FILE_LIST="/tmp/file.list"
MSX_MSG_CMD="0xF0"
MSX_END_CMD="0xFF"
MSX_MY_CMD="0xF3"
MSX_MODE=""
MSX_HD_DIR="/mnt/msxhd"
SOCKET_PATH="/tmp/openmsx-"${USER}
OPENMSX_SETSTRING_CMD="./openmsx-setstring.py --dir "${SOCKET_PATH}
OPENMSX_SHUTDOWN_CMD="./openmsx-shutdown.py --dir "${SOCKET_PATH}


# =============================================================
# --- PARSE ARGS ---
# =============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dst)
            STORAGE_DST="$2"
            shift 2
        ;;
	--msxmode)
	    MSX_MODE="ON"
	    shift 1
	;;
        *)
            echo "Unknown parameter: $1"
            exit 1
        ;;
    esac
done

# --- VALIDATIONS ---
if [[ -z "$STORAGE_DST" ]]; then
    echo "Usage: $0 --dst <destination_dir> "
    exit 1
fi

if [[ ! -d "$STORAGE_DST" ]]; then
    echo "Destination directory not found: $STORAGE_DST"
    exit 1
fi


# =============================================================
# VERIFY OPEN MSX MEMORY MAPPING MODE
# =============================================================
if [[ ! -z "${MSX_MODE}" ]]; then
  OPENMSX=`./openmsx-getstring.py --dir ${SOCKET_PATH}`
  COMMAND=`echo ${OPENMSX} | awk '{ print $1 }'`
  PARAMETER=`echo ${OPENMSX} | awk '{ print $2 }'`

  echo "HD EXPORT: ${COMMAND} ${PARAMETER}"

  if [[ "${COMMAND}" != "${MSX_MY_CMD}" ]] && [[ "${PARAMETER}" != "EXPORT" ]]; then
    echo "Not my command..."
    exit 0
  fi
fi


# =============================================================
# SHUTS DOWN CURRENT OPENMSX INSTANCE, IF THERE´S ONE RUNNING
# =============================================================
MSX_MOUNTED_HD=`lsblk | grep ${MSX_HD_DIR}`
if [[ -z "${MSX_MOUNTED_HD}" ]]; then

  PROCESS_CMD=`ps -ef | grep openmsx | grep -v "grep"`
  if [[ ! -z "${PROCESS_CMD}" ]]; then

    ${OPENMSX_SHUTDOWN_CMD}
    sleep 2

  fi

  EXISTING_MSXHD_FILE=$(find "${STORAGE_DIR}/" -maxdepth 1 -iname "hd.dsk")	

  # =====================================================
  # CHECK FOR SD CARD MSX HD
  # =====================================================
  if [ ! "${EXISTING_MSXHD_FILE}" == "" ]; then
    sudo umount /mnt/msxhd
    REPLACE_STR_DISABLE="s|/opt/uosxpi/hd|#"${STORAGE_DIR}"|g"
    REPLACE_STR_ENABLE="s|/opt/uosxpi/hd|"${STORAGE_DIR}"|g"    
    sudo sed -i ${REPLACE_STR_DISABLE} /etc/fstab
    sudo sed -i ${REPLACE_STR_ENABLE} /opt/openMSX/share/extensions/nextor.xml
	   
    sudo systemctl daemon-reload
    sudo mount -a
    sudo mount -o loop,gid=1000,uid=1000,umask=0022 -t auto ${STORAGE_DIR}/hd.dsk /mnt/msxhd
  else
   
    sudo mount ${MSX_HD_DIR}
  
  fi

else

 # Strange if it´s running with a mounted HD...
 # some corruption may happen
 #
 PROCESS_CMD=`ps -ef | grep openmsx | grep -v "grep"`
  if [[ ! -z "${PROCESS_CMD}" ]]; then

    ${OPENMSX_SHUTDOWN_CMD}
    sleep 2

  fi
 
fi

# =============================================================
# COMPARE FILES
# =============================================================
./dir-compare.sh --src ${MSX_HD_DIR} --dst ${STORAGE_DST} --noSrcDirSuffix >${FILE_LIST}

if [[ -z "$(cat ${FILE_LIST})" ]]; then
    echo "No more files to sync, exiting..."
    sudo umount ${MSX_HD_DIR}
    exit 0
fi



# =============================================================
# START SYSTEM´S OPENMSX AND START COPY
# =============================================================
cd ./openmsx-profiles
./default.system.sh &
cd ..
# We are talking about MSX so...slow! So be patient!
sleep 5
${OPENMSX_SETSTRING_CMD} --command ${MSX_MSG_CMD} --message "Exportacao do HD Virtual solicitada!"
sleep 2
${OPENMSX_SETSTRING_CMD} --command ${MSX_MSG_CMD} --message "Iniciando exportacao, aguarde..."
./dir-copy.sh \
	--filelist ${FILE_LIST} \
       	--src ${MSX_HD_DIR} \
       	--dst ${STORAGE_DST} \
       	--command './openmsx-setstring.py --command '${MSX_MSG_CMD}' --message "Copiando do HD virtual para externo..."' \
	--command-ins-spa './openmsx-setstring.py --command '${MSX_END_CMD}' --message "Armazenamento externo sem espaço para tanto arquivo! Revise e tente novamente!"' \
	--command-finish './openmsx-setstring.py --command '${MSX_END_CMD}' --message "Copia concluída, o aparelho sera desligado por seguranca"' >~/dir-copy.stdout 2>~/dir-copy.stderr
	

sleep 5
${OPENMSX_SHUTDOWN_CMD}

sudo umount ${MSX_HD_DIR}
exit 0
