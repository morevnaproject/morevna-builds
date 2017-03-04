DEPS="blas-3.7.0"

PK_DIRNAME="SuperLU_5.2.1"
PK_ARCHIVE="superlu_5.2.1.tar.gz"
PK_URL="http://crd-legacy.lbl.gov/~xiaoye/SuperLU/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"

rm -f make.inc
cat > make.inc << EOF 	
SuperLUroot  = $BUILD_PACKET_DIR/$PK_DIRNAME
SUPERLULIB   = \$(SuperLUroot)/lib/libsuperlu.a
BLASDEF      = -DUSE_VENDOR_BLAS
BLASLIB      = \$(LDFLAGS) -lblas -lgfortran
TMGLIB       = libtmglib.a
LIBS         = \$(SUPERLULIB) \$(BLASLIB)
ARCH         = ${AR:-ar}
ARCHFLAGS    = cr
RANLIB       = ${RANLIB:-ranlib}
CC           = ${CC:-gcc}
CFLAGS       = -O3 -fPIC
NOOPTS       = -fPIC
FORTRAN      = ${FORTRAN:-gfortran}
FFLAGS       = -O2 -fPIC
LOADER       = \$(CC)
LOADOPTS     =
CDEFS        = -DAdd_
EOF
	
	cp --remove-destination "$FILES_PACKET_DIR/mc64ad.c" "$BUILD_PACKET_DIR/$PK_DIRNAME/SRC/" || return 1
	make lib || return 1
}

pkinstall() {
	cp --remove-destination -r "$BUILD_PACKET_DIR/$PK_DIRNAME/lib" "$INSTALL_PACKET_DIR" || return 1
	mkdir -p "$INSTALL_PACKET_DIR/include/superlu"
	cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/SRC/*.h "$INSTALL_PACKET_DIR/include/superlu" || return 1
}
