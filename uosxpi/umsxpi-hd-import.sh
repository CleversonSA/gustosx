#! /bin/bash
# =============================================================
# SINCRONIZADOR DR AQUIVOS ENTRE STORAGES E O HD VIRTUAL DO MSX
# VISTO QUE O OPENMSX NÃO MANIPULA DIRETO OS DISPOSITIVOS
#
# Author: Cleverson SA
# =============================================================


# =============================================================
# GLOBAIS
# =============================================================
STORAGE_SRC=""
FILE_LIST="/tmp/file.list"
MSX_MSG_CMD="0xF0"
MSX_END_CMD="0xFF"
MSX_HD_DIR="/mnt/msxhd"
SOCKET_FILE="/tmp/openmsx-"${USER}
OPENMSX_SETSTRING_CMD="./openmsx-setstring.py --dir "${SOCKET_FILE}
OPENMSX_SHUTDOWN_CMD="./openmsx-shutdown.py --dir "${SOCKET_FILE}

# =============================================================
# --- PARSE ARGS ---
# =============================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --src)
            STORAGE_SRC="$2"
            shift 2
        ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
        ;;
    esac
done

# --- VALIDATIONS ---
if [[ -z "$STORAGE_SRC" ]]; then
    echo "Usage: $0 --src <source_dir> "
    exit 1
fi

if [[ ! -d "$STORAGE_SRC" ]]; then
    echo "Source directory not found: $STORAGE_SRC"
    exit 1
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

  sudo mount ${MSX_HD_DIR}

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
./dir-compare.sh --src ${STORAGE_SRC} --dst ${MSX_HD_DIR} --noSrcDirSuffix >${FILE_LIST}

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
${OPENMSX_SETSTRING_CMD} --command ${MSX_MSG_CMD} --message "Novos arquivos encontrados!"
sleep 2
${OPENMSX_SETSTRING_CMD} --command ${MSX_MSG_CMD} --message "Iniciando copia, aguarde..."
./dir-copy.sh \
	--filelist ${FILE_LIST} \
       	--src ${STORAGE_SRC} \
       	--dst ${MSX_HD_DIR} \
       	--command './openmsx-setstring.py --dir '${SOCKET_FILE}' --command '${MSX_MSG_CMD}' --message "Copiando para o HD virtual..."' \
	--command-ins-spa './openmsx-setstring.py --dir '${SOCKET_FILE}' --command '${MSX_END_CMD}' --message "HD virtual do MSX sem espaço para tanto arquivo! Reduza a quantidade e tente novamente!"' \
	--command-finish './openmsx-setstring.py --dir '${SOCKET_FILE}' --command '${MSX_END_CMD}' --message "Copia concluída, aguarde início do emulador"' >~/dir-copy.stdout 2>~/dir-copy.stderr
	

sleep 5
${OPENMSX_SHUTDOWN_CMD}

sudo umount ${MSX_HD_DIR}
exit 0
