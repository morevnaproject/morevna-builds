source "$PACKET_SCRIPT_DIR/opentoonz-master.sh"

DEPS="$DEPS mypaintlib-master"
PK_DIRNAME="opentoonz"
PK_URL="https://github.com/blackwarthog/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="origin/testing"

PK_LICENSE_FILES="$PK_LICENSE_FILES stuff/library/mypaint?brushes/Licenses.txt"
