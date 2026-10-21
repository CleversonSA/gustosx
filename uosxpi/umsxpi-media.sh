#!/bin/bash
# Desabilita erros
#set -euo pipefail
#set -euxo pipefail

ACTION="${1:?}"
DEVICE_NAME="${2:?}"

# Aceitar somente nomes de dispositivos esperados
[[ "$DEVICE_NAME" =~ ^(sd[a-z]+[0-9]*|mmcblk[0-9]+(p[0-9]+)?)$ ]] || exit 0

DEVICE="/dev/$DEVICE_NAME"

# Pool de pontos de montagem
STORAGE=(
    "/mnt/storage1"
    "/mnt/storage2"
    "/mnt/storage3"
)

# Lock para eventos simultaneos do udev
LOCK="/run/lock/gustosx-media.lock"

# =====================================================
# ONLY AFTER INSTALLED MODE
# =====================================================
if grep -qw 'gustosx.mode=live' /proc/cmdline; then
   
   echo "Live not supported"
   exit 0 

elif grep -qw 'gustosx.mode=install' /proc/cmdline; then

   echo "Install not supported"
   exit 0

fi

# =====================================================
# IGNORE INSTALLED PARTITIONS
# =====================================================
is_system_partition() {
    local candidate="$1"
    local root_dev
    local root_disk
    local candidate_disk

    # Localiza a partição raiz do sistema
    root_dev=$(findmnt -nro SOURCE -M /) || return 1

    # Resolve links simbólicos, se existirem
    [[ "$root_dev" == /dev/* ]] || return 1
    root_dev=$(readlink -f -- "$root_dev") || return 1

    # Descobre o disco físico da raiz
    root_disk=$(lsblk -dnro PKNAME "$root_dev" 2>/dev/null)

    # Descobre o disco físico da partição detectada
    candidate_disk=$(lsblk -dnro PKNAME "$candidate" 2>/dev/null)

    # Ignora dispositivos sem identificação válida
    [[ -n "$root_disk" && -n "$candidate_disk" ]] || return 1

    # Ambos pertencem ao mesmo disco?
    [[ "$root_disk" == "$candidate_disk" ]]
}


case "$ACTION" in

    add)
        [[ -b "$DEVICE" ]] || exit 0

        # Identificar disco pai
        PARENT=$(lsblk -dnro PKNAME "$DEVICE" | head -n 1)
        [[ -n "$PARENT" ]] || PARENT="$DEVICE_NAME"

        # Identificar barramento
        TRAN=$(lsblk -dnro TRAN "/dev/$PARENT" || true)

        if [[ "$TRAN" != "usb" ]]; then

            # Aceitar apenas cartoes SD reais.
            # Excluir armazenamento eMMC interno.
            [[ "$PARENT" == mmcblk* ]] || exit 0

            CARD_TYPE=$(cat \
                "/sys/class/block/$PARENT/device/type" \
                2>/dev/null || true)

            [[ "$CARD_TYPE" == "SD" ]] || exit 0
        fi

        # Permitir apenas filesystems conhecidos
        FSTYPE=$(blkid -s TYPE -o value "$DEVICE" || true)

        case "$FSTYPE" in
            vfat|exfat|ntfs|ext2|ext3|ext4) ;;
            *) exit 0 ;;
        esac

 	# Bloqueia alocacoes simultaneas
	exec 9>"$LOCK"
	flock -x 9

	# Nao montar um dispositivo que ja esteja montado
	if findmnt -rn -S "$DEVICE" >/dev/null; then
    		logger -t gustosx-media \
        	"$DEVICE ja esta montado"
    		exit 0
	fi

	MOUNT=""

	# Localizar primeiro storage disponivel
	for DIR in "${STORAGE[@]}"; do

    		mkdir -p "$DIR"

    		if ! findmnt -rn -M "$DIR" >/dev/null; then
        		MOUNT="$DIR"
        		break
    		fi

	done

	# Nenhum storage disponivel
	if [[ -z "$MOUNT" ]]; then
    		logger -t gustosx-media \
        		"Nenhum storage disponivel para $DEVICE"
    		exit 0
	fi

	# Montar a particao
	USER_UID=$(id -u gustosx)
	USER_GID=$(id -g gustosx)
	MOUNT_OPTS="rw,nosuid,nodev,noexec"
	
	case "$FSTYPE" in

		vfat|exfat|ntfs|ntfs3)
			MOUNT_OPTS+=",uid=$USER_UID,gid=$USER_GID,umask=0022"
			;;

		ext2|ext3|ext4)
			# Permissoes nativas do filesystem
			;;
	esac

	DEV="/dev/$2"
	if is_system_partition "$DEV"; then
    		logger -t gustosx-media \
        		"Ignorando partição do disco do sistema: $DEV"
    		exit 0
	fi

	if mount -o "$MOUNT_OPTS" "$DEVICE" "$MOUNT"; then

    		logger -t gustosx-media \
        		"$DEVICE montado em $MOUNT"

		systemctl restart gustosx-storages.timer

	else
    		logger -t gustosx-media \
        	"Falha ao montar $DEVICE"

    		exit 1
	fi

	# Liberar lock
	flock -u 9
	exec 9>&-       
        ;;

    remove)

        exec 9>"$LOCK"
        flock -x 9

        for MOUNT in "${STORAGE[@]}"; do

            SOURCE=$(findmnt -rn -M "$MOUNT" \
                -o SOURCE 2>/dev/null || true)

            # Somente desmontar o dispositivo removido
            if [[ "$SOURCE" == "$DEVICE" ]]; then

                if umount "$MOUNT" ||
                   umount -l "$MOUNT"; then

                    logger -t gustosx-media \
                        "$DEVICE removido de $MOUNT"

                else

                    logger -t gustosx-media \
                        "Falha ao desmontar $DEVICE"

                fi
            fi

        done

        flock -u 9
        exec 9>&-

    	;;

esac
