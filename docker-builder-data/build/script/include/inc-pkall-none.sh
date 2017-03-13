DEPS=
DEPS_NATIVE=

PK_URL=
PK_VERSION=
PK_ARCHIVE=
PK_DIRNAME=
PK_CONFIGURE_OPTIONS=
PK_CFLAGS=
PK_CPPFLAGS=
PK_LDFLAGS=
PK_GIT_OPTIONS=

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


pkdownload() {
	return 0
}

pkunpack() {
	return 0
}

pkbuild() {
	return 0
}

pkinstall() {
	return 0
}

pkinstall_release() {
	return 0
}

pkhook_prebuild() {
    return 0
}

pkhook_postinstall_release() {
    return 0
}
