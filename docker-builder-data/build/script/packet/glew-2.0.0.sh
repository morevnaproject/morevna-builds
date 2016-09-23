DEPS=""

PK_DIRNAME="glew-2.0.0"

pkdownload() {
    if ! wget "https://sourceforge.net/projects/glew/files/glew/2.0.0/$PK_DIRNAME.tgz/download"; then
        return 1
    fi
}

pkunpack() {
    if ! tar -xzf "$2/$PK_DIRNAME.tgz"; then
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
