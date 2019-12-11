DEPS="sndfile-1.0.28 speexdsp-1.2rc3"

PK_DIRNAME="pulseaudio-11.1"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://freedesktop.org/software/pulseaudio/releases/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--without-caps"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
