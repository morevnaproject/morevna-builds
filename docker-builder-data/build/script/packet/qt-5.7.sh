DEPS=""

PK_DIRNAME="qt-everywhere-opensource-src-5.7.0"

pkdownload() {
    if ! wget "http://download.qt.io/official_releases/qt/5.7/5.7.0/single/$PK_DIRNAME.tar.gz"; then
        return 1
    fi
}

pkunpack() {
    if ! tar -xzf "$2/$PK_DIRNAME.tar.gz"; then
        return 1
    fi
}

pkbuild() {
    cd "$1/$PK_DIRNAME"
    if ! (./configure -prefix "$3" -opensource -confirm-license -qt-xcb -no-compile-examples -nomake examples && make); then
        return 1
    fi
}

pkinstall() {
    cd "$2/$PK_DIRNAME"
    if ! make install; then
        return 1
    fi
}
