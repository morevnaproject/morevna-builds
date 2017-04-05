DEPS=""

PK_DIRNAME="fontconfig-2.11.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.freedesktop.org/software/fontconfig/release/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_prebuild() {
    rm -rf test
    ln -s src test
}

if [ "$PLATFORM" != "win" ]; then
    pkinstall_release() {
        return 0
    }
fi
