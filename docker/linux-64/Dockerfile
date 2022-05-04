FROM multiarch/crossbuild

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
# for synfigstudio-nsis \
unzip \
# for portable versions \
zip \
# migw tools \
win-iconv-mingw-w64-dev \
# fix ca-certificates issue - https://github.com/multiarch/crossbuild/issues/63
libssl1.0.2 openssl libgnutls30 \
&& apt-get clean

COPY files/install-cross-tools.sh /
RUN /install-cross-tools.sh
#TODO: Remove above lines after Conan migration?

RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix && \
    update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix && \
    update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix && \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
python3-pip ninja-build
RUN pip3 install meson
#RUN apt-get install -y -q  libpcre3-dev
#RUN apt-get install -y -q wine64 wine32:i386
RUN apt-get install -y -q doxygen
RUN apt-get install -y -q graphviz
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
apt-add-repository https://dl.winehq.org/wine-builds/debian/ && \
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --install-recommends winehq-stable -y
RUN apt-get install -y -q gfortran

# Image metadata
ENTRYPOINT ["/usr/bin/crossbuild"]
CMD ["/bin/bash"]
WORKDIR /workdir
