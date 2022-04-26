DEPS="zlib-1.2.12"

PK_DIRNAME="libpng-1.6.26"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://download.sourceforge.net/libpng/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_prebuild() {
    pkhelper_patch . libpng.pc.in
}
