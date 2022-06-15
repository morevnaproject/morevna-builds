FROM buildpack-deps:bullseye-curl

# Install deps
RUN set -x \
 && apt-get update                                     \
 && apt-get install -y -q                              \
        autoconf                                       \
        automake                                       \
        autotools-dev                                  \
        bc                                             \
        binfmt-support                                 \
#        binutils-multiarch                             \
#        binutils-multiarch-dev                         \
        build-essential                                \
        ccache                                         \
        clang                                          \
        curl                                           \
        devscripts                                     \
        gdb                                            \
        git-core                                       \
        libtool                                        \
        llvm                                           \
#        mercurial                                      \
#        multistrap                                     \
        patch                                          \
        software-properties-common                     \
        subversion                                     \
        wget                                           \
        xz-utils                                       \
        cmake                                          \
#        qemu-user-static                               \
#        libxml2-dev                                    \
#        lzma-dev                                       \
        openssl                                        \
#        libssl-dev                                     \
 && apt-get clean

# Install Windows cross-tools
RUN apt-get install -y mingw-w64 \
 && apt-get clean


# Create symlinks for triples and set default CROSS_TRIPLE
ENV WINDOWS_TRIPLES=i686-w64-mingw32,x86_64-w64-mingw32                                                                           \
    CROSS_TRIPLE=x86_64-linux-gnu
RUN mkdir -p /usr/x86_64-linux-gnu;                                                               \
    for triple in $(echo ${WINDOWS_TRIPLES} | tr "," " "); do                                     \
      mkdir -p /usr/$triple/bin;                                                                  \
      for bin in /etc/alternatives/$triple-* /usr/bin/$triple-*; do                               \
        if [ ! -f /usr/$triple/bin/$(basename $bin | sed "s/$triple-//") ]; then                  \
          ln -s $bin /usr/$triple/bin/$(basename $bin | sed "s/$triple-//");                      \
        fi;                                                                                       \
      done;                                                                                       \
      ln -s gcc /usr/$triple/bin/cc;                                                              \
      ln -s /usr/$triple /usr/x86_64-linux-gnu/$triple;                                           \
    done

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
pkg-config \
xsltproc \
m4 \
automake \
autopoint \
intltool \
libtool \
libltdl-dev \
git \
libintl-perl \
python3-pip \
ninja-build \
doxygen \
graphviz \
python \
# for synfigstudio-nsis \
unzip \
# for portable versions \
zip \
# fix ca-certificates issue - https://github.com/multiarch/crossbuild/issues/63
#libssl1.0.2 openssl libgnutls30 \
# epoxy
xutils-dev \
# native-SDL
libx11-dev \
libxext-dev \
# native-boost
libbz2-dev \
# native-cairo
libxcb1-dev \
# native-gtk -> native-epoxy
libegl1-mesa-dev \
# native-gtk -> native-atspi2
libxtst-dev \
libdbus-1-dev \
# qt deps see: http://doc.qt.io/qt-5/linux-requirements.html \
#libxrender-dev \
#libfontconfig1-dev \
#libfreetype6-dev \
#libxi-dev \
#libx11-xcb-dev \
#libsm-dev \
#libice-dev \
#libglu1-mesa-dev \
# other deps \
#libdirectfb-dev \
#liblzma-dev \
#liblzo2-dev \
#libudev-dev \
#libfuse-dev \
#libdb-dev \
#libasound2-dev \
#libffi-dev \
#libmount-dev \
#libbz2-dev \
#libcroco3-dev \
#libpthread-stubs0-dev \
#libxau-dev \
#libxcursor-dev \
#flex \
#bison \
#python-dev \
#xutils-dev \
&& apt-get clean

COPY files/install-cross-tools.sh /
RUN /install-cross-tools.sh
#TODO: Remove above lines after Conan migration?

RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix && \
    update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix && \
    update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix && \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

RUN pip3 install meson

RUN cd /tmp \
  && wget http://ftp.us.debian.org/debian/pool/main/a/automake-1.15/automake-1.15_1.15.1-5_all.deb \
  && dpkg -i automake-1.15_1.15.1-5_all.deb \
  && rm -f automake-1.15_1.15.1-5_all.deb

RUN dpkg --add-architecture i386 \
    && wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && apt-add-repository https://dl.winehq.org/wine-builds/debian/ \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --install-recommends winehq-stable -y \
    && apt-get clean


CMD ["/bin/bash"]
WORKDIR /workdir
