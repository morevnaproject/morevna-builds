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

OLDDIR=`pwd`
ROOT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
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

DRY_RUN=
NO_CHECK_DEPS=
declare -A COMPLETION_STATUS


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
#     |  | | |
# 4. build | |
#     |    | |
# 5. install |
#     |    | |
# 6.  |    env
#     |    |
#     |    envdeps*
#     |
#     | env_release^
#     |  | 
# 7.  | envdeps_release
#     |  |           | 
# 8. install_release |
#            |       |
# 9.        env_release
#            |
#    envdeps_release*
#
###################################

FUNC_DEPS_download=""
FUNC_DEPS_unpack="download"
FUNC_DEPS_envdeps="-env"
FUNC_DEPS_build="unpack envdeps"
FUNC_DEPS_install="build envdeps"
FUNC_DEPS_env="install envdeps"
FUNC_DEPS_envdeps_release="-env_release"
FUNC_DEPS_install_release="install envdeps_release"
FUNC_DEPS_env_release="install_release envdeps_release"


copy() {
	if [ -d "$1" ]; then
		if ! mkdir -p $2; then
			return 1
		fi
		if [ "$(ls -A $1)" ]; then
			if ! cp -rlfP $1/* "$2/"; then
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

try_do_nothing() {
	if [ -z "$DRY_RUN" ]; then
		return 1
	fi
	set_done $1 $2
}

set_done() {
	local COMPLETION_KEY="$1:$2"
	if [ -z "$DRY_RUN" ]; then
		touch "$PACKET_DIR/$1/$2.done"
	fi
	COMPLETION_STATUS[$COMPLETION_KEY]=complete
}

set_undone_silent() {
	if [ -z "$DRY_RUN" ]; then
    	rm -f $PACKET_DIR/$1/$2.*.done
		rm -f "$PACKET_DIR/$1/$2.done"
	fi
	COMPLETION_STATUS[$COMPLETION_KEY]=incomplete
}

set_undone() {
	message "$1 set_undone $2"
	set_undone_silent $1 $2
}

clean_packet_directory_silent() {
	set_undone_silent $1 $2
    try_do_nothing $1 $2 && return 0
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

prepare_install() {
    if ! cp -f $BUILD_PACKET_DIR/version-* "$INSTALL_PACKET_DIR/"; then
        return 1
    fi
}

prepare_install_release() {
    if ! cp -f $INSTALL_PACKET_DIR/version-* "$INSTALL_RELEASE_PACKET_DIR/"; then
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
    local COMPARE_RESULTS=$5

    set_environment_vars $NAME

    local FUNC_NAME=pk$FUNC
    local FUNC_CURRENT_PACKET_DIR=$CURRENT_PACKET_DIR/$FUNC

    message "$NAME $FUNC"
    try_do_nothing $NAME $FUNC && return 0
	echo "${DRY_RUN_DONE[@]}"

	local PREV_DATE=
	local PREV_HASH=
	if [ "$COMPARE_RESULTS" = "compare_results" ]; then
		if check_packet_function $NAME $FUNC; then
			PREV_DATE=`date -Ins -r "$PACKET_DIR/$1/$2.done"`
			[ ! $? -eq 0 ] && return 1
			PREV_HASH=`tar -cf - "$FUNC_CURRENT_PACKET_DIR" --exclude=.git | md5sum` 
			[ ! $? -eq 0 ] && return 1
		fi
	fi

   	set_undone_silent $NAME $FUNC

    mkdir -p $FUNC_CURRENT_PACKET_DIR
    cd $FUNC_CURRENT_PACKET_DIR
    
	source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
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

	if [ ! -z "$PREV_DATE"]; then
		if [ ! -z "$PREV_HASH"]; then
			local HASH=`tar -cf - "$FUNC_CURRENT_PACKET_DIR" --exclude=.git | md5sum` 
			[ ! $? -eq 0 ] && return 1
			if [ "$HASH" = "$PREV_HASH" ]; then
				touch -d "$PREV_DATE" "$PACKET_DIR/$NAME/$FUNC.done"
				message "$NAME $FUNC - not changed"
				return 0
			fi
		fi
	fi

    set_done $NAME $FUNC
}

foreach_deps() {
    local NAME=$1
    local FUNC=$2
    local RECURSIVE=$3
    
	source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
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

is_complete() {
	local NAME=$1
	local FUNC=$2
	local SUBFUNCS_VAR_NAME=FUNC_DEPS_$FUNC
    local SUBFUNCS=${!SUBFUNCS_VAR_NAME}
    local COMPLETION_KEY="$NAME:$FUNC"
	if [ ! -z ${COMPLETION_STATUS[$COMPLETION_KEY]} ]; then
		if [ "${COMPLETION_STATUS[$COMPLETION_KEY]}" = "complete" ]; then
			return 0
		else
			return 1
		fi
	fi
	
	COMPLETION_STATUS[$COMPLETION_KEY]=incomplete
	
	if ! check_packet_function $1 $2; then
		return 1
	fi
	if [ ! -z "$NO_CHECK_DEPS" ]; then
		COMPLETION_STATUS[$COMPLETION_KEY]=complete
		return 0
	fi

	source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
    [ ! $? -eq 0 ] && return 1

	local CURRENT_DEPS=$DEPS
	for SUBFUNC in $SUBFUNCS; do
		local SUBFUNC_LOCAL=$SUBFUNC
		if [ "${SUBFUNC_LOCAL:0:1}" = "-" ]; then
			SUBFUNC_LOCAL=${SUBFUNC_LOCAL:1}
		    for DEP in $CURRENT_DEPS; do
		        if [ ! -z "$DEP" ]; then
		        	local DEP_LOCAL=$DEP
					if ! is_complete $DEP_LOCAL $SUBFUNC_LOCAL; then
						return 1
					fi
		    	    if [ "$PACKET_DIR/$NAME/$FUNC.done" -ot "$PACKET_DIR/$DEP_LOCAL/$SUBFUNC_LOCAL.done" ]; then
		        		return 1
		    	    fi
		        fi
		    done 
		else
			if ! is_complete $NAME $SUBFUNC_LOCAL; then
				return 1
			fi
    	    if [ "$PACKET_DIR/$NAME/$FUNC.done" -ot "$PACKET_DIR/$NAME/$SUBFUNC_LOCAL.done" ]; then
        		return 1
    	    fi
		fi
	done

	COMPLETION_STATUS[$COMPLETION_KEY]=complete
}

prepare() {
	local NAME=$1
	local FUNC=$2
	local SUBFUNCS_VAR_NAME=FUNC_DEPS_$FUNC
    local SUBFUNCS=${!SUBFUNCS_VAR_NAME}
	
	source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
    [ ! $? -eq 0 ] && return 1

	local CURRENT_DEPS=$DEPS
	local DODEPS=
	for SUBFUNC in $SUBFUNCS; do
		local SUBFUNC_LOCAL=$SUBFUNC
		if [ "${SUBFUNC_LOCAL:0:1}" = "-" ]; then
			SUBFUNC_LOCAL=${SUBFUNC_LOCAL:1}
		    for DEP in $CURRENT_DEPS; do
		        if [ ! -z "$DEP" ]; then
					if ! $SUBFUNC_LOCAL $DEP; then
						return 1
					fi
		        fi
		    done 
		elif ! $SUBFUNC_LOCAL $NAME; then
			return 1
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

update() {
    local NAME=$1
    prepare $NAME download || return 1
    call_packet_function $NAME download "" "" compare_results || return 1
}

download() {
    local NAME=$1
    is_complete $NAME download && return 0
    prepare     $NAME download || return 1
    call_packet_function $NAME download || return 1
}

unpack() {
    local NAME=$1
    is_complete $NAME unpack && return 0
    prepare     $NAME unpack || return 1
    call_packet_function $NAME unpack || return 1
}

envdeps() {
    local NAME=$1
    is_complete $NAME envdeps && return 0 
	prepare     $NAME envdeps || return 1

    message "$NAME envdeps"
    try_do_nothing $NAME envdeps && return 0

    clean_packet_directory_silent $NAME envdeps
    mkdir -p "$PACKET_DIR/$NAME/envdeps"
	if ! foreach_deps $NAME add_envdeps; then
		return 1
	fi
	set_done $NAME envdeps
}

build() {
    local NAME=$1
    is_complete $NAME build && return 0
    prepare     $NAME build || return 1
    call_packet_function $NAME build prepare_build || return 1
}

install() {
    local NAME=$1
    is_complete $NAME install && return 0
    prepare     $NAME install || return 1
    call_packet_function $NAME install prepare_install || return 1
}

env() {
    local NAME=$1
    is_complete $NAME env && return 0
    prepare     $NAME env || return 1

    message "$NAME env"
    try_do_nothing $NAME env && return 0
            
    clean_packet_directory_silent $NAME env
    mkdir -p "$PACKET_DIR/$NAME/env"
	if ! (copy "$PACKET_DIR/$NAME/envdeps" "$PACKET_DIR/$NAME/env" \
	&& copy "$PACKET_DIR/$NAME/install" "$PACKET_DIR/$NAME/env"); then
	    return 1
	fi
	set_done $NAME env
}

envdeps_release() {
    local NAME=$1
    is_complete $NAME envdeps_release && return 0
	prepare     $NAME envdeps_release || return 1

	message "$NAME envdeps_release"
    try_do_nothing $NAME envdeps_release && return 0

    clean_packet_directory_silent $NAME envdeps_release
    mkdir -p "$PACKET_DIR/$NAME/envdeps_release"
	if ! foreach_deps $NAME add_envdeps_release; then
		return 1
	fi
	set_done $NAME envdeps_release
}

install_release() {
    local NAME=$1
    is_complete $NAME install_release && return 0
    prepare     $NAME install_release || return 1
    call_packet_function $NAME install_release prepare_install_release || return 1
}

env_release() {
    local NAME=$1
    is_complete $NAME env_release && return 0
    prepare     $NAME env_release || return 1

	message "$NAME env_release"
    try_do_nothing $NAME env_release && return 0
            
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

clean_all_env() {
    clean_install $1
    clean_install_release $1
    clean_envdeps $1
    clean_env $1
    clean_envdeps_release $1
    clean_env_release $1
}

clean_all_install() {
    clean_build $1
    clean_all_env $1
}

clean_all_unpack() {
    clean_download $1
    clean_unpack $1
}

clean() {
	message "$1 clean all"
	try_do_nothing $NAME clean_all && return 0
    rm -rf "$PACKET_DIR/$1"
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

set_undone_all_env() {
    set_undone_install $1
    set_undone_install_release $1
    set_undone_envdeps $1
    set_undone_env $1
    set_undone_envdeps_release $1
    set_undone_env_release $1
}

set_undone_all_install() {
    set_undone_build $1
    set_undone_all_env $1
}

set_undone_all_unpack() {
    set_undone_download $1
    set_undone_unpack $1
}

set_undone_all() {
	set_undone_all_unpack $1
    set_undone_all_install $1
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
    set -- "${@:2}"
    if [ -z "$@" ]; then
    	/bin/bash -i
	else
		"$@"
    fi
}

dry_run() {
    DRY_RUN=1
    "$@"
}

no_check_deps() {
    NO_CHECK_DEPS=1
    "$@"
}

"$@"

