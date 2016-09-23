DEPS=""

PK_DIRNAME="libpng-1.6.25"

pkdownload() {
    if ! wget "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.25.tar.xz"; then
        return 1
    fi
}

pkunpack() {
    if ! tar -xf "$2/$PK_DIRNAME.tar.xz"; then
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
