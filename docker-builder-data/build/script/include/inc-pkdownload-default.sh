
# PK_URL
# PK_ARCHIVE

pkdownload() {
    wget -c "$PK_URL" -O "$PK_ARCHIVE" \
     || curl -L "$PK_URL" -o "$PK_ARCHIVE" \
     || return 1
}
