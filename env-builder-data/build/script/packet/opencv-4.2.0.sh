DEPS=""

PK_DIRNAME="opencv-4.2.0"
PK_ARCHIVE="opencv-4.2.0.tar.gz"
PK_URL="https://github.com/opencv/opencv/archive/refs/tags/4.2.0.tar.gz"

source $INCLUDE_SCRIPT_DIR/inc-pkall-default.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    
    if [ "$PLATFORM" = "win" ]; then
        cat > toolchain.cmake << EOF
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR X86)
set(CMAKE_C_COMPILER /usr/bin/${TC_HOST}-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/${TC_HOST}-g++)
EOF
        LOCAL_OPTIONS="$LOCAL_OPTIONS -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake"
    fi
    
    if ! check_packet_function $NAME build.configure; then
        mkdir build && cd build
        cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$INSTALL_PACKET_DIR $LOCAL_OPTIONS .. || return 1
        set_done $NAME build.configure
    fi
    
    make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME"
    cd build
    make install
}
