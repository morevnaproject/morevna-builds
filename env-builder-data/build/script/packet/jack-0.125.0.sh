DEPS=""

PK_DIRNAME="jack1"
PK_URL="https://github.com/jackaudio/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="tags/0.125.0"
PK_LICENSE_FILES="AUTHORS COPYING COPYING.GPL COPYING.LGPL"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

PK_CONFIGURE_OPTIONS="--enable-force-install"

pkhook_prebuild() {
    ./autogen.sh
}
