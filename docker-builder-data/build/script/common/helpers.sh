# helpers

allvars() {
    for LOCAL_ALLVARS_VAR_PREFIX in _ {a..z} {A..Z}; do
        eval echo -n $\{\!$LOCAL_ALLVARS_VAR_PREFIX*} | sed "s|LOCAL_ALLVARS_VAR_PREFIX||g"
        echo -n " "
    done
}

vars_clear() {
    # local PREFIX=$1
    [ ! -z "$1" ] || return 1
    for VAR in $(allvars); do
        if [[ "$VAR" = $1* ]]; then
            unset $VAR
        fi
    done
}

vars_copy() {
    # local PREFIX_FROM=$1
    # local PREFIX_TO=$2
    # local EXPORT=$3
    [ "$1" == "$2" ] && return 0
    for VAR in $(allvars); do
        if [[ "$VAR" = $1* ]]; then
            if [ "$3" = "export" ]; then
                eval export ${2}${VAR#$1}='${!VAR}'
            else
                eval ${2}${VAR#$1}='${!VAR}'
            if
        fi
    done
}

vars_rename() {
    # local PREFIX_FROM=$1
    # local PREFIX_TO=$2
    [ ! -z "$1" ] || return 1
    vars_copy "$1" "$2"
    vars_clear "$1"
}
    
vars_backup() {
    # local PREFIX=$1
    [ ! -z "$1" ] || return 1
    vars_copy "" "$1"
}

vars_restore() {
    # local PREFIX=$1
    # local EXPORT=$2
    [ ! -z "$1" ] || return 1
    vars_copy "$1" "" "$2"
}

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
    local DIR="$1"
    local COMMAND="$2"
    if [ -z "$DIR" ] || [ ! -e "$DIR" ]; then
        return 1
    fi
        
    if [ -d "$DIR" ]; then
        for FILE in "$DIR/".*; do
            if [ "$FILE" != "$DIR/." ] && [ "$FILE" != "$DIR/.." ]; then
                if ! "$COMMAND" "$FILE" ${@:3}; then
                    return 1
                fi
            fi
        done
        for FILE in "$DIR/"*; do
            if [ "$FILE" != "$DIR" ] && [ "$FILE" != "$DIR/" ]; then
                if ! "$COMMAND" "$FILE" ${@:3}; then
                    return 1
                fi
            fi
        done
    fi
}

remove_recursive() {
    local DIR="$1"
    local NEEDLE="$2"

    if [ -d "$DIR" ]; then
        rm -f "$DIR/"$NEEDLE
        if ! foreachfile "$DIR" "${FUNCNAME[0]}" "$NEEDLE"; then
            return 1
        fi
    fi
}

foreachfile() {
    local FILE=$1
    local COMMAND=$2
    if [ ! -e "$FILE" ]; then
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

sha512dir() {
    local DIR="$1"
    local INFO="$2"

    [[ "$DIR" = ".git" ]] || return 0
    [[ "$DIR" = *.po   ]] || return 0

    if [ "$INFO" = "info" ]; then
        basename "$DIR" || return 1
        stat -c%F:%a:%s "$DIR" || return 1
    fi
        
    if [ -d "$DIR" ]; then
        (foreachfile "$DIR" "${FUNCNAME[0]}" info | sha512sum -b | cut -c1-128) || return 1
    else
        (sha512sum -b "$DIR" | cut -c1-128) || return 1
    fi
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

