FROM i386/debian:stretch

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libssl1.0.2 openssl libgnutls30 \
autoconf \
automake \
autotools-dev \
bc \
binfmt-support \
build-essential \
ccache \
clang \
curl \
devscripts \
gdb \
git-core \
libtool \
llvm \
mercurial \
multistrap \
patch \
software-properties-common \
subversion \
wget \
xz-utils \
cmake \
qemu-user-static \
libxml2-dev \
lzma-dev \
openssl \
# libssl-dev replaced with libssl1.0-dev because of QT build error
# see here for details - https://forum.qt.io/topic/83279/qt-5-9-1-static-build-linux
libssl1.0-dev \
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
# for synfigstudio-nsis \
unzip \
# for portable versions \
zip \
&& apt-get clean

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
python3-pip ninja-build
RUN pip3 install meson
RUN apt-get install -y -q doxygen
RUN apt-get install -y -q graphviz
RUN apt-get install -y -q gfortran

CMD ["/bin/bash"]
WORKDIR /workdir
