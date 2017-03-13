DEPS="opentoonz-master"

pkfunc_register_file() {
    local FILE=$1
    local WIN_FILE=$(echo "$FILE" | sed "s|\/|\\\\|g")
    ! [ -L "$FILE" ] || return 0

    if [ "${FILE:0:8}" = "./files-" ]; then
        true # skip
    elif [ "${FILE:0:24}" = "./share/opentoonz/stuff/" ]; then
        if [ -d "$FILE" ]; then
            echo "CreateDirectory \"\$STUFFDIR\\${WIN_FILE:24}\""   >> "files-stuff-install.nsh"
            foreachfile $FILE pkfunc_register_file
            echo "RMDir \"\$STUFFDIR\\${WIN_FILE:24}\""             >> "files-stuff-uninstall.nsh"
        else
            echo "File \"/oname=${WIN_FILE:24}\" \"${WIN_FILE:2}\"" >> "files-stuff-install.nsh"
            echo "Delete \"\$STUFFDIR\\${WIN_FILE:24}\""            >> "files-stuff-uninstall.nsh"
        fi
    elif [ "${FILE:0:2}" = "./" ]; then
        if [ -d "$FILE" ]; then
            echo "CreateDirectory \"\$INSTDIR\\${WIN_FILE:2}\""     >> "files-install.nsh"
            foreachfile $FILE pkfunc_register_file
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
    local LOCAL_VERSION=$(cat "$ENVDEPS_RELEASE_PACKET_DIR/version-opentoonz-master")

    # create file lists
    echo "create file lists"
    pkfunc_register_file .
    echo "created"

    # copy NSIS configuration
    cp "$FILES_PACKET_DIR/opentoonz.nsi" "./" || return 1
            
    # create config.nsh (see opentoons.nsi)
    cat > config.nsh << EOF
!define PK_NAME         "OpenToonz" 
!define PK_NAME_FULL    "OpenToonz"
!define PK_ARCH         "$ARCH"
!define PK_VERSION      "${LOCAL_VERSION:0:3}"
!define PK_VERSION_FULL "${LOCAL_VERSION:0:11}" 
!define PK_EXECUTABLE   "bin\\\${PK_NAME}_\${PK_VERSION}.exe" 
EOF

    # let's go
    makensis opentoonz.nsi || return 1

    # remove temporary dir
    cd "$INSTALL_RELEASE_PACKET_DIR" || return 1
    mv installer/*.exe ./ || return 1
    rm -rf "installer"
}
