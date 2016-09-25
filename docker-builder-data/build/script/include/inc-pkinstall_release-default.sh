
pkinstall_release() {
    if ! copy "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR"; then
        return 1
    fi
    rm -r -f "$INSTALL_RELEASE_PACKET_DIR/include"
}
