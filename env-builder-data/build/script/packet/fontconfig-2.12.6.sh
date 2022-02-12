DEPS="freetype-2.8.1 expat-2.2.5"
DEPS_NATIVE="gperf-3.1"

PK_DIRNAME="fontconfig-2.12.6"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.freedesktop.org/software/fontconfig/release/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_prebuild() {
    rm -rf test
    cp -rf --remove-destination src test
}
