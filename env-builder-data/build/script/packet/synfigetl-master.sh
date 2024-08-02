DEPS="glibmm-2.58.1"
DEPS_NATIVE="libtool-2.4.6"

if [ -z "$REPO_URL" ] && [ -z "$BRANCH" ]; then
PK_DIRNAME="synfig"
else
PK_DIRNAME="synfig.ci"
fi
if [ -z "$REPO_URL" ]; then
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"
else
PK_URL="$REPO_URL"
fi
if [ -z "$BRANCH" ]; then
PK_GIT_CHECKOUT="origin/testing"
else
PK_GIT_CHECKOUT="origin/$BRANCH"
fi

PK_LICENSE_FILES="ETL/AUTHORS ETL/README"

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/ETL" || return 1
    if ! check_packet_function $NAME build.configure; then
        autoreconf --install --force || return 1
        ./configure \
         --host=$HOST \
         --prefix=$INSTALL_PACKET_DIR \
         --sysconfdir=$INSTALL_PACKET_DIR/etc \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.configure
    fi
    make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/ETL"
    if ! make install; then
        return 1
    fi
}
