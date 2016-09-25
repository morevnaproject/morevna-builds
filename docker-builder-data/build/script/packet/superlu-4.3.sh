DEPS="blas-3.6.0"

PK_DIRNAME="SuperLU_4.3"
PK_ARCHIVE="superlu_4.3.tar.gz"
PK_URL="http://crd-legacy.lbl.gov/~xiaoye/SuperLU/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	
	if ! (cp -f "$FILES_PACKET_DIR/mc64ad.c" "$BUILD_PACKET_DIR/$PK_DIRNAME/SRC/" \
	 && cp -f "$FILES_PACKET_DIR/make.inc" "$BUILD_PACKET_DIR/$PK_DIRNAME/"); then
		return 1
	fi

	if ( ! HOME=$BUILD_PACKET_DIR make); then
		return 1
	fi
}

pkinstall() {
	if ! cp -r "$BUILD_PACKET_DIR/$PK_DIRNAME/lib" "$INSTALL_PACKET_DIR"; then
		return 1
	fi
}
