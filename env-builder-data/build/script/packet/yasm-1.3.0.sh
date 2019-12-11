DEPS=""

PK_DIRNAME="yasm-1.3.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://www.tortall.net/projects/yasm/releases/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkinstall_release() {
    return 0
}