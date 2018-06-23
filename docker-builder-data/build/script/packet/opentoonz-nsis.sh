DEPS="opentoonz-master"
DEPS_NATIVE="nsis-2.50"

pkfunc_register_file() {
    local FILE=$1
    local WIN_FILE=$(echo "$FILE" | sed "s|\/|\\\\|g")
    ! [ -L "$FILE" ] || return 0

    if [ "${FILE:0:8}" = "./files-" ]; then
        true # skip
    elif [ "${FILE:0:24}" = "./share/opentoonz/stuff/" ]; then
        if [ -d "$FILE" ]; then
            echo "CreateDirectory \"\$STUFFDIR\\${WIN_FILE:24}\""   >> "files-stuff-install.nsh"
            foreachfile "$FILE" pkfunc_register_file
            echo "RMDir \"\$STUFFDIR\\${WIN_FILE:24}\""             >> "files-stuff-uninstall.nsh"
        else
            echo "File \"/oname=${WIN_FILE:24}\" \"${WIN_FILE:2}\"" >> "files-stuff-install.nsh"
            echo "Delete \"\$STUFFDIR\\${WIN_FILE:24}\""            >> "files-stuff-uninstall.nsh"
        fi
    elif [ "${FILE:0:2}" = "./" ]; then
        if [ -d "$FILE" ]; then
            echo "CreateDirectory \"\$INSTDIR\\${WIN_FILE:2}\""     >> "files-install.nsh"
            foreachfile "$FILE" pkfunc_register_file
            echo "RMDir \"\$INSTDIR\\${WIN_FILE:2}\""               >> "files-uninstall.nsh" 
        else
            echo "File \"/oname=${WIN_FILE:2}\" \"${WIN_FILE:2}\""  >> "files-install.nsh"
            echo "Delete \"\$INSTDIR\\${WIN_FILE:2}\""              >> "files-uninstall.nsh" 
        fi
    else
        foreachfile $FILE pkfunc_register_file
    fi
}

pkinstall_release() {
    # create temporary dir
    rm -rf "$INSTALL_RELEASE_PACKET_DIR/installer"
    mkdir -p "$INSTALL_RELEASE_PACKET_DIR/installer"
    cd "$INSTALL_RELEASE_PACKET_DIR/installer" || return 1

    # copy files
    copy "$ENVDEPS_RELEASE_PACKET_DIR" "./" || return 1

    # get version
    local LOCAL_VERSION_FULL=$(cat $ENVDEPS_RELEASE_PACKET_DIR/version-opentoonz-*)
    local LOCAL_VERSION=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 1)
    local LOCAL_VERSION2=$(echo "$LOCAL_VERSION" | cut -d . -f -2)
    local LOCAL_COMMIT=$(echo "$LOCAL_VERSION_FULL" | cut -d - -f 2)

    # create file lists
    echo "create file lists"
    pkfunc_register_file .
    echo "created"

    # copy NSIS configuration
    cp "$FILES_PACKET_DIR/opentoonz.nsi" "./" || return 1

    # create config.nsh (see opentoons.nsi)
    cat > config.nsh << EOF
!define PK_NAME         "OpenToonz" 
!define PK_NAME_FULL    "OpenToonz Morevna Edition (${ARCH}bit)"
!define PK_ARCH         "${ARCH}"
!define PK_VERSION      "${LOCAL_VERSION2}"
!define PK_VERSION_FULL "${LOCAL_VERSION}-${LOCAL_COMMIT:0:5}" 
!define PK_EXECUTABLE   "bin\\\${PK_NAME}_${LOCAL_VERSION2}.exe" 
!define PK_ICON         "bin\\toonz.ico" 
EOF

    # let's go
    makensis opentoonz.nsi || return 1

    # remove temporary dir
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    mv installer/*.exe ./ || return 1
    rm -rf "installer"
}
