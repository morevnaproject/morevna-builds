DEPS=""

PK_DIRNAME="OpenBLAS"
PK_URL="https://github.com/xianyi/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
    local LOCAL_BINARY_OPTION=
    if [ "$ARCH" = "32" ]; then
        LOCAL_BINARY_OPTION="BINARY=$ARCH"
    fi

rm -f Makefile.rule
cat > Makefile.rule << EOF
PREFIX                     = ${INSTALL_PACKET_DIR}
VERSION                    = 0.2.20.dev
CC                         = ${CC:-gcc}
FC                         = ${FORTRAN:-gfortran}
TARGET                     = generic
${LOCAL_BINARY_OPTION}
HOSTCC                     = PATH=${INITIAL_PATH} /usr/bin/gcc
USE_THREAD                 = 1
NUM_THREADS                = 24
BUILD_LAPACK_DEPRECATED    = 1
NO_WARMUP                  = 1
NO_AFFINITY                = 1
COMMON_PROF                = -pg
EOF

    if ! make -j${THREADS}; then
        return 1
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! PREFIX=${INSTALL_PACKET_DIR} make install; then
        return 1
    fi
}
