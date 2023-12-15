# automake
# intltool
# libdb-dev        - libdb already installed - required
# bzip2            - required
# libasound2-dev   - required 
# libffi-dev       - libffi5 already installed - glib
# libdbus-1-dev    - atspi2
# libxtst-dev      - atspi2

# uuid-dev         - libuuid1 already installed - gilib via libmount-dev
# libpciaccess-dev - libpciaccess0 already installed

# libncurses-dev   - gettext
# libtinfo-dev     - gettext
# libunistring-dev - gettext

# libjasper-dev
# libdirectfb-dev
# python-dev

# libxml-parser-perl



# +	jpeg
# +	tiff
#  	glib         - from glibmm
# 	harfbuzz     - not used in core - pango
# 	fontconfig   - from the system
#	pixman       - from cairo
# +	cairo
# +	pango        - also from cairo
#   croco        - not used in core - for gettext
# +	jack
# 	mesa         - opengl not used in this build 
# 	sigcpp       - from glibmm
# +	glibmm
# +	xmlpp
# +	mlt
# +	imagemagick
#   ogg          - not used in core - ffmpeg, vorbis, theora
#   vorbis       - not used in core - ffmpeg
#   samplerate   - not used in core - mlt
#   sox          - not used in core - mlt
#   lame         - not used in core - ffmpeg
#   theora       - not used in core - ffmpeg
#   x264         - not used in core - ffmpeg
#   faac         - not used in core - mlt
#   yasm         - not used in core - ffmpeg
# + ffmpeg
#   sdl          - not used in core - ffmpeg, mlt
# +	fftw
# +	boost
# + fribidi
# + harfbuzz
# . m4           - from autoconf 
# . autoconf     - from automake
# . automake     - from intltool 
# . tool (libtool) - from the system
# . gettext      - from intltool 
# . intltool      - from the system

DEPS=" \
 synfigetl-me \
 jpeg-9b tiff-4.0.6 fftw-3.3.5 imagemagick-6.8.7 \
 ffmpeg-3.1.5 mlt-6.6.0 \
 boost-1.61.0 cairo-1.15.4 pango-1.40.3 \
 fribidi-0.19.7 harfbuzz-1.3.2 \
 glibmm-2.58.1 xmlpp-2.40.1 "
DEPS_NATIVE="libtool-2.4.6"

PK_DIRNAME="synfig"
PK_URL="https://tvoygit.ru/morevnaproject/$PK_DIRNAME"
#PK_URL="https://tvoygit.ru/konstantin_dmitriev/$PK_DIRNAME"
PK_GIT_CHECKOUT="origin/main"
PK_LICENSE_FILES="synfig-core/AUTHORS synfig-core/README"
PK_CPPFLAGS="-DWINVER=0x0600" # required for `GetUserDefaultLocaleName` function

source $INCLUDE_SCRIPT_DIR/inc-pkall-git.sh

pkbuild() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-core" || return 1
    if ! check_packet_function $NAME build.configure; then
        ./bootstrap.sh || return 1
        CPPFLAGS="$PK_CPPFLAGS $CPPFLAGS" \
         ./configure \
         --host=$HOST \
         --prefix=$INSTALL_PACKET_DIR \
         --sysconfdir=$INSTALL_PACKET_DIR/etc \
         --with-boost-libdir=$ENVDEPS_PACKET_DIR/lib \
         --without-opengl \
         $PK_CONFIGURE_OPTIONS \
         || return 1
        set_done $NAME build.configure
    fi
    make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-core"
    if ! make install; then
        return 1
    fi
# We do not use Wine, because it is a way too slow
#    if [ "$PLATFORM" = "win" ]; then
#        cat <<EOT >>  "${INSTALL_PACKET_DIR}/bin/synfig"
##!/bin/bash
#
#wine ${INSTALL_PACKET_DIR}/bin/synfig.exe "\$@"
#EOT
#        chmod +x "${INSTALL_PACKET_DIR}/bin/synfig"
#    fi
}
