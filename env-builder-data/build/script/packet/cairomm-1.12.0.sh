DEPS="cairo-1.15.4 sigcpp-2.10.0"

PK_DIRNAME="cairomm-1.12.0"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.cairographics.org/releases/$PK_ARCHIVE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

if [ "$PLATFORM" = "win" ]; then
    PK_CONFIGURE_OPTIONS="CXXFLAGS=-DM_PI=3.14159265358979323846"
fi