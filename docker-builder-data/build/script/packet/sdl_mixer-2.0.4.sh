DEPS="sdl-2.0.7"

PK_DIRNAME="SDL2_mixer-2.0.4"
PK_ARCHIVE="$PK_DIRNAME.tar.gz"
PK_URL="https://www.libsdl.org/projects/SDL_mixer/release/$PK_ARCHIVE"

PK_CONFIGURE_OPTIONS_DEFAULT="--host=$HOST --prefix=$INSTALL_PACKET_DIR"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh
