DEPS=""

PK_DIRNAME="SDL2-2.0.9"
## !!! SDL 2.0.7 produces linker errors with MinGW builds:
# /usr/local/x86_64-w64-mingw32/sys-root/lib/libmingw32.a(lib64_libmingw32_a-crt0_c.o): In function `main':
# /install-mingw/build/crt-x86_64-w64-mingw32/../../download/mingw-w64-v5.0.3/mingw-w64-crt/crt/crt0_c.c:18: undefined reference to `WinMain'
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.libsdl.org/release/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--host=$HOST --prefix=$INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
