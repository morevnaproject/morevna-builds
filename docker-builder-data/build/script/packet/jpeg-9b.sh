DEPS=""

PK_DIRNAME="jpegsrc.v9b"

pkdownload() {
    if ! wget "http://ijg.org/files/$PK_DIRNAME.tar.gz"; then
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
