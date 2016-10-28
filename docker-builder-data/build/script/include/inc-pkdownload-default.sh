
# PK_URL
# PK_ARCHIVE

pkdownload() {
if ! wget -c --no-check-certificate "$PK_URL" -O $PK_ARCHIVE; then
        return 1
    fi
}
