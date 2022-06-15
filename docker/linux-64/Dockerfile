FROM buildpack-deps:stretch-curl

RUN set -x; apt-get update                                     \
 && apt-get install -y -q                              \
        autoconf                                       \
        automake                                       \
        autotools-dev                                  \
        bc                                             \
#        binfmt-support                                 \
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
        libxml2-dev                                    \
        lzma-dev                                       \
        openssl                                        \
        libssl-dev                                     \
 && apt-get clean
 
# upgrade gcc
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install libgmp-dev libmpfr-dev libmpc-dev gcc-multilib && apt-get clean
COPY files/install-gcc.sh /
RUN /install-gcc.sh

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
pkg-config \
csh \
xsltproc \
m4 \
automake \
autopoint \
intltool \
libtool \
libltdl-dev \
git \
# qt deps see: http://doc.qt.io/qt-5/linux-requirements.html \
libxrender-dev \
libfontconfig1-dev \
libfreetype6-dev \
libxi-dev \
libxext-dev \
libx11-dev \
libx11-xcb-dev \
libsm-dev \
libice-dev \
libglu1-mesa-dev \
# other deps \
libegl1-mesa-dev \
libdirectfb-dev \
liblzma-dev \
liblzo2-dev \
libudev-dev \
libfuse-dev \
libdb-dev \
libasound2-dev \
libffi-dev \
libmount-dev \
libbz2-dev \
libdbus-1-dev \
libcroco3-dev \
libpthread-stubs0-dev \
libxau-dev \
libxcursor-dev \
flex \
bison \
python-dev \
libxtst-dev \
xutils-dev \
doxygen \
graphviz \
gfortran \
# fix ca-certificates issue - https://github.com/multiarch/crossbuild/issues/63
libssl1.0.2 openssl libgnutls30 \
&& apt-get clean

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
python3-pip ninja-build
RUN pip3 install meson

RUN apt-get remove -y -q gcc g++-6 gcc-6-multilib clang

CMD ["/bin/bash"]
WORKDIR /workdir
