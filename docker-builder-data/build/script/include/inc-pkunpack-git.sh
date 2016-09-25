
# PK_DIRNAME

pkunpack() {
    if ! (copy "$DOWNLOAD_PACKET_DIR" "$UNPACK_PACKET_DIR" \
     && rm -f -r "$UNPACK_PACKET_DIR/$PK_DIRNAME/.git"); then
        return 1
    fi
}
