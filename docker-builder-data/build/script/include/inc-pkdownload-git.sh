
# PK_URL
# PK_DIRNAME
# PK_GIT_OPTIONS

pkdownload() {
    if [ -d "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME/.git" ]; then
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME"
        git fetch || return 1
        git stash || return 1
        git reset --hard origin/testing || return 1
    else
        if ! git clone "$PK_URL" $PK_GIT_OPTIONS; then
            return 1
        fi
    fi
}
