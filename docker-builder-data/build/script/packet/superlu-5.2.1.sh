DEPS="blas-3.7.0"

PK_DIRNAME="SuperLU_5.2.1"
PK_ARCHIVE="superlu_5.2.1.tar.gz"
PK_URL="http://crd-legacy.lbl.gov/~xiaoye/SuperLU/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	
	if ! (cp --remove-destination "$FILES_PACKET_DIR/mc64ad.c" "$BUILD_PACKET_DIR/$PK_DIRNAME/SRC/" \
	 && cp --remove-destination "$FILES_PACKET_DIR/make.inc" "$BUILD_PACKET_DIR/$PK_DIRNAME/"); then
		return 1
	fi

	if ( ! HOME=$BUILD_PACKET_DIR make); then
		return 1
	fi
}

pkinstall() {
	cp --remove-destination -r "$BUILD_PACKET_DIR/$PK_DIRNAME/lib" "$INSTALL_PACKET_DIR" || return 1
	mkdir -p "$INSTALL_PACKET_DIR/include/superlu-5.2.1"
	cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/SRC/*.h "$INSTALL_PACKET_DIR/include/superlu-5.2.1" || return 1
}