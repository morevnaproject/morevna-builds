DEPS="zlib-1.2.13 bzip2-1.0.6 jpeg-9b jasper-1.900.13 png-1.6.26 tiff-4.0.6 exiv2-0.25 lensfun-0.3.95 lcms2-2.12 gtk-2.20.1 gtkimageview-1.6.4"

PK_DIRNAME="ufraw-0.22"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://sourceforge.net/projects/ufraw/files/ufraw/ufraw-0.22/$PK_ARCHIVE"
PK_CFLAGS="-fpermissive"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh



pkhook_prebuild() {
    cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/dcraw.cc" "dcraw.cc" || return 1
    patch -p1 -i "$FILES_PACKET_DIR/dcraw.patch" || return 1
}

