DEPS="synfigstudio-master"

PK_PYTHON_DIRNAME="python"
PK_PYTHON_ARCHIVE="portable-python-3.2.5.1.zip"
PK_PYTHON_URL="https://download.tuxfamily.org/synfig/packages/sources/$PK_PYTHON_ARCHIVE"

# download portable python and pass downloaded files through all build phases
pkdownload() {
    wget -c --no-check-certificate "$PK_PYTHON_URL" -O "$PK_PYTHON_ARCHIVE" || return 1
}

pkunpack() {
    unzip "$DOWNLOAD_PACKET_DIR/$PK_PYTHON_ARCHIVE" || return 1
}

pkinstall() {
    copy "$BUILD_PACKET_DIR" "$INSTALL_PACKET_DIR" || return 1
}

pkinstall_release() {
    # create temporary dir
    rm -rf "$INSTALL_RELEASE_PACKET_DIR/portable"
    mkdir -p "$INSTALL_RELEASE_PACKET_DIR/portable"
    cd "$INSTALL_RELEASE_PACKET_DIR/portable" || return 1

    # copy files
    copy "$ENVDEPS_RELEASE_PACKET_DIR/bin/lib/" "./bin/lib/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/bin/share/" "./bin/share/" || return 1
    cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/bin/"*.dll "./bin/" || return 1
    for FILE in animate composite convert ffmpeg ffprobe gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders gio-querymodules melt sox synfig synfigstudio; do
        cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/bin/${FILE}.exe" "./bin/" || return 1
    done
    copy "$ENVDEPS_RELEASE_PACKET_DIR/etc/" "./etc/" || return 1
    [ -d "./lib/gdk-pixbuf-2.0/2.10.0/loaders" ] || mkdir -p "./lib/gdk-pixbuf-2.0/2.10.0/loaders"
    cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/lib/gdk-pixbuf-2.0/2.10.0/loaders/"*.dll "./lib/gdk-pixbuf-2.0/2.10.0/loaders" || return 1
    [ -d "./lib/gtk-3.0/3.0.0/immodules" ] || mkdir -p "./lib/gtk-3.0/3.0.0/immodules"
    cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/lib/gtk-3.0/3.0.0/immodules/"*.dll "./lib/gtk-3.0/3.0.0/immodules" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/lib/ImageMagick-6.8.7/" "./lib/ImageMagick-6.8.7/" || return 1
    [ -d "./lib/synfig/modules" ] || mkdir -p "./lib/synfig/modules"
    cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/lib/synfig/modules/"*.dll "./lib/synfig/modules" || return 1
    cp -rf "$ENVDEPS_RELEASE_PACKET_DIR/lib/"*.dll "./lib" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/license/" "./license/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/fontconfig/" "./share/fontconfig/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/glib-2.0/schemas/" "./share/glib-2.0/schemas/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/gtk-3.0/" "./share/gtk-3.0/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/icons/" "./share/icons/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/ImageMagick-6/" "./share/ImageMagick-6/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/locale/" "./share/locale/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/mime/" "./share/mime/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/mime-info/" "./share/mime-info/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/pixmaps/" "./share/pixmaps/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/synfig/" "./share/synfig/" || return 1
    copy "$ENVDEPS_RELEASE_PACKET_DIR/share/themes/" "./share/xml/" || return 1
    
    # move examples
    mv "./share/synfig/examples" "./" || return 1
    
    # add portable python
    copy "$INSTALL_PACKET_DIR/$PK_PYTHON_DIRNAME" "./python" || return 1

    # get version
    local LOCAL_VERSION_FULL=$(cat $ENVDEPS_RELEASE_PACKET_DIR/version-synfigstudio-*)
    local LOCAL_VERSION=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 1)
    local LOCAL_VERSION2=$(echo "$LOCAL_VERSION" | cut -d . -f -2)
    local LOCAL_COMMIT=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 2)

    # copy NSIS configuration
    cp "$FILES_PACKET_DIR/synfigstudio.bat" "./" || return 1

    # let's go
    zip -r "../synfigstudio-${LOCAL_VERSION}-${LOCAL_COMMIT:0:5}.zip" ./ || return 1
    
    # remove temporary dir
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    rm -rf "portable"
}
