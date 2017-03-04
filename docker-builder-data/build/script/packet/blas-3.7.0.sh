DEPS=""

PK_DIRNAME="BLAS-3.7.0"
PK_ARCHIVE="blas-3.7.0.tgz"
PK_URL="http://www.netlib.org/blas/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"

rm -f make.inc
cat > make.inc << EOF
SHELL     = /bin/sh
FORTRAN   = ${FORTRAN:-gfortran}
OPTS      = -O3
DRVOPTS   = \$(OPTS)
NOOPT     =
LOADER    = \$(FORTRAN)
LOADOPTS  =
ARCH      = ${AR:-ar}
ARCHFLAGS = cr
RANLIB    = ${RANLIB:-ranlib}
BLASLIB   = libblas.a
EOF
		
	make || return 1
}

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/lib"
	cp --remove-destination -r "$BUILD_PACKET_DIR/$PK_DIRNAME/libblas.a" "$INSTALL_PACKET_DIR/lib/" || return 1
}
