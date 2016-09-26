#!/bin/bash

# options

if [ -z "$PLATFORM" ]; then
	PLATFORM="linux-x64"
fi
export PLATFORM

if [ -z "$THREADS" ]; then
	THREADS=8
fi
export THREADS


# root

ROOT_DIR=`realpath "$0"`
ROOT_DIR=`dirname "$ROOT_DIR"`
ROOT_DIR=`dirname "$ROOT_DIR"`
ROOT_DIR=`dirname "$ROOT_DIR"`
export ROOT_DIR

# dirs

export SCRIPT_DIR=$ROOT_DIR/script
export COMMON_SCRIPT_DIR=$SCRIPT_DIR/common
export INCLUDE_SCRIPT_DIR=$SCRIPT_DIR/include
export PACKET_SCRIPT_DIR=$SCRIPT_DIR/packet
export PACKET_DIR=$ROOT_DIR/packet/$PLATFORM

if [ ! -z $PACKET_BUILD_DIR ]; then
	export PACKET_DIR=$PACKET_BUILD_DIR/$PLATFORM
fi

# vars

INITIAL_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
INITIAL_PATH=$PATH
INITIAL_LDFLAGS=$LDFLAGS
INITIAL_CFLAGS=$CFLAGS
INITIAL_CPPFLAGS=$CPPFLAGS
INITIAL_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

###################################
#
# Fairy Tale
# 
# Once upon time in faraway...
#
# Function dependency:
#
# 1. download 
#     |
# 2. unpack
#     |
#     | env^
#     |  |
# 3.  | envdeps  
#     |  |   |
# 4. build   |
#     |      |
# 5. install |
#     |    | |
# 6.  |    env
#     |    |
#     |    envdeps*
#     | 
# 7. install_release
#     |
#     | env_release^
#     |  |
# 8.  | envdeps_release
#     |  |
# 9. env_release
#     |
#    envdeps_release*
#
###################################


copy() {
	if [ -d "$1" ]; then
		if ! mkdir -p $2; then
			return 1
		fi
		if [ "$(ls -A $1)" ]; then
			if ! cp -rlf $1/* "$2/"; then
				return 1
			fi
		fi
	elif [ -f "$1" ]; then
		if ! (mkdir -p `dirname $2` && cp -l "$1" "$2"); then
			return 1
		fi
	else
		return 1
	fi
}

message() {
    echo " ------ $1"
}

set_done() {
	touch "$PACKET_DIR/$1/$2.done"
}

set_undone_silent() {
    rm -f $PACKET_DIR/$1/$2.*.done
	rm -f "$PACKET_DIR/$1/$2.done"
}

set_undone() {
	message "$1 set_undone $2"
	set_undone_silent $1 $2
}

clean_packet_directory_silent() {
    if [ ! -z "$DRY_RUN" ]; then
        return 0
    fi
	set_undone_silent $1 $2
    rm -rf "$PACKET_DIR/$1/$2"
}

clean_packet_directory() {
	message "$1 clean $2"
	clean_packet_directory_silent $1 $2
}

check_packet_function() {
    if [ ! -f "$PACKET_DIR/$1/$2.done" ]; then
        return 1
    fi
}

prepare_build() {
    if ! copy "$UNPACK_PACKET_DIR" "$BUILD_PACKET_DIR"; then
        return 1
    fi
}

set_environment_vars() {
    export NAME=$1

    export CURRENT_PACKET_DIR=$PACKET_DIR/$NAME
	export FILES_PACKET_DIR=$PACKET_SCRIPT_DIR/$NAME.files
    export DOWNLOAD_PACKET_DIR=$CURRENT_PACKET_DIR/download
    export UNPACK_PACKET_DIR=$CURRENT_PACKET_DIR/unpack
    export ENVDEPS_PACKET_DIR=$CURRENT_PACKET_DIR/envdeps
    export BUILD_PACKET_DIR=$CURRENT_PACKET_DIR/build
    export INSTALL_PACKET_DIR=$CURRENT_PACKET_DIR/install
    export INSTALL_RELEASE_PACKET_DIR=$CURRENT_PACKET_DIR/install_release
    export ENV_PACKET_DIR=$CURRENT_PACKET_DIR/env
    export ENVDEPS_RELEASE_PACKET_DIR=$CURRENT_PACKET_DIR/envdeps_release
    export ENV_RELEASE_PACKET_DIR=$CURRENT_PACKET_DIR/env_release

    export LD_LIBRARY_PATH="$ENV_PACKET_DIR/lib:$ENV_PACKET_DIR/lib64:$ENVDEPS_PACKET_DIR/lib:$ENVDEPS_PACKET_DIR/lib64:$INITIAL_LD_LIBRARY_PATH"
    export PATH="$ENVDEPS_PACKET_DIR/bin:$INITIAL_PATH"
    export LDFLAGS="-L$ENVDEPS_PACKET_DIR/lib $INITIAL_LDFLAGS"
    export CFLAGS="-I$ENVDEPS_PACKET_DIR/include $INITIAL_CFLAGS"
    export CPPFLAGS="-I$ENVDEPS_PACKET_DIR/include $INITIAL_CPPFLAGS"
    export PKG_CONFIG_PATH="$ENVDEPS_PACKET_DIR/lib/pkgconfig:$INITIAL_PKG_CONFIG_PATH" 
}

call_packet_function() {
    local NAME=$1
    local FUNC=$2
    local PREPARE_FUNC=$3
    local FINALIZE_FUNC=$4

    set_environment_vars $NAME

    local FUNC_NAME=pk$FUNC
    local FUNC_CURRENT_PACKET_DIR=$CURRENT_PACKET_DIR/$FUNC

    message "$NAME $FUNC"
    if [ ! -z "$DRY_RUN" ]; then
        return 0
    fi

    set_undone_silent $NAME $FUNC

    mkdir -p $FUNC_CURRENT_PACKET_DIR
    cd $FUNC_CURRENT_PACKET_DIR
    
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
    [ ! $? -eq 0 ] && return 1

    if [ ! -z "$PREPARE_FUNC" ]; then
        if ! "$PREPARE_FUNC"; then
            return 1
        fi
    fi

    if ! "$FUNC_NAME"; then
        return 1
    fi

    if [ ! -z "$FINALIZE_FUNC" ]; then
        if ! "$FINALIZE_FUNC"; then
            return 1
        fi
    fi

    set_done $NAME $FUNC
}

foreach_deps() {
    local NAME=$1
    local FUNC=$2
    local RECURSIVE=$3
    
    source $PACKET_SCRIPT_DIR/$NAME.sh
    [ ! $? -eq 0 ] && return 1
    
    local CURRENT_DEPS=$DEPS
    for DEP in $CURRENT_DEPS; do
        if [ ! -z "$DEP" ]; then
        	local DEP_LOCAL=$DEP 
        	if [ "$RECURSIVE" = "recursive" ]; then
        		if ! foreach_deps "$DEP_LOCAL" "$FUNC" "$RECURSIVE"; then
                	return 1
        		fi
        	fi
            if ! "$FUNC" "$DEP_LOCAL" "$NAME"; then
                return 1
            fi
        fi
	done
}

add_envdeps() {
	if ! copy "$PACKET_DIR/$1/env" "$PACKET_DIR/$2/envdeps"; then
	    return 1
	fi
}

add_envdeps_release() {
	if ! copy "$PACKET_DIR/$1/env_release" "$PACKET_DIR/$2/envdeps_release"; then
	    return 1
	fi
}

download() {
    if ! (check_packet_function $1 download || call_packet_function $1 download); then
        return 1
    fi
}

unpack() {
    if ! (check_packet_function $1 unpack || (download $1 && call_packet_function $1 unpack)); then
        return 1
    fi
}

envdeps() {
    if check_packet_function $1 envdeps; then
        return 0
    fi

    local NAME=$1

	if ! foreach_deps $NAME env; then
		return 1
	fi

    message "$NAME envdeps"
    
    if [ ! -z "$DRY_RUN" ]; then
    	return 0
    fi

    clean_packet_directory_silent $NAME envdeps
    mkdir -p "$PACKET_DIR/$NAME/envdeps"
	if ! foreach_deps $NAME add_envdeps; then
		return 1
	fi
	set_done $NAME envdeps
}

build() {
    if ! (check_packet_function $1 build || (envdeps $1 && unpack $1 && call_packet_function $1 build prepare_build)); then
        return 1
    fi
}

install() {
    if ! (check_packet_function $1 install || (build $1 && call_packet_function $1 install)); then
        return 1
    fi
}

env() {
    if check_packet_function $1 env; then
        return 0
    fi
    
    local NAME=$1
    
    if ! (install $1 && envdeps $1); then
        return 1
    fi

    message "$NAME env"
    
    if [ ! -z "$DRY_RUN" ]; then
    	return 0
    fi
            
    clean_packet_directory_silent $NAME env
    mkdir -p "$PACKET_DIR/$NAME/env"
	if ! (copy "$PACKET_DIR/$NAME/envdeps" "$PACKET_DIR/$NAME/env" \
	&& copy "$PACKET_DIR/$NAME/install" "$PACKET_DIR/$NAME/env"); then
	    return 1
	fi
	set_done $NAME env
}

install_release() {
    if ! (check_packet_function $1 install_release || (install $1 && call_packet_function $1 install_release)); then
        return 1
    fi
}

envdeps_release() {
    if check_packet_function $1 envdeps_release; then
        return 0
    fi

    local NAME=$1

	if ! foreach_deps $NAME env_release; then
		return 1
	fi

	message "$NAME envdeps_release"

    if [ ! -z "$DRY_RUN" ]; then
    	return 0
    fi

    clean_packet_directory_silent $NAME envdeps_release
    mkdir -p "$PACKET_DIR/$NAME/envdeps_release"
	if ! foreach_deps $NAME add_envdeps_release; then
		return 1
	fi
	set_done $NAME envdeps_release
}

env_release() {
    if check_packet_function $1 env_release; then
        return 0
    fi
    
    local NAME=$1
    
    if ! (install_release $1 && envdeps_release $1); then
        return 1
    fi

	message "$NAME env_release"

    if [ ! -z "$DRY_RUN" ]; then
    	return 0
    fi
            
    clean_packet_directory_silent $NAME env_release
    mkdir -p "$PACKET_DIR/$NAME/env_release"
	if ! (copy "$PACKET_DIR/$NAME/envdeps_release" "$PACKET_DIR/$NAME/env_release" \
	&& copy "$PACKET_DIR/$NAME/install_release" "$PACKET_DIR/$NAME/env_release"); then
	    return 1
	fi
	set_done $NAME env_release
}


#############

clean_download() {
    clean_packet_directory $1 download
}

clean_unpack() {
    clean_packet_directory $1 download
}

clean_envdeps() {
    clean_packet_directory $1 envdeps
}

clean_build() {
    clean_packet_directory $1 build
}

clean_install() {
    clean_packet_directory $1 install
}

clean_env() {
    clean_packet_directory $1 env
}

clean_install_release() {
    clean_packet_directory $1 install_release
}

clean_envdeps_release() {
    clean_packet_directory $1 envdeps_release
}

clean_env_release() {
    clean_packet_directory $1 env_release
}

clean() {
    clean_download $1
    clean_unpack $1
    clean_envdeps $1
    clean_build $1
    clean_install $1
    clean_env $1
    clean_install_release $1
    clean_envdeps_release $1
    clean_env_release $1
}

clean_all_install() {
    clean_envdeps $1
    clean_build $1
    clean_install $1
    clean_env $1
    clean_install_release $1
    clean_envdeps_release $1
    clean_env_release $1
}

clean_all_env() {
    clean_envdeps $1
    clean_env $1
    clean_envdeps_release $1
    clean_env_release $1
}

#############

set_undone_download() {
    set_undone $1 download
}

set_undone_unpack() {
    set_undone $1 download
}

set_undone_envdeps() {
    set_undone $1 envdeps
}

set_undone_build() {
    set_undone $1 build
}

set_undone_install() {
    set_undone $1 install
}

set_undone_env() {
    set_undone $1 env
}

set_undone_install_release() {
    set_undone $1 install_release
}

set_undone_envdeps_release() {
    set_undone $1 envdeps_release
}

set_undone_env_release() {
    set_undone $1 env_release
}

clean() {
    set_undone_download $1
    set_undone_unpack $1
    set_undone_envdeps $1
    set_undone_build $1
    set_undone_install $1
    set_undone_env $1
    set_undone_install_release $1
    set_undone_envdeps_release $1
    set_undone_env_release $1
}

#############

with_deps() {
	if ! foreach_deps "$2" "$1" "recursive"; then
		return 1
	fi
    if ! "$1" "$2"; then
        return 1
    fi
}

shell() {
    set_environment_vars $1
    cd $PACKET_DIR/$1
    /bin/bash -i
}

dry_run() {
    DRY_RUN=1
    "$@"
}

"$@"
