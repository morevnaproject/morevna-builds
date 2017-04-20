DEPS="jpeg-9b png-1.6.26 tiff-4.0.6 xml-2.9.4 fftw-3.3.5"

PK_DIRNAME="ImageMagick-6.8.7-10"
PK_ARCHIVE="$PK_DIRNAME.tar.xz"
PK_URL="http://www.imagemagick.org/download/releases/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS=" \
 --without-perl \
 --without-x \
 --with-threads \
 --with-magick_plus_plus"

if [ "$PLATFORM" = "win" ]; then
  PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --without-modules"
else
  PK_CONFIGURE_OPTIONS="$PK_CONFIGURE_OPTIONS --with-modules"
fi 

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
