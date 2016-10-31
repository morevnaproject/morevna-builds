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
# . m4           - from autoconf 
# . autoconf     - from automake
# . automake     - from intltool 
# . tool (libtool) - from the system
# . gettext      - from intltool 
# . intltool      - from the system

DEPS=" \
 synfigetl-master \
 jpeg-9b tiff-4.0.6 fftw-3.3.5 imagemagick-6.9.6 \
 jack-0.125.0 ffmpeg-3.1.5 mlt-6.2.0 \
 boost-1.61.0 cairo-1.14.6 pango-1.40.3 glibmm-2.41.4 xmlpp-2.22.0"

PK_DIRNAME="synfig"
PK_URL="https://github.com/synfig/$PK_DIRNAME.git"
PK_GIT_OPTIONS="--branch testing"

source $INCLUDE_SCRIPT_DIR/inc-pkallunpack-git.sh
source $INCLUDE_SCRIPT_DIR/inc-pkinstall_release-default.sh

pkbuild() {
	cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-core" || return 1
	if ! check_packet_function $NAME build.configure; then
		libtoolize --ltdl --copy --force || return 1
		autoreconf --install --force || return 1
		./configure \
			--prefix=$INSTALL_PACKET_DIR \
			--sysconfdir=$INSTALL_PACKET_DIR/etc \
			--with-boost-libdir=$ENVDEPS_PACKET_DIR/lib \
			--without-opengl || return 1
		set_done $NAME build.configure
	fi
	make -j${THREADS} || return 1
}

pkinstall() {
    cd "$BUILD_PACKET_DIR/$PK_DIRNAME/synfig-core"
    if ! make install; then
        return 1
    fi
}
