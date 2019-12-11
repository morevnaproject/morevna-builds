# NB: version of doxygen should be EQUAL to 1.8.8 - not newer, not older

DEPS="python-3.6.0 doxygen-1.8.8 python3requests-master gstreamerpluginsbase-0.10.36 gtk-3.22.12 adwaitaicontheme-3.24.0 gnomethemesstandard-3.22.3"

PK_DIRNAME="Phoenix"
PK_URL="https://github.com/wxWidgets/$PK_DIRNAME.git"
PK_GIT_CHECKOUT="tags/wxPython-4.0.0a2"

PK_LICENSE_FILES=" \
    ext/wxWidgets/docs/readme.txt \
    ext/wxWidgets/docs/preamble.txt \
    ext/wxWidgets/docs/licence.txt \
    ext/wxWidgets/docs/licendoc.txt \
    ext/wxWidgets/docs/gpl.txt \
    ext/wxWidgets/docs/lgpl.txt \
    ext/wxWidgets/docs/xserver.txt "

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    if [ ! -f wscript.orig ]; then
        cp wscript wscript.orig
        grep -v _html2.py wscript.orig > wscript
    fi
    PYTHONHOME=$ENVDEPS_PACKET_DIR \
        DOXYGEN=$ENVDEPS_PACKET_DIR/bin/doxygen \
        python3 build.py 3.6 \
        --gtk3 \
        --release \
        -j8 \
        --extra_setup=--prefix=$INSTALL_PACKET_DIR \
        dox etg sip build \
        || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME" || return 1
    rm -rf $INSTALL_PACKET_DIR
    mkdir -p $INSTALL_PACKET_DIR
    PYTHONHOME=$ENVDEPS_PACKET_DIR python3 build.py 3.6 \
        --gtk3 \
        --release \
        -j8 \
        --extra_setup=--prefix=$INSTALL_PACKET_DIR \
        install \
        || return 1
}
