DEPS=""

PK_DIRNAME="AppImageKit"
PK_URL="https://github.com/probonopd/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkunpack-git.sh

pkdownload() {
    if [ -d "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME/.git" ]; then
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME" || return 1
        git fetch || return 1
        git reset --hard origin/$(git rev-parse --abbrev-ref HEAD) || return 1
        git submodule update || return 1
    else
        git clone "$PK_URL" $PK_GIT_OPTIONS || return 1
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME" || return 1
        git submodule init || return 1
        git submodule update || return 1
    fi
}

pkbuild() {
	cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
	if ! check_packet_function $NAME build.configure; then
		cp -p shared.c shared.c.tmp || return 1
		mv -f shared.c.tmp shared.c || return 1
		cp -p build.sh build.sh.tmp || return 1
		mv -f build.sh.tmp build.sh || return 1
		sed -i -e 's|archive3.h|archive.h|g' ./shared.c || return 1
		sed -i -e 's|archive_entry3.h|archive_entry.h|g' ./shared.c || return 1
		sed -i -e 's|-larchive3|-larchive|g' ./build.sh || return 1
		sed -i -e 's|git submodule|#git submodule|g' ./build.sh || return 1
		sed -i -e 's|wget -c|wget -c --no-check-certificate|g' ./build.sh || return 1
		sed -i -e 's|automake|#automake|g' ./build.sh || return 1
		set_done $NAME build.configure
	fi
	bash -ex ./build.sh || return 1
}

pkinstall() {
	mkdir -p "$INSTALL_PACKET_DIR/bin"
	cp --remove-destination $BUILD_PACKET_DIR/$PK_DIRNAME/build/* "$INSTALL_PACKET_DIR/bin/" || return 1
}
