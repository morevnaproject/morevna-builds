DEPS=""

PK_DIRNAME="BLAS-3.7.0"
PK_ARCHIVE="blas-3.7.0.tgz"
#PK_URL="http://www.netlib.org/blas/$PK_ARCHIVE"
PK_URL="https://software.morevnaproject.org/builder/src/blas/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if [ "$PLATFORM" = "win" ]; then
		FORTRAN=${HOST}-gfortran
	else
		FORTRAN=gfortran
	fi

rm -f make.inc
cat > make.inc << EOF
SHELL     = /bin/sh
FORTRAN   = ${FORTRAN}
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
