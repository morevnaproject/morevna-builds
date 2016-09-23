DEPS=""

PK_DIRNAME="tiff-4.0.6"

pkdownload() {
    if ! wget "http://download.osgeo.org/libtiff/$PK_DIRNAME.tar.gz"; then
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
    if ! ./configure "-prefix=$3" && make; then
        return 1
    fi
}

pkinstall() {
    cd $2
    if ! make install; then
        return 1
    fi
}
