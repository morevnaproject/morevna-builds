DEPS="fftwsingle-3.3.5"

PK_DIRNAME="fftw-3.3.5"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://fftw.org/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS="--enable-double --disable-static --enable-shared"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
