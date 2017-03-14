DEPS="python-3.6.0"

PK_DIRNAME="requests"
PK_URL="https://github.com/kennethreitz/$PK_DIRNAME.git"
PK_LICENSE_FILES="AUTHORS.rst LICENSE"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    return 0
}

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
