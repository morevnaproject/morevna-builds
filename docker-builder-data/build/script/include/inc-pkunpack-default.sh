
# PK_VERSION
# PK_ARCHIVE

pkunpack() {
	if [ ${PK_ARCHIVE: -7} == ".tar.gz" ]; then
    	if ! tar -xzf "$DOWNLOAD_PACKET_DIR/$PK_ARCHIVE"; then
        	return 1
    	fi
	elif [ ${PK_ARCHIVE: -7} == ".tgz" ]; then
    	if ! tar -xzf "$DOWNLOAD_PACKET_DIR/$PK_ARCHIVE"; then
        	return 1
    	fi
	else
    	if ! tar -xf "$DOWNLOAD_PACKET_DIR/$PK_ARCHIVE"; then
        	return 1
    	fi
	fi
	if [ ! -z "$PK_VERSION" ]; then
		echo "$PK_VERSION" > "$UNPACK_PACKET_DIR/version-$NAME"
		[ ! $? -eq 0 ] && return 1
	fi 
}