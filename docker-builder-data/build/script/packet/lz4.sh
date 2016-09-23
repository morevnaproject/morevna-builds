DEPS=""

PK_DIRNAME="lz4"

pkdownload() {
    if [ -d "lz4/.git" ]; then
        if ! git clone https://github.com/Cyan4973/$PK_DIRNAME.git; then
            return 1
        fi
    else
        cd "$PK_DIRNAME"
        if ! git pull; then
            return 1
        fi
    fi
}

pkunpack() {
    cd "$2/$PK_DIRNAME"
    if ! git checkout-index "--prefix=$1/$PK_DIRNAME/" -f -a; then
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
    cd "$2"
    if ! make install; then
        return 1
    fi
}
