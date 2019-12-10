#!/bin/bash

set -e

OLDDIR=`pwd`
BASE_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"

INSTANCE_NAME=`uuidgen`
INSTANCE_NAME="chrooter-$INSTANCE_NAME"
PRIVILEGED=
IMAGE_MOUNT_DIR=
COMMAND_ERROR=
PREFIX="$CHROOTER_PREFIX"
if [ -z "$PREFIX" ]; then
    PREFIX="/tmp"
fi

image_mount_add() {
	echo "Mount: $1 -> $2"
	sudo mkdir -p "$IMAGE_MOUNT_DIR$2"
	sudo mount --bind "$1" "$IMAGE_MOUNT_DIR$2"
	echo "umount \"$IMAGE_MOUNT_DIR$2\" \\" >> "/$PREFIX/$INSTANCE_NAME.umount.sh"
	echo "|| (echo \"next try after 10 seconds\" && sleep 10 && umount -f \"$IMAGE_MOUNT_DIR$2\") \\" >> "/$PREFIX/$INSTANCE_NAME.umount.sh"
	echo "|| (echo \"final try after 10 seconds\" && sleep 10 && umount -f \"$IMAGE_MOUNT_DIR$2\")" >> "/$PREFIX/$INSTANCE_NAME.umount.sh"
}

image_mount() {
	echo "Mount image: $1"

	if [ ! -z "$IMAGE_MOUNT_DIR" ]; then
		echo "Image already mounted"
		return 1
	fi
	if [ -z "$1" ]; then
		echo "Image name was not set"
		return 1
	fi	
	
	local IMAGE_NAME="$(echo $1 | tr "/:" "_")"
	local IMAGE_FILE="$BASE_DIR/image/$IMAGE_NAME.tgz"
	
	echo "Unpack image: $1"
	IMAGE_MOUNT_DIR="/$PREFIX/$INSTANCE_NAME"
	mkdir -p "$IMAGE_MOUNT_DIR"
	cd "$IMAGE_MOUNT_DIR"
	sudo tar -xzf $IMAGE_FILE
	cd "$OLDDIR"
	
	echo "Add -.chroot.sh file"
	sudo mv "/$PREFIX/$INSTANCE_NAME.chroot.sh" "$IMAGE_MOUNT_DIR"
	sudo chmod a+x "$IMAGE_MOUNT_DIR/$INSTANCE_NAME.chroot.sh"
	
    set -- "${@:2}"
	echo "Mount subs: $@"
	echo "#!/bin/sh" > "/$PREFIX/$INSTANCE_NAME.umount.sh"
	echo "" >> "/$PREFIX/$INSTANCE_NAME.umount.sh"
	echo "set -e" >> "/$PREFIX/$INSTANCE_NAME.umount.sh"
	chmod a+x "/$PREFIX/$INSTANCE_NAME.umount.sh"
	if [ ! -z "$PRIVILEGED" ]; then
		echo "Mount /proc and /dev for priveleged feature"
		image_mount_add /proc /proc
		image_mount_add /dev /dev
	fi
    for ARG in $@; do
		SRC="$(echo "$ARG" | cut -d':' -f 1)"
		DEST="$(echo "$ARG" | cut -d':' -f 2-)"
		image_mount_add $SRC $DEST
	done

	echo "Add /etc/resolv.conf"
	sudo mkdir -p $IMAGE_MOUNT_DIR/etc && cp /etc/resolv.conf $IMAGE_MOUNT_DIR/etc
}

image_unmount() {
	echo "Unmount image"
	
	if [ -z "$IMAGE_MOUNT_DIR" ]; then
		echo "Image not mounted"
		return 1
	fi

	echo "Unmount subs"
	sudo "/$PREFIX/$INSTANCE_NAME.umount.sh"
	sudo rm -f "/$PREFIX/$INSTANCE_NAME.umount.sh"

	echo "Remove -.chroot.sh file"
	sudo rm -f "$IMAGE_MOUNT_DIR/$INSTANCE_NAME.chroot.sh"
	
	if [ ! -z $1 ]; then
		echo "Save image: $1"
		
		local IMAGE_NAME="$(echo $1 | tr "/:" "_")"
		local IMAGE_FILE="$BASE_DIR/image/$IMAGE_NAME.tgz"
		local IMAGE_DIR=`dirname "$IMAGE_FILE"`
		mkdir -p "$IMAGE_DIR"
		
		cd "$IMAGE_MOUNT_DIR"
		sudo tar -czf $IMAGE_FILE .
		cd "$OLDDIR"
	fi
	
	echo "Remove unpacked image"
	sudo rm -rf --one-file-system "$IMAGE_MOUNT_DIR"
	IMAGE_MOUNT_DIR=
}

image_command() {
	echo "Run command: $@"
	
	if [ -z "$IMAGE_MOUNT_DIR" ]; then
		echo "Image not mounted"
		return 1
	fi

	if ! env -i /usr/bin/sudo -i chroot "$IMAGE_MOUNT_DIR" "/$INSTANCE_NAME.chroot.sh" $@; then
		COMMAND_ERROR=1
		echo "Command returned with error"
	fi
}

image_copy() {
	echo "Copy into image: $1 $2"
	
	if ! cp "$1" "$IMAGE_MOUNT_DIR/$2"; then
		echo "Cannot copy \"$1\" -> \"$IMAGE_MOUNT_DIR/$2\""
		return 1
	fi
}

chroot_file_begin() {
	echo "#!/bin/sh" > "/$PREFIX/$INSTANCE_NAME.chroot.sh"
	echo "" >> "/$PREFIX/$INSTANCE_NAME.chroot.sh"
}

chroot_file_env() {
    echo "Set env: $1=\"$2\""
	echo "export $1=\"$2\"" >> "/$PREFIX/$INSTANCE_NAME.chroot.sh"
}

chroot_file_end() {
	echo "\$@" >> "/$PREFIX/$INSTANCE_NAME.chroot.sh"
}

import() {
	echo "Import $2"
	
	if [ ! "$1" = "-" ]; then
    	echo "Unknown commandline argument $1"
	fi
	if [ -z "$2" ]; then
    	echo "Image name was not set"
    	return 1
	fi
	
		
	local IMAGE_NAME="$(echo $2 | tr "/:" "_")"
	local IMAGE_FILE="$BASE_DIR/image/$IMAGE_NAME.tgz"
	local IMAGE_DIR=`dirname "$IMAGE_FILE"`
	mkdir -p "$IMAGE_DIR"
	cat "/dev/stdin" > $IMAGE_FILE
}

build() {
	echo "Build"
	
	local IMAGE_NAME=
	local WORK_DIR=
		
	chroot_file_begin
    local MODE=
    for ARG in $@; do
    	if [ -z "$WORK_DIR" ]; then
	    	if [ "$MODE" = "-t" ]; then
	    		IMAGE_NAME="$ARG"
	    		echo "Set image name: $IMAGE_NAME"
	    		MODE=
	    		continue
	    	fi
	    fi
    	
    	if [ ! -z "$MODE" ]; then
    		echo "Unknown commandline argument: $MODE"
    	fi

    	MODE=
    	if [ ! -z "$WORK_DIR" ]; then
    		echo "Unknown commandline argument: $ARG"
		elif [ "${ARG:0:1}" = "-" ]; then
    		SUBMODE="$(echo "$ARG" | cut -d'=' -f 1)"
    		SUBVALUE="$(echo "$ARG" | cut -d'=' -f 2-)"
    		if [ "$SUBMODE" = "--build-arg" ]; then
    			ENVKEY="$(echo "$SUBVALUE" | cut -d'=' -f 1)"
    			ENVVALUE="$(echo "$SUBVALUE" | cut -d'=' -f 2-)"
    			chroot_file_env "$ENVKEY" "$ENVVALUE"
    			continue
    		else
    			MODE=$ARG
    		fi
    	else
			WORK_DIR=$ARG
			echo "Set work dir: $WORK_DIR"
		fi
	done
	if [ ! -z "$MODE" ]; then
		echo "Unknown commandline argument $MODE"
	fi
	chroot_file_end

	if [ -z "$IMAGE_NAME" ]; then
		echo "Image name was not set"
		return 1
	fi
								
	local DOCKERFILE="$WORK_DIR/Dockerfile"
	if [ ! -f "$DOCKERFILE" ]; then
		echo "Dockerfile not found at: $DOCKERFILE"
		return 1
	fi

	echo "Read $DOCKERFILE"
	FULLROW=
	while read ROW; do
		FULLROW="$FULLROW$ROW"
		LASTCHAR=$((${#ROW}-1))
		if [ ! "${ROW:LASTCHAR:1}" = "\\" ]; then
			if [ "${FULLROW:0:5}" = "FROM " ]; then
				image_mount "${FULLROW:5}"
			elif [ "${ROW:0:4}" = "RUN " ]; then
				image_command "${FULLROW:4}"
			elif [ "${ROW:0:5}" = "COPY " ]; then
				image_copy ${FULLROW:5}
			elif [ ! "${FULLROW:0:1}" = "#" ]; then
				if [ ! -z "$FULLROW" ]; then
					echo "Unknown command: $FULLROW"
				fi 
			fi
			FULLROW=
		fi
		if [ ! -z "$COMMAND_ERROR" ]; then
			echo "Cancel build"
			IMAGE_NAME=""
			break
		fi
	done < "$DOCKERFILE"
	
	image_unmount "$IMAGE_NAME"
}

run() {
	local IMAGE_NAME=
	local COMMAND=
	local SUBMOUNT=
	
	chroot_file_begin
    local MODE=
    for ARG in $@; do
    	if [ ! -z "$COMMAND" ]; then
	    	COMMAND="$COMMAND $ARG"
    	else
	    	if [ "$MODE" = "-e" ]; then
				ENVKEY="$(echo "$ARG" | cut -d'=' -f 1)"
				ENVVALUE="$(echo "$ARG" | cut -d'=' -f 2-)"
				chroot_file_env "$ENVKEY" "$ENVVALUE"
				MODE=
				continue
	    	elif [ "$MODE" = "-v" ]; then
				SUBMOUNT="$SUBMOUNT$ARG "
	    		echo "Add submount: $ARG"
				MODE=
				continue
	    	elif [ "$MODE" = "--name" ]; then
	    		echo "Set name: $ARG (not uses)"
				MODE=
				continue
	    	fi
	    
	    	if [ ! -z "$MODE" ]; then
	    		echo "Unknown commandline argument $MODE"
	    	fi
	    	    	    	    	
	    	MODE=
	    	if [ -z "$MODE" ]; then
	    		if [ "$ARG" = "--privileged=true" ]; then
	    			PRIVILEGED=1
	    			echo "Set privileged: true"
	    		elif [ "${ARG:0:1}" = "-" ]; then
    				MODE=$ARG
		    	elif [ -z "$IMAGE_NAME" ]; then
		    		IMAGE_NAME=$ARG
	    			echo "Set image name: $IMAGE_NAME"
		    	elif [ -z "$COMMAND" ]; then
	    			COMMAND=$ARG
	    		fi
	    	fi
		fi
	done
	if [ ! -z "$MODE" ]; then
		echo "Unknown commandline argument $MODE"
	fi
	chroot_file_end
	echo "Set command: $COMMAND"

	if [ -z "$COMMAND" ]; then
		echo "Command was not set"
		return 1
	fi

	image_mount "$IMAGE_NAME" $SUBMOUNT
	image_command $COMMAND
	image_unmount
}


if [ "$1" = "import" ]; then
    set -- "${@:2}"
    import $@
elif [ "$1" = "build" ]; then
    set -- "${@:2}"
    build $@
elif [ "$1" = "run" ]; then
    set -- "${@:2}"
    run $@
else
	echo "Unknown command: $1"
	COMMAND_ERROR=1
fi

if [ ! -z "$COMMAND_ERROR" ]; then
	false
fi
