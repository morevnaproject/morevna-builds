DEPS=""

PK_DIRNAME="json-c-0.12.1"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://s3.amazonaws.com/json-c_releases/releases/$PK_ARCHIVE"

if [ "$PLATFORM" = "win" ]; then
    PK_CFLAGS="-Wno-error=unknown-pragmas"
    PK_LDFLAGS="-ladvapi32 -lgettextlib"
fi

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkhook_prebuild() {
    if [ ! -f "Makefile.in.orig" ]; then
        mv Makefile.in Makefile.in.orig
    fi
    cat Makefile.in.orig | sed -e 's| -Werror | |g' > Makefile.in
}