DEPS="jpeg-9b png-1.6.26 tiff-4.0.6 xml-2.9.4 fftw-3.3.5"

PK_DIRNAME="ImageMagick-6.9.5-10"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://www.imagemagick.org/download/releases/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS=" \
 --with-modules \
 --without-perl \
 --without-x \
 --with-threads \
 --with-magick_plus_plus"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
