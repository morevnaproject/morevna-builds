
gen_name_template() {
    local NAME="$1"
    local TAG="$2"
    local PLATFORM="$3"
    local ARCH="$4"
    local SUFFIX="$4"
    
    if [ ! -z "$TAG" ]; then
        TAG="-$TAG"
    fi
    
    echo "$NAME-%VERSION%-${ARCH}bit-$PLATFORM$TAG-%DATE%-%COMMIT%$SUFFIX"
}
