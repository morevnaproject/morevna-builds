DEPS=""

PK_VERSION="0.3.3"
PK_DIRNAME="OpenBLAS-$PK_VERSION"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://github.com/xianyi/OpenBLAS/archive/refs/tags/v$PK_VERSION.tar.gz"
PK_LICENSE_FILES="LICENSE CONTRIBUTORS.md BACKERS.md"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"

    #if [ "$PLATFORM" = "linux" ]; then
    #    pkhelper_patch . getarch.c
    #fi
    if [ "$PLATFORM" = "win" ]; then
        pkhelper_patch kernel/x86    KERNEL.generic
        pkhelper_patch kernel/x86_64 KERNEL.generic
    fi

    LOCAL_BINARY_OPTION="BINARY=$ARCH"
    
    if [ "$PLATFORM" = "win" ]; then
		export FORTRAN=${HOST}-gfortran
		export PK_CC=${HOST}-gcc
	else
		export FORTRAN=gfortran
		export PK_CC=gcc
	fi

rm -f Makefile.rule
cat > Makefile.rule << EOF
PREFIX                     = ${INSTALL_PACKET_DIR}
VERSION                    = 0.3.3
CC                         = ${PK_CC}
FC                         = ${FORTRAN:-gfortran}
TARGET                     = P2
${LOCAL_BINARY_OPTION}
HOSTCC                     = PATH=${INITIAL_PATH} /usr/bin/gcc
USE_THREAD                 = 1
NUM_THREADS                = 24
BUILD_LAPACK_DEPRECATED    = 1
NO_WARMUP                  = 1
NO_AFFINITY                = 1
COMMON_PROF                = -pg
DYNAMIC_ARCH = 1
EOF

    make -j${THREADS} libs netlib shared || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! PREFIX=${INSTALL_PACKET_DIR} make install; then
        return 1
    fi
}
