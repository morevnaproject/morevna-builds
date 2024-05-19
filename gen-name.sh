
gen_name_template() {
    local NAME="$1"
    local TAG="$2"
    local PLATFORM="$3"
    local ARCH="$4"
    local SUFFIX="$5"

    if [ ! -z "$TAG" ]; then
        TAG="-$TAG"
    fi

    echo "$NAME-%VERSION%-%DATE%-$PLATFORM$ARCH-%COMMIT%$SUFFIX"
}
