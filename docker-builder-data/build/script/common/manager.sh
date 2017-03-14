#!/bin/bash

###############################################
#
# Input environment variables
#
# PLATFORM         - target platform (linux or windows)
# ARCH             - bits (32 or 64)
# NATIVE_PLATFORM  - folder name for store compiled utilities for build-time (debian, fedora, etc)
# NATIVE_ARCH      - ^^^ bits (32 or 64)
# THREADS          - amount of simultaneous threads for build process
# PACKET_BUILD_DIR - output directory (optional)
#
###############################################

# check options

if [ -z "$NATIVE_PLATFORM" ]; then
    NATIVE_PLATFORM="default"
fi

if [ -z "$NATIVE_ARCH" ]; then
    NATIVE_ARCH=`uname -m`
    if [ "$NATIVE_ARCH" = "x86_64" ]; then
        NATIVE_ARCH="64"
    elif [ "$NATIVE_ARCH" = "i686" ]; then
        NATIVE_ARCH="32"
    fi
fi

if [ -z "$TARGET_PLATFORM" ]; then
    TARGET_PLATFORM="$NATIVE_PLATFORM"
fi

if [ -z "$ARCH" ]; then
    ARCH="$NATIVE_ARCH"
fi

if [ -z "$THREADS" ]; then
    THREADS=8
fi

export NATIVE_PLATFORM
export NATIVE_ARCH
export PLATFORM
export ARCH
export THREADS

# root

ROOT_DIR=$(cd `dirname "$0"`; pwd)
ROOT_DIR=`dirname "$ROOT_DIR"`
ROOT_DIR=`dirname "$ROOT_DIR"`
export ROOT_DIR

# dirs

export SCRIPT_DIR=$ROOT_DIR/script
export COMMON_SCRIPT_DIR=$SCRIPT_DIR/common
export INCLUDE_SCRIPT_DIR=$SCRIPT_DIR/include
export PACKET_SCRIPT_DIR=$SCRIPT_DIR/packet
if [ -z "$PACKET_BUILD_DIR" ]; then
	export PACKET_BUILD_DIR=$ROOT_DIR/packet
fi
export PACKET_DIR=$PACKET_BUILD_DIR/$PLATFORM-$ARCH
export NATIVE_PACKET_DIR=$PACKET_BUILD_DIR/$NATIVE_PLATFORM-$NATIVE_ARCH-native

# toolchain

export TOOLCHAIN_SCRIPT_DIR=$SCRIPT_DIR/toolchain
export NATIVE_TOOLCHAIN_SCRIPT="$TOOLCHAIN_SCRIPT_DIR/none.sh"
export TOOLCHAIN_SCRIPT="$TOOLCHAIN_SCRIPT_DIR/$PLATFORM-$ARCH.sh"
if [ ! -f "$TOOLCHAIN_SCRIPT" ]; then
    TOOLCHAIN_SCRIPT=$NATIVE_TOOLCHAIN_SCRIPT
fi

# initial system vars

INITIAL_HOST=$HOST
INITIAL_PATH=$PATH
INITIAL_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
INITIAL_CC=$CC
INITIAL_CXX=$CXX
INITIAL_FORTRAN=$FORTRAN
INITIAL_LD=$LD
INITIAL_AR=$AR
INITIAL_RANLIB=$RANLIB
INITIAL_LDFLAGS=$LDFLAGS
INITIAL_CFLAGS=$CFLAGS
INITIAL_CPPFLAGS=$CPPFLAGS
INITIAL_CXXFLAGS=$CXXFLAGS
INITIAL_PKG_CONFIG_PATH=$PKG_CONFIG_PATH
INITIAL_PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR
INITIAL_XDG_DATA_DIRS=$XDG_DATA_DIRS
INITIAL_ACLOCAL_PATH=$ACLOCAL_PATH
INITIAL_CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH
INITIAL_CMAKE_LIBRARY_PATH=$CMAKE_LIBRARY_PATH

if [ ! -z "$INITIAL_ACLOCAL_PATH" ]; then
    INITIAL_ACLOCAL_PATH = "$INITIAL_ACLOCAL_PATH:"
fi
INITIAL_ACLOCAL_PATH="$INITIAL_ACLOCAL_PATH/usr/share/aclocal"


# work vars

IS_NATIVE=
DRY_RUN=
FORCE=
CLEAN_BEFORE_DO=
NO_CHECK_DEPS=
declare -A COMPLETION_STATUS

###############################################
#
# Fairy Tale
# 
# Once upon time in faraway...
#
# Function dependency:
#
# 1.                 download 
#                     |
# 2.                 unpack
#                     |
#                     | env^
#                     |  |
# 3.                  | envdeps 
#                     | | | |
#      env^^          | | | |
#       |             | | | |
#       | env_native^ | | | |
#       |  |          | | | |
# 4.   envdeps_native | | | |
#       |         | | | | | |
# 5.    |         | build | |
#       |         | | |   | |
#       |         | | |   | |
# 6.    |         | | lic | | (license)
#       |         | | |   | |
# 7.    |         --install |
#       |            |    | |
# 8.    |            |    env
#       |            |    | |
#       |            |    | envdeps*
#       |            |    |
#       |            |   envdeps_native**
#       |            |
# 9.   env_native    |
#       |            |
#    envdeps_native* |
#                    |
#                    | env_release^
#                    |  | 
# 10.                | envdeps_release
#                    |  |           | 
# 11.               install_release |
#                           |       |
# 12.                      env_release
#                           |
#                          envdeps_release*
#
###############################################

FUNC_DEPS_download=""
FUNC_DEPS_unpack="download"
FUNC_DEPS_envdeps="-env"
FUNC_DEPS_envdeps_native="--env -env_native"
FUNC_DEPS_build="envdeps envdeps_native unpack"
FUNC_DEPS_license="build"
FUNC_DEPS_install="envdeps envdeps_native build license"
FUNC_DEPS_env="envdeps install"
FUNC_DEPS_env_native="envdeps_native"
FUNC_DEPS_envdeps_release="-env_release"
FUNC_DEPS_install_release="envdeps_release install"
FUNC_DEPS_env_release="envdeps_release install_release"


# helpers

copy() {
    local SRC=$1
    local DEST=$2
	if [ -d "$SRC" ]; then
		if ! mkdir -p $DEST; then
			return 1
		fi
		if [ "$(ls -A $1)" ]; then
			if ! cp --remove-destination -rlP $SRC/* "$DEST/"; then
				return 1
			fi
		fi
	elif [ -f "$SRC" ]; then
		if ! (mkdir -p `dirname $DEST` && cp --remove-destination -l "$SRC" "$DEST"); then
			return 1
		fi
	else
		return 1
	fi
}

foreachfile() {
    local FILE=$1
    local COMMAND=$2
    if [ ! -x "$FILE" ]; then
        return 1
    fi
    if [ -d "$FILE" ]; then    
        ls -1 "$FILE" | while read SUBFILE; do
            if ! $COMMAND "$FILE/$SUBFILE" ${@:3}; then
                return 1
            fi
        done
    fi
}

readdir() {
    local FILE=$1
    if [ -d "$FILE" ]; then
        echo "directory begin"
        ls -1 "$1" | while read SUBFILE; do
            if [ "$SUBFILE" = ".git" ]; then
                continue
            fi
            if [[ "$SUBFILE" == *.po ]]; then
                continue
            fi
            local STAT=`stat -c%F:%a:%s "$FILE/$SUBFILE"`
            echo "$STAT:$SUBFILE"
            readdir "$FILE/$SUBFILE"
        done
        echo "directory end"
    else
        local MD5=`md5sum -b "$FILE"`
        echo "file:${MD5:0:32}"
    fi
}

md5() {
    local FILE=$1
    local MD5=`readdir "$FILE" | md5sum -b`
    echo "${MD5:0:32}"
}

remove_recursive() {
    local CURRENT_PATH="$1"
    local NEEDLE="$2"
    rm -f "$CURRENT_PATH/"$NEEDLE
    for FILE in $CURRENT_PATH; do
        if [ -d "$CURRENT_PATH/$FILE" ]; then
            remove_recursive "$CURRENT_PATH/$FILE" "$NEEDLE"
        fi
    done
}

copy_system_lib() {
    local SRC_NAME=$1
    local DST_PATH=$2
    cp --remove-destination /lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /usr/lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /usr/lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || (echo "$SRC_NAME not found in system libraries" && return 1)
}

copy_system_license() {
    local SRC_NAMES=$1
    local DST_PATH=$2
    local SRC_NAME=
    for SRC_NAME in $SRC_NAMES; do
        rm -f "$DST_PATH/license-$SRC_NAME"
    done
    for SRC_NAME in $SRC_NAMES; do
        local TARGET="$DST_PATH/license-$SRC_NAME"
        local FILE=
        if   [ -f "/usr/share/doc/$SRC_NAME/copyright" ]; then
             FILE="/usr/share/doc/$SRC_NAME/copyright"
        elif [ -d "/usr/share/licenses/$SRC_NAME" ]; then
             FILE="/usr/share/licenses/$SRC_NAME"
        elif [ -d "/usr/share/doc/$SRC_NAME" ]; then
             FILE="/usr/share/doc/$SRC_NAME"
        fi

        if [ -f "$FILE" ]; then
            echo ""                                      >> "$TARGET"
            echo "-------------------------------------" >> "$TARGET"
            echo "  File: $FILE"                         >> "$TARGET"
            echo "-------------------------------------" >> "$TARGET"
            echo ""                                      >> "$TARGET"
            cat "$FILE"                                  >> "$TARGET"
        elif [ -d "$FILE" ]; then
            ls -1 "$FILE" | while read SUBFILE; do
                echo ""                                      >> "$TARGET"
                echo "-------------------------------------" >> "$TARGET"
                echo "  File: $SUBFILE"                      >> "$TARGET"
                echo "-------------------------------------" >> "$TARGET"
                echo ""                                      >> "$TARGET"
                cat "$SUBFILE"                               >> "$TARGET"
            done
        fi
        
        if [ -f "$TARGET" ]; then
            return 0
        fi
    done

    echo "Cannot found any license for one of system packages: $SRC_NAMES"
    return 1
}

# internal functions

message() {
    local MESSAGE=$1
    echo " ------ $MESSAGE"
}

try_do_nothing() {
	if [ -z "$DRY_RUN" ]; then
		return 1
	fi
	set_done $1 $2
}

set_done() {
    local PACKET=$1
    local FUNC=$2
	local COMPLETION_KEY="$PLATFORM:$ARCH:$PACKET:$FUNC"
	if [ -z "$DRY_RUN" ]; then
		touch "$PACKET_DIR/$PACKET/$FUNC.done"
	fi
	COMPLETION_STATUS[$COMPLETION_KEY]=complete
}

set_undone_silent() {
    local PACKET=$1
    local FUNC=$2
	local COMPLETION_KEY="$PLATFORM:$ARCH:$PACKET:$FUNC"
	if [ -z "$DRY_RUN" ]; then
    	rm -f $PACKET_DIR/$PACKET/$FUNC.*.done
		rm -f "$PACKET_DIR/$PACKET/$FUNC.done"
	fi
	COMPLETION_STATUS[$COMPLETION_KEY]=incomplete
}

set_undone() {
    local PACKET=$1
    local FUNC=$2
	message "$PACKET set_undone $FUNC"
	set_undone_silent $PACKET $FUNC
}

clean_packet_directory_silent() {
    local PACKET=$1
    local FUNC=$2
	set_undone_silent $PACKET $FUNC
    try_do_nothing $PACKET $FUNC && return 0
    rm -rf "$PACKET_DIR/$PACKET/$FUNC"
}

clean_packet_directory() {
    local PACKET=$1
    local FUNC=$2
	message "$PACKET clean $FUNC"
	clean_packet_directory_silent $PACKET $FUNC
}

check_packet_function() {
    local PACKET=$1
    local FUNC=$2
	if [ ! -z "$FORCE" ]; then
		return 1
	fi
    if [ ! -f "$PACKET_DIR/$PACKET/$FUNC.done" ]; then
        return 1
    fi
}

prepare_build() {
    if ! copy "$UNPACK_PACKET_DIR" "$BUILD_PACKET_DIR"; then
        return 1
    fi
}

prepare_license() {
    return 0
}

prepare_install() {
    if ls $BUILD_PACKET_DIR/version-* 1> /dev/null 2>&1; then
        cp --remove-destination $BUILD_PACKET_DIR/version-* "$INSTALL_PACKET_DIR/" || true
    fi
    mkdir -p "$INSTALL_PACKET_DIR/license" || return 1
    copy "$LICENSE_PACKET_DIR" "$INSTALL_PACKET_DIR/license" || return 1
}

prepare_install_release() {
    if ls $INSTALL_PACKET_DIR/version-* 1> /dev/null 2>&1; then
        cp --remove-destination $INSTALL_PACKET_DIR/version-* "$INSTALL_RELEASE_PACKET_DIR/" || true
    fi
}

set_environment_vars() {
    export NAME=$1

    export CURRENT_PACKET_DIR="$PACKET_DIR/$NAME"
	export FILES_PACKET_DIR="$PACKET_SCRIPT_DIR/$NAME.files"
    export DOWNLOAD_PACKET_DIR="$CURRENT_PACKET_DIR/download"
    export UNPACK_PACKET_DIR="$CURRENT_PACKET_DIR/unpack"
    export ENVDEPS_PACKET_DIR="$CURRENT_PACKET_DIR/envdeps"
    export ENVDEPS_NATIVE_PACKET_DIR="$CURRENT_PACKET_DIR/envdeps_native"
    export BUILD_PACKET_DIR="$CURRENT_PACKET_DIR/build"
    export LICENSE_PACKET_DIR="$CURRENT_PACKET_DIR/license"
    export INSTALL_PACKET_DIR="$CURRENT_PACKET_DIR/install"
    export INSTALL_RELEASE_PACKET_DIR="$CURRENT_PACKET_DIR/install_release"
    export ENV_PACKET_DIR="$CURRENT_PACKET_DIR/env"
    export ENV_NATIVE_PACKET_DIR="$CURRENT_PACKET_DIR/env_native"
    export ENVDEPS_RELEASE_PACKET_DIR="$CURRENT_PACKET_DIR/envdeps_release"
    export ENV_RELEASE_PACKET_DIR="$CURRENT_PACKET_DIR/env_release"

    export HOST=$TOOLCHAIN_HOST

    export PATH="\
$ENVDEPS_NATIVE_PACKET_DIR/bin:\
$ENV_NATIVE_PACKET_DIR/bin:\
$ENVDEPS_PACKET_DIR/bin:\
$ENV_PACKET_DIR/bin:\
$TOOLCHAIN_PATH"

    export LD_LIBRARY_PATH="\
$ENVDEPS_NATIVE_PACKET_DIR/lib:\
$ENVDEPS_NATIVE_PACKET_DIR/lib64\
$ENV_NATIVE_PACKET_DIR/lib:\
$ENV_NATIVE_PACKET_DIR/lib64:\
$ENVDEPS_PACKET_DIR/lib:\
$ENVDEPS_PACKET_DIR/lib64:\
$ENV_PACKET_DIR/lib:\
$ENV_PACKET_DIR/lib64:\
$TOOLCHAIN_LD_LIBRARY_PATH"

    export CC=$TOOLCHAIN_CC
    export CXX=$TOOLCHAIN_CXX
    export FORTRAN=$TOOLCHAIN_FORTRAN
    export LD=$TOOLCHAIN_LD
    export AR=$TOOLCHAIN_AR
    export RANLIB=$TOOLCHAIN_RANLIB

    if [ -z "$CC" ]; then
        export -n CC
    fi
    if [ -z "$CXX" ]; then
        export -n CXX
    fi
    if [ -z "$FORTRAN" ]; then
        export -n FORTRAN
    fi
    if [ -z "$LD" ]; then
        export -n LD
    fi
    if [ -z "$AR" ]; then
        export -n AR
    fi
    if [ -z "$RANLIB" ]; then
        export -n RANLIB
    fi


    export LDFLAGS="-L$ENVDEPS_PACKET_DIR/lib -L$ENVDEPS_PACKET_DIR/lib64 $TOOLCHAIN_LDFLAGS"
    export CFLAGS="-I$ENVDEPS_PACKET_DIR/include $TOOLCHAIN_CFLAGS"
    export CPPFLAGS="-I$ENVDEPS_PACKET_DIR/include $TOOLCHAIN_CPPFLAGS"
    export CXXFLAGS="-I$ENVDEPS_PACKET_DIR/include $TOOLCHAIN_CXXFLAGS"
    export PKG_CONFIG_PATH="$ENVDEPS_PACKET_DIR/lib/pkgconfig:$ENVDEPS_PACKET_DIR/share/pkgconfig:$TOOLCHAIN_PKG_CONFIG_PATH"
    export PKG_CONFIG_LIBDIR="$ENVDEPS_PACKET_DIR/lib:$TOOLCHAIN_PKG_CONFIG_LIBDIR"
    export PKG_CONFIG_SYSROOT_DIR="/"
    export XDG_DATA_DIRS="$ENVDEPS_PACKET_DIR/share:$TOOLCHAIN_XDG_DATA_DIRS"
    export ACLOCAL_PATH="$ENVDEPS_PACKET_DIR/share/aclocal:$TOOLCHAIN_ACLOCAL_PATH"
    export CMAKE_INCLUDE_PATH="$ENVDEPS_PACKET_DIR/include:$TOOLCHAIN_CMAKE_INCLUDE_PATH"  
    export CMAKE_LIBRARY_PATH="$ENVDEPS_PACKET_DIR/lib:$ENVDEPS_PACKET_DIR/lib64:$TOOLCHAIN_CMAKE_LIBRARY_PATH"  
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

	local PREV_HASH=
	if [ "$COMPARE_RESULTS" = "compare_results" ]; then
		if check_packet_function $NAME $FUNC; then
			PREV_HASH=`md5 "$FUNC_CURRENT_PACKET_DIR"` 
			[ ! $? -eq 0 ] && return 1
		fi
    else
   		set_undone_silent $NAME $FUNC
	fi

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

	if [ ! -z "$PREV_HASH" ]; then
		local HASH=`md5 "$FUNC_CURRENT_PACKET_DIR"` 
		[ ! $? -eq 0 ] && return 1
		if [ "$HASH" = "$PREV_HASH" ]; then
			message "$NAME $FUNC - not changed"
			return 0
		fi
	fi

    set_done $NAME $FUNC
}

foreach_deps() {
    local NAME=$1
    local FUNC=$2
    local RECURSIVE=$3
    local NATIVE=$4
    local WAS_NATIVE=$IS_NATIVE
    
	source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
    [ ! $? -eq 0 ] && return 1
    if [ ! -z "$WAS_NATIVE" ]; then
        DEPS="$DEPS $DEPS_NATIVE"
        DEPS_NATIVE=
    fi
        
    local CURRENT_DEPS=$DEPS
    local CURRENT_DEPS_NATIVE=$DEPS_NATIVE
    local PROCESS_SELF=""
    if [ "$NATIVE" = "native" ]; then
        CURRENT_DEPS=$DEPS_NATIVE
        if [ ! -z "$TOOLCHAIN_HOST" ]; then
            PROCESS_SELF="process_self"
        fi
    fi
    
    for DEP in $CURRENT_DEPS; do
        if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" -o "$PROCESS_SELF" = "process_self" ]; then
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

    if [ "$RECURSIVE" = "recursive" ]; then
        for DEP in $CURRENT_DEPS_NATIVE; do
            if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" -o ! -z "$TOOLCHAIN_HOST" ]; then
                local DEP_LOCAL=$DEP 
                if ! native foreach_deps "$DEP_LOCAL" "$FUNC" "$RECURSIVE"; then
                    return 1
                fi
                if ! native "$FUNC" "$DEP_LOCAL" "$NAME"; then
                    return 1
                fi
            fi
        done
    fi
}

set_toolchain() {
    if [ "$1" = "native" ]; then
        IS_NATIVE=1
        if [ ! "$2" = "silent" ]; then
            echo " --- set toolchain $NATIVE_PLATFORM-$NATIVE_ARCH (native)"
        fi
        source $NATIVE_TOOLCHAIN_SCRIPT
    else
        IS_NATIVE=
        if [ ! "$2" = "silent" ]; then
            echo " --- set toolchain $PLATFORM-$ARCH (target)"
        fi
        source $NATIVE_TOOLCHAIN_SCRIPT
        source $TOOLCHAIN_SCRIPT
    fi
}

is_complete() {
    local NAME=$1
    local FUNC=$2

    local WAS_NATIVE=$IS_NATIVE
    local WAS_PLATFORM=$PLATFORM
    local WAS_ARCH=$ARCH
    local WAS_PACKET_DIR=$PACKET_DIR
    local PROCESS_SELF=""
    if [ ! -z "$TOOLCHAIN_HOST" ]; then
        PROCESS_SELF="process_self"
    fi

    local SUBFUNCS_VAR_NAME=FUNC_DEPS_$FUNC
    local SUBFUNCS=${!SUBFUNCS_VAR_NAME}
    local COMPLETION_KEY="$PLATFORM:$ARCH:$NAME:$FUNC"
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
    if [ ! -z "$WAS_NATIVE" ]; then
        DEPS="$DEPS $DEPS_NATIVE"
        DEPS_NATIVE=
    fi

    local FAIL=
    local CURRENT_DEPS="$DEPS"
    local CURRENT_DEPS_NATIVE="$DEPS_NATIVE"
    for SUBFUNC in $SUBFUNCS; do
        local SUBFUNC_LOCAL=$SUBFUNC
        if [ "${SUBFUNC_LOCAL:0:2}" = "--" ]; then
            if [ ! -z "$CURRENT_DEPS_NATIVE" ]; then
                SUBFUNC_LOCAL=${SUBFUNC_LOCAL:2}
                if [ -z "$WAS_NATIVE" ]; then
                    set_toolchain "native" "silent"
                    PLATFORM=$NATIVE_PLATFORM
                    ARCH=$NATIVE_ARCH
                    PACKET_DIR=$NATIVE_PACKET_DIR
                fi
                for DEP in $CURRENT_DEPS_NATIVE; do
                    if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" -o "$PROCESS_SELF" = "process_self" ]; then
                        local DEP_LOCAL=$DEP
                        if ! is_complete $DEP_LOCAL $SUBFUNC_LOCAL; then
                            FAIL=1
                            break
                        fi
                        if [ "$WAS_PACKET_DIR/$NAME/$FUNC.done" -ot "$PACKET_DIR/$DEP_LOCAL/$SUBFUNC_LOCAL.done" ]; then
                            FAIL=1
                            break
                        fi
                    fi
                done
                if [ -z "$WAS_NATIVE" ]; then
                    PLATFORM=$WAS_PLATFORM
                    ARCH=$WAS_ARCH
                    PACKET_DIR=$WAS_PACKET_DIR
                    set_toolchain "" "silent"
                fi
                if [ ! -z "$FAIL" ]; then
                    return 1
                fi
            fi
        elif [ "${SUBFUNC_LOCAL:0:1}" = "-" ]; then
            SUBFUNC_LOCAL=${SUBFUNC_LOCAL:1}
            for DEP in $CURRENT_DEPS; do
                if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" ]; then
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
	
    local WAS_NATIVE=$IS_NATIVE
    local WAS_PLATFORM=$PLATFORM
    local WAS_ARCH=$ARCH
    local WAS_PACKET_DIR=$PACKET_DIR
    local PROCESS_SELF=""
    if [ ! -z "$TOOLCHAIN_HOST" ]; then
        PROCESS_SELF="process_self"
    fi

    local SUBFUNCS_VAR_NAME=FUNC_DEPS_$FUNC
    local SUBFUNCS=${!SUBFUNCS_VAR_NAME}
	
    source $INCLUDE_SCRIPT_DIR/inc-pkall-none.sh
    [ ! $? -eq 0 ] && return 1
    source "$PACKET_SCRIPT_DIR/$NAME.sh"
    [ ! $? -eq 0 ] && return 1
    if [ ! -z "$WAS_NATIVE" ]; then
        DEPS="$DEPS $DEPS_NATIVE"
        DEPS_NATIVE=
    fi
    local FAIL=
    local CURRENT_DEPS="$DEPS"
    local CURRENT_DEPS_NATIVE="$DEPS_NATIVE"
    for SUBFUNC in $SUBFUNCS; do
        local SUBFUNC_LOCAL=$SUBFUNC
        if [ "${SUBFUNC_LOCAL:0:2}" = "--" ]; then
            if [ ! -z "$CURRENT_DEPS_NATIVE" ]; then
                SUBFUNC_LOCAL=${SUBFUNC_LOCAL:2}
                if [ -z "$WAS_NATIVE" ]; then
                    set_toolchain "native"
                    PLATFORM=$NATIVE_PLATFORM
                    ARCH=$NATIVE_ARCH
                    PACKET_DIR=$NATIVE_PACKET_DIR
                fi
                for DEP in $CURRENT_DEPS_NATIVE; do
                    if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" -o "$PROCESS_SELF" = "process_self" ]; then
                        if ! $SUBFUNC_LOCAL $DEP; then
                            FAIL=1
                            break
                        fi
                    fi
                done
                if [ -z "$WAS_NATIVE" ]; then
                    PLATFORM=$WAS_PLATFORM
                    ARCH=$WAS_ARCH
                    PACKET_DIR="$WAS_PACKET_DIR"
                    set_toolchain
                fi
                if [ ! -z "$FAIL" ]; then
                    return 1
                fi
            fi
        elif [ "${SUBFUNC_LOCAL:0:1}" = "-" ]; then
            SUBFUNC_LOCAL=${SUBFUNC_LOCAL:1}
            for DEP in $CURRENT_DEPS; do
                if [ ! -z "$DEP" ] && [ "$DEP" != "$NAME" ]; then
                    if ! $SUBFUNC_LOCAL $DEP; then
                        return 1
                    fi
                fi
            done 
        elif ! $SUBFUNC_LOCAL $NAME; then
            return 1
        fi
    done
    
    if [ ! -z "$CLEAN_BEFORE_DO" ]; then
        if ! clean_packet_directory $NAME $FUNC; then
            return 1
        fi
    fi
}

add_envdeps() {
	if ! copy "$PACKET_DIR/$1/env" "$PACKET_DIR/$2/envdeps"; then
	    return 1
	fi
}

add_envdeps_native() {
    if ! copy "$PACKET_DIR/$1/env_native" "$PACKET_DIR/$2/envdeps_native"; then
        return 1
    fi
}

add_envdeps_native_cross() {
    if ! copy "$NATIVE_PACKET_DIR/$1/env" "$PACKET_DIR/$2/envdeps_native"; then
        return 1
    fi
}

add_envdeps_release() {
    if ! copy "$PACKET_DIR/$1/env_release" "$PACKET_DIR/$2/envdeps_release"; then
        return 1
    fi
}

# functions

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

envdeps_native() {
    local NAME=$1
    is_complete $NAME envdeps_native && return 0 
    prepare     $NAME envdeps_native || return 1

    message "$NAME envdeps_native"
    try_do_nothing $NAME envdeps_native && return 0

    clean_packet_directory_silent $NAME envdeps_native
    mkdir -p "$PACKET_DIR/$NAME/envdeps_native"
    if ! foreach_deps $NAME add_envdeps_native; then
        return 1
    fi
    if ! foreach_deps $NAME add_envdeps_native_cross "" "native"; then
        return 1
    fi
    set_done $NAME envdeps_native
}

build() {
    local NAME=$1
    is_complete $NAME build && return 0
    prepare     $NAME build || return 1
    call_packet_function $NAME build prepare_build || return 1
}

license() {
    local NAME=$1
    is_complete $NAME license && return 0
    prepare     $NAME license || return 1
    call_packet_function $NAME license prepare_license || return 1
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
    copy "$PACKET_DIR/$NAME/envdeps" "$PACKET_DIR/$NAME/env" || return 1
    copy "$PACKET_DIR/$NAME/install" "$PACKET_DIR/$NAME/env" || return 1

    set_done $NAME env
}

env_native() {
    local NAME=$1
    is_complete $NAME env_native && return 0
    prepare     $NAME env_native || return 1

    message "$NAME env_native"
    try_do_nothing $NAME env_native && return 0
            
    clean_packet_directory_silent $NAME env_native
    mkdir -p "$PACKET_DIR/$NAME/env_native"
    if ! copy "$PACKET_DIR/$NAME/envdeps_native" "$PACKET_DIR/$NAME/env_native"; then
        return 1
    fi
    set_done $NAME env_native
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
    copy "$PACKET_DIR/$NAME/envdeps_release" "$PACKET_DIR/$NAME/env_release" || return 1
    copy "$PACKET_DIR/$NAME/install_release" "$PACKET_DIR/$NAME/env_release" || return 1

    set_done $NAME env_release
}


#############

clean_download() {
    clean_packet_directory $1 download
}

clean_unpack() {
    clean_packet_directory $1 unpack
}

clean_envdeps() {
    clean_packet_directory $1 envdeps
}

clean_envdeps_native() {
    clean_packet_directory $1 envdeps_native
}

clean_build() {
    clean_packet_directory $1 build
}

clean_license() {
    clean_packet_directory $1 license
}

clean_install() {
    clean_packet_directory $1 install
}

clean_env() {
    clean_packet_directory $1 env
}

clean_env_native() {
    clean_packet_directory $1 env_native
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
    clean_license $1
    clean_install $1
    clean_install_release $1
    clean_envdeps $1
    clean_envdeps_native $1
    clean_env $1
    clean_env_native $1
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

set_undone_envdeps_native() {
    set_undone $1 envdeps_native
}

set_undone_build() {
    set_undone $1 build
}

set_undone_install() {
    set_undone $1 install
}

set_undone_license() {
    set_undone $1 license
}

set_undone_env() {
    set_undone $1 env
}

set_undone_env_native() {
    set_undone $1 env_native
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
    set_undone_license $1
    set_undone_install $1
    set_undone_install_release $1
    set_undone_envdeps $1
    set_undone_envdeps_native $1
    set_undone_env $1
    set_undone_env_native $1
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
    if ! foreach_deps "$2" "$1" "recursive" "native"; then
        return 1
    fi
    if ! "$1" "$2"; then
        return 1
    fi
}

shell() {
	echo "Set environment for $1"
    set_environment_vars $1
    cd $PACKET_DIR/$1
    if [ -z "${*:2}" ]; then
    	/bin/bash -i
	else
		"${@:2}"
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

force() {
    FORCE=1
    "$@"
}

clean_before_do() {
	CLEAN_BEFORE_DO=1
    "$@"
}

native() {
    local ARGS="$@"
    local LOCAL_ERROR=0
    if [ ! -z "$IS_NATIVE" ]; then
        $ARGS
    else
        local WAS_PLATFORM=$PLATFORM
        local WAS_ARCH=$ARCH
        local WAS_PACKET_DIR=$PACKET_DIR

        set_toolchain "native"
        PLATFORM=$NATIVE_PLATFORM
        ARCH=$NATIVE_ARCH
        PACKET_DIR=$NATIVE_PACKET_DIR
        if [ ! -z "$NAME" ]; then
            set_environment_vars $NAME
        fi

        $ARGS
        LOCAL_ERROR=$?

        PLATFORM=$WAS_PLATFORM
        ARCH=$WAS_ARCH
        PACKET_DIR=$WAS_PACKET_DIR
        set_toolchain
        if [ ! -z "$NAME" ]; then
            set_environment_vars $NAME
        fi
    fi
    return $LOCAL_ERROR
}

native_at_place() {
    local ARGS="$@"
    local LOCAL_ERROR=0
    if [ ! -z "$IS_NATIVE" ]; then
        $ARGS
    else
        local WAS_PLATFORM=$PLATFORM
        local WAS_ARCH=$ARCH

        set_toolchain "native"
        PLATFORM=$NATIVE_PLATFORM
        ARCH=$NATIVE_ARCH
        if [ ! -z "$NAME" ]; then
            set_environment_vars $NAME
        fi

        $ARGS
        LOCAL_ERROR=$?

        PLATFORM=$WAS_PLATFORM
        ARCH=$WAS_ARCH
        set_toolchain
        if [ ! -z "$NAME" ]; then
            set_environment_vars $NAME
        fi
    fi
    return $LOCAL_ERROR
}

foreach_packet() {
    local COMMAND=$1
    local FILE=
    ls -1 "$PACKET_SCRIPT_DIR" | grep -e \\.sh$ | while read FILE; do
        if ! $COMMAND "${FILE:0:-3}" ${@:2}; then
            return 1
        fi
    done
}


set_toolchain
"$@"

