# helpers

copy() {
    local SRC=$1
    local DEST=$2
    if [ -d "$SRC" ]; then
        if ! mkdir -p $DEST; then
            return 1
        fi
        if [ "$(ls -A $1)" ]; then
            if ! cp --remove-destination -rlP $SRC/* "$DEST/"; then
                return 1
            fi
        fi
    elif [ -f "$SRC" ]; then
        if ! (mkdir -p `dirname $DEST` && cp --remove-destination -l "$SRC" "$DEST"); then
            return 1
        fi
    else
        return 1
    fi
}

foreachfile() {
    local FILE=$1
    local COMMAND=$2
    if [ ! -x "$FILE" ]; then
        return 1
    fi
    if [ -d "$FILE" ]; then    
        ls -1 "$FILE" | while read SUBFILE; do
            if ! $COMMAND "$FILE/$SUBFILE" ${@:3}; then
                return 1
            fi
        done
    fi
}

readdir() {
    local FILE=$1
    if [ -d "$FILE" ]; then
        echo "directory begin"
        ls -1 "$1" | while read SUBFILE; do
            if [ "$SUBFILE" = ".git" ]; then
                continue
            fi
            if [[ "$SUBFILE" == *.po ]]; then
                continue
            fi
            local STAT=`stat -c%F:%a:%s "$FILE/$SUBFILE"`
            echo "$STAT:$SUBFILE"
            readdir "$FILE/$SUBFILE"
        done
        echo "directory end"
    else
        local MD5=`md5sum -b "$FILE"`
        echo "file:${MD5:0:32}"
    fi
}

md5() {
    local FILE=$1
    local MD5=`readdir "$FILE" | md5sum -b`
    echo "${MD5:0:32}"
}

remove_recursive() {
    local CURRENT_PATH="$1"
    local NEEDLE="$2"
    rm -f "$CURRENT_PATH/"$NEEDLE
    for FILE in $CURRENT_PATH; do
        if [ -d "$CURRENT_PATH/$FILE" ]; then
            remove_recursive "$CURRENT_PATH/$FILE" "$NEEDLE"
        fi
    done
}

copy_system_lib() {
    local SRC_NAME=$1
    local DST_PATH=$2
    cp --remove-destination /lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /usr/lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || cp --remove-destination /usr/lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null \
     || (echo "$SRC_NAME not found in system libraries" && return 1)
}

add_license() {
    local FILE="$1"
    local FILE_IN_TITLE="$2"
    local TARGET="$3"
    if [ ! -z "$FILE_IN_TITLE" ]; then
        echo ""                                      >> "$TARGET" || return 1
        echo "-------------------------------------" >> "$TARGET" || return 1
        echo "  File: $FILE_IN_TITLE"                >> "$TARGET" || return 1
        echo "-------------------------------------" >> "$TARGET" || return 1
        echo ""                                      >> "$TARGET" || return 1
    else
        echo ""                                      >> "$TARGET" || return 1
        echo "-------------------------------------" >> "$TARGET" || return 1
        echo ""                                      >> "$TARGET" || return 1
    fi
    cat "$FILE"                                      >> "$TARGET" || return 1
}

copy_system_license() {
    local SRC_NAMES=$1
    local DST_PATH=$2
    local SRC_NAME=
    for SRC_NAME in $SRC_NAMES; do
        rm -f "$DST_PATH/license-$SRC_NAME"
    done
    for SRC_NAME in $SRC_NAMES; do
        local TARGET="$DST_PATH/license-$SRC_NAME"
        local FILE=
        if   [ -f "/usr/share/doc/$SRC_NAME/copyright" ]; then
             FILE="/usr/share/doc/$SRC_NAME/copyright"
        elif [ -d "/usr/share/licenses/$SRC_NAME" ]; then
             FILE="/usr/share/licenses/$SRC_NAME"
        elif [ -d "/usr/share/doc/$SRC_NAME" ]; then
             FILE="/usr/share/doc/$SRC_NAME"
        fi

        if [ -f "$FILE" ]; then
            add_license "$FILE" "$FILE" "$TARGET" || (echo "Cannot add license file: $FILE -> $TARGET"; return 1)
        elif [ -d "$FILE" ]; then
            ls -1 "$FILE" | while read SUBFILE; do
                add_license "$FILE/$SUBFILE" "$FILE/$SUBFILE" "$TARGET" || (echo "Cannot add license file: $FILE/$SUBFILE -> $TARGET"; return 1)
            done
        fi
        
        if [ -f "$TARGET" ]; then
            return 0
        fi
    done

    echo "Cannot found any license for one of system packages: $SRC_NAMES (for $DST_PATH)"
    return 1
}
