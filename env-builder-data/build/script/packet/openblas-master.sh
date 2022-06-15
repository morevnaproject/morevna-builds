DEPS=""

PK_DIRNAME="OpenBLAS"
PK_URL="https://github.com/xianyi/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="tags/v0.2.19"
PK_LICENSE_FILES="LICENSE CONTRIBUTORS.md BACKERS.md"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"

    pkhelper_patch . getarch.c
    if [ "$PLATFORM" = "win" ]; then
        pkhelper_patch kernel/x86    KERNEL.generic
        pkhelper_patch kernel/x86_64 KERNEL.generic
    fi

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
HOSTCC                     = PATH=${INITIAL_PATH} /usr/local/bin/gcc
USE_THREAD                 = 1
NUM_THREADS                = 24
BUILD_LAPACK_DEPRECATED    = 1
NO_WARMUP                  = 1
NO_AFFINITY                = 1
COMMON_PROF                = -pg
EOF

    make -j${THREADS} libs netlib shared || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! PREFIX=${INSTALL_PACKET_DIR} make install; then
        return 1
    fi
}
