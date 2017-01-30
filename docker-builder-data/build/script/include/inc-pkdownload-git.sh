
# PK_URL
# PK_DIRNAME
# PK_GIT_OPTIONS

pkdownload() {
    if [ -d "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME/.git" ]; then
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME" || return 1
        git fetch || return 1
        git reset --hard origin/$(git rev-parse --abbrev-ref HEAD) || return 1
        git submodule init || true
        git submodule update || true
    else
        git clone "$PK_URL" $PK_GIT_OPTIONS || return 1
        cd "$DOWNLOAD_PACKET_DIR/$PK_DIRNAME" || return 1
        git submodule init || true
        git submodule update || true
    fi
}
