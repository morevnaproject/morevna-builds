
# PK_URL
# PK_DIRNAME
# PK_GIT_OPTIONS

pkdownload() {
    if [ -d "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME/.git" ]; then
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME"
        if ! git pull; then
            return 1
        fi
    else
        if ! git clone "$PK_URL" $PK_GIT_OPTIONS; then
            return 1
        fi
    fi
}
