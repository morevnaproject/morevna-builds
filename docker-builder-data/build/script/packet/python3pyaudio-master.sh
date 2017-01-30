DEPS="python-3.6.0 portaudio-19.6.0"

PK_DIRNAME="pyaudio"
PK_URL="https://people.csail.mit.edu/hubert/git/$PK_DIRNAME.git"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    mkdir -p $INSTALL_PACKET_DIR/lib/python3.6/site-packages
    PYTHONHOME=$ENVDEPS_PACKET_DIR \
        PYTHONPATH=$INSTALL_PACKET_DIR/lib/python3.6/site-packages:$PYTHONPATH \
        python3 \
        setup.py \
        install \
        --prefix=$INSTALL_PACKET_DIR \
        || return 1
}
