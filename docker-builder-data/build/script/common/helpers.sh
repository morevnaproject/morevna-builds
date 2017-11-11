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
            fi
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
    
    local BASE=$(basename "$DIR")

    [[ "$BASE" != ".git" ]] || return 0
    [[ "$BASE" != *.po   ]] || return 0

    if [ "$INFO" = "info" ]; then
        basename "$DIR" || return 1
        stat -c%F:%a:%s "$DIR" || return 1
    fi
        
    if [ -d "$DIR" ]; then
        (foreachfile "$DIR" "${FUNCNAME[0]}" info | sha512sum -b | cut -c1-128) || return 1
    elif [ -L "$DIR" ]; then
        (readlink "$DIR" | sha512sum -b | cut -c1-128) || return 1
    else
        (sha512sum -b "$DIR" | cut -c1-128) || return 1
    fi
}

copy_system_lib() {
    local SRC_NAME=$1
    local DST_PATH=$2
    cp --remove-destination /lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/local/lib/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/local/lib64/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/local/lib/x86_64-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    cp --remove-destination /usr/local/lib/i386-linux-gnu/$SRC_NAME* "$DST_PATH" &> /dev/null
    if ! (ls "$DST_PATH/$SRC_NAME"* &> /dev/null); then
        echo "$SRC_NAME not found in system libraries"
        return 1
    fi
}

add_common_licenses() {
    local FILE="$1"
    local TARGET="$2"

    local LIC_PATH="/usr/share/common-licenses"
    [ -d "$LIC_PATH" ] || return 0
    [[ ! "$FILE" = "$LIC_PATH/"* ]] || return 0
    ls -d1 "$LIC_PATH/"* | while read SUB_FILE; do
        if grep -q "$SUB_FILE" "$FILE"; then
            add_license "$SUB_FILE" "$SUB_FILE" "$TARGET"
        fi
    done
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
    add_common_licenses "$FILE" "$TARGET" || return 1
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
        for SUFFIX in "" {0..9} "-"; do
            local SUB_NAME="$SRC_NAME$SUFFIX"
            if [ ! -z "$SUFFIX" ]; then
                SUB_NAME="$SUB_NAME*"
            fi

            for MASK in "/usr/share/doc/$SUB_NAME/copyright" \
                        "/usr/share/licenses/$SUB_NAME" \
                        "/usr/share/licenses/$SUB_NAME/*" \
                        "/usr/share/doc/$SUB_NAME/*" \
                        "/usr/local/share/doc/$SUB_NAME/copyright"
            do
                local FOUND=
                ls -d1 $MASK 2>/dev/null | while read FILE; do
                    if [ -f "$FILE" ] && [[ "$FILE" != *.bz2 ]]; then
                        FOUND=1
                        if ! add_license "$FILE" "$FILE" "$TARGET"; then
                            echo "Cannot add license file: $FILE -> $TARGET";
                            return 1
                        fi
                    fi
                done
                if [ ! -z "$FOUND" ]; then
                    break
                fi
            done

            if [ -z "$SUFFIX" ] && [ -f "$TARGET" ]; then
                return 0
            fi
        done

        if [ -f "$TARGET" ]; then
            return 0
        fi
    done

    echo "Cannot found any license for one of system packages: $SRC_NAMES (for $DST_PATH)"
    return 1
}

