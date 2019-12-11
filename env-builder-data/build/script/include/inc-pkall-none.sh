DEPS=
DEPS_NATIVE=

vars_clear "PK_"

PK_URL=
PK_VERSION=
PK_ARCHIVE=
PK_DIRNAME=
PK_CONFIGURE_OPTIONS=
PK_CFLAGS=
PK_CPPFLAGS=
PK_LDFLAGS=
PK_GIT_CHECKOUT=
PK_LICENSE_FILES=

PK_CONFIGURE_OPTIONS_DEFAULT=

if [ ! -z "$HOST" ]; then
	PK_CONFIGURE_OPTIONS_DEFAULT=" \
	 $PK_CONFIGURE_OPTIONS_DEFAULT \
	 --host=$HOST "
fi

PK_CONFIGURE_OPTIONS_DEFAULT=" \
 $PK_CONFIGURE_OPTIONS_DEFAULT \
 --prefix=$INSTALL_PACKET_DIR \
 --disable-static \
 --enable-shared "


pkhelper_patch() {
    local FILE_PATH="$1"
    local FILE_NAME="$2"
    cp --remove-destination "$UNPACK_PACKET_DIR/$PK_DIRNAME/$FILE_PATH/$FILE_NAME" "$FILE_PATH/" || return 1
    patch "$FILE_PATH/$FILE_NAME" "$FILES_PACKET_DIR/$FILE_NAME.patch" || return 1
}


pkdownload() {
    return 0
}

pkunpack() {
    return 0
}

pkbuild() {
    return 0
}

pklicense() {
    return 0
}

pkinstall() {
    return 0
}

pkinstall_release() {
    return 0
}

pkhook_version() {
    echo "$NAME" | cut -d'-' -f 2-
}

pkhook_prebuild() {
    return 0
}

pkhook_postlicense() {
    return 0
}

pkhook_postinstall() {
    return 0
}

pkhook_postinstall_release() {
    return 0
}
