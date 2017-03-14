DEPS=""

PK_DIRNAME="glew-2.0.0"
PK_ARCHIVE="$PK_DIRNAME.tgz"
PK_URL="https://sourceforge.net/projects/glew/files/glew/2.0.0/$PK_ARCHIVE/download"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    
    if [ "$PLATFORM" = "win" ]; then
cat > "config/Makefile.mingw-$PLATFORM-$ARCH" << EOF
NAME          := glew32
HOST          := $HOST
CC            := $CC
LD            := $LD
LN            :=
STRIP         :=
LDFLAGS.GL     = -lopengl32 -lgdi32 -luser32 -lkernel32 $LDFLAGS
CFLAGS.EXTRA  += -fno-builtin -fno-stack-protector
WARN           = -Wall -W
POPT           = -O2
BIN.SUFFIX     = .exe
LIB.SONAME     = lib\$(NAME).dll
LIB.DEVLNK     = lib\$(NAME).dll.a
LIB.SHARED     = \$(NAME).dll
LIB.STATIC     = lib\$(NAME).a
LDFLAGS.SO     = -shared -soname \$(LIB.SONAME) --out-implib lib/\$(LIB.DEVLNK)
EOF
        
        if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR SYSTEM=mingw-$PLATFORM-$ARCH make -j${THREADS}; then
            return 1
        fi
    else
        if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR make -j${THREADS}; then
            return 1
        fi
    fi
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    if [ "$PLATFORM" = "win" ]; then
        if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR SYSTEM=mingw-$PLATFORM-$ARCH make install; then
            return 1
        fi
    else
        if ! GLEW_PREFIX=$INSTALL_PACKET_DIR GLEW_DEST=$INSTALL_PACKET_DIR make install; then
            return 1
        fi
    fi
}
