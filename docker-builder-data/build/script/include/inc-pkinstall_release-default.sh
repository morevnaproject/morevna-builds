
pkinstall_release() {
    if ! copy "$INSTALL_PACKET_DIR" "$INSTALL_RELEASE_PACKET_DIR"; then
        return 1
    fi

    rm -rf "$INSTALL_RELEASE_PACKET_DIR/include"
    remove_recursive "$INSTALL_RELEASE_PACKET_DIR/lib" *.a
    remove_recursive "$INSTALL_RELEASE_PACKET_DIR/lib64" *.a
	rm -rf "$INSTALL_RELEASE_PACKET_DIR/share/aclocal"
	rm -rf "$INSTALL_RELEASE_PACKET_DIR/share/devhelp"
	rm -rf "$INSTALL_RELEASE_PACKET_DIR/share/doc"
	rm -rf "$INSTALL_RELEASE_PACKET_DIR/share/gtk-doc"
	rm -rf "$INSTALL_RELEASE_PACKET_DIR/share/man"
}
