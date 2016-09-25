
# PK_DIRNAME

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if ! make install; then
        return 1
    fi
}
