
# PK_VERSION
# PK_DIRNAME

pkunpack() {
    if ! (copy "$DOWNLOAD_PACKET_DIR" "$UNPACK_PACKET_DIR" \
     && rm -f -r "$UNPACK_PACKET_DIR/$PK_DIRNAME/.git"); then
        return 1
    fi

	if [ -z "$PK_VERSION" ]; then
		PK_VERSION="$(echo "$NAME" | cut -d'-' -f 2-)"
	fi
	cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME"
	local COMMIT=`git rev-parse HEAD`
	[ ! $? -eq 0 ] && return 1
	echo "$PK_VERSION-$COMMIT" > "$UNPACK_PACKET_DIR/version-$NAME"
	[ ! $? -eq 0 ] && return 1
   	return 0
}
