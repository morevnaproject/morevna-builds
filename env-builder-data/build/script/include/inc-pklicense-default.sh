
# PK_DIRNAME
# PK_LICENSE_FILES

pklicense() {
    local TARGET="$LICENSE_PACKET_DIR/license-$NAME"
    rm -f "$TARGET"

    local FILES=" \
        AUTHORS \
        AUTHORS.txt \
        COPYING \
        COPYING.txt \
        LICENSE \
        LICENSE.txt \
        License.txt \
        COPYRIGHT \
        Copyright \
        Copyright.txt \
        CREDITS \
        CREDITS.txt "
    if [ ! -z "$PK_LICENSE_FILES" ]; then
        FILES="$PK_LICENSE_FILES"
    fi
    
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    local FILE=
    for FILE in $FILES; do
        if [ -f "$FILE" ]; then
            add_license "$FILE" "$FILE" "$TARGET" || (echo "Cannot copy license file: $FILE"; return 1)
        elif [ -f "$FILES_PACKET_DIR/$FILE" ]; then
            add_license "$FILES_PACKET_DIR/$FILE" "" "$TARGET" || (echo "Cannot copy license file: $FILE"; return 1)
        elif [ ! -z "$PK_LICENSE_FILES" ]; then
            echo "Cannot copy license file: $FILE"
            return 1
        fi
    done

    if [ ! -f "$TARGET" ]; then
        echo "Cannot copy any license";
        return 1
    fi
    
    if ! pkhook_postlicense; then
        return 1
    fi
}
