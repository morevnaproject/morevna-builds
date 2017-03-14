DEPS=""

PK_DIRNAME="fontconfig-2.12.1"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.freedesktop.org/software/fontconfig/release/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkinstall_release() {
    return 0
}