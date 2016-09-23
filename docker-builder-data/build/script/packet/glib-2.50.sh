DEPS=""

PK_DIRNAME="glib-2.50.0"

pkdownload() {
    if ! wget "https://download.gnome.org/sources/glib/2.50/$PK_DIRNAME.tar.xz"; then
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
