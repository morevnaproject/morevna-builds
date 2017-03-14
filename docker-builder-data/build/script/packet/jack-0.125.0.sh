DEPS=""

PK_DIRNAME="jack-audio-connection-kit-0.125.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://jackaudio.org/downloads/$PK_ARCHIVE"
PK_LICENSE_FILES="AUTHORS COPYING COPYING.GPL COPYING.LGPL"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkinstall_release() {
    return 0
}