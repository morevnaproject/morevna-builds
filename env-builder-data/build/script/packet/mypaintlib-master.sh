DEPS="jsonc-0.12.1 glib-2.69.3"
DEPS_NATIVE="automake-1.15"

PK_DIRNAME="libmypaint"
PK_URL="https://github.com/blackwarthog/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="origin/testing"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkhook_prebuild() {
    ./autogen.sh || return 1
}
