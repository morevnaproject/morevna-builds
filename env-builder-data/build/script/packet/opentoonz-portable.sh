DEPS="opentoonz-master"

pkinstall_release() {
    # create temporary dir
    rm -rf "$INSTALL_RELEASE_PACKET_DIR/portable"
    mkdir -p "$INSTALL_RELEASE_PACKET_DIR/portable"
    cd "$INSTALL_RELEASE_PACKET_DIR/portable" || return 1

    # copy files
    copy "$ENVDEPS_RELEASE_PACKET_DIR" "./" || return 1

    # get version
    local LOCAL_VERSION_FULL=$(cat $ENVDEPS_RELEASE_PACKET_DIR/version-opentoonz-*)
    local LOCAL_VERSION=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 1)
    local LOCAL_VERSION2=$(echo "$LOCAL_VERSION" | cut -d . -f -2)
    local LOCAL_COMMIT=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 2)

    # copy NSIS configuration
    cp "$FILES_PACKET_DIR/opentoonz.bat" "./" || return 1

    # portable stuff
    mv "./share/opentoonz/stuff" "./portablestuff" || return 1

    # let's go
    zip -r "../opentoonz-${LOCAL_VERSION}-${LOCAL_COMMIT:0:5}.zip" ./ || return 1
    
    # remove temporary dir
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    rm -rf "portable"
}
