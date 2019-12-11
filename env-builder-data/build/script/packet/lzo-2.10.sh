DEPS=""

PK_DIRNAME="lzo-2.10"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="http://www.oberhumer.com/opensource/lzo/download/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT=" \
    --prefix=$INSTALL_PACKET_DIR \
    --enable-static \
    --enable-shared "

if [ ! -z "$HOST" ]; then
    PK_CONFIGURE_OPTIONS_DEFAULT=" \
        $PK_CONFIGURE_OPTIONS_DEFAULT \
        --host=$HOST "
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
