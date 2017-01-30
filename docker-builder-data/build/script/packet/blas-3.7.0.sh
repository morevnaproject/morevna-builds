DEPS=""

PK_DIRNAME="BLAS-3.7.0"
PK_ARCHIVE="blas-3.7.0.tgz"
PK_URL="http://www.netlib.org/blas/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-default.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	if ! make; then
		return 1
	fi
}

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/lib"
	if ! cp --remove-destination -r "$BUILD_PACKET_DIR/$PK_DIRNAME/blas_LINUX.a" "$INSTALL_PACKET_DIR/lib/libblas.a"; then
		return 1
	fi
}
