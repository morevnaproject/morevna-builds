FROM debian:7
ARG ALL_PROXY

# set available apt sources
COPY files/sources.list /etc/apt/sources.list

# update
RUN apt-get -yq update

# upgrade
RUN apt-get -yq upgrade

# update ca-certificates
RUN apt-get -yq purge ca-certificates
RUN apt-get -yq install ca-certificates

# install tools
RUN apt-get -yq install bash sudo pkg-config g++ make wget bzip2

# upgrade gcc
RUN apt-get -yq install libgmp-dev libmpfr-dev libmpc-dev gcc-multilib
COPY files/install-gcc.sh /
RUN /install-gcc.sh

# install mingw
COPY files/install-mingw.sh /
RUN /install-mingw.sh

# install tools
RUN apt-get -yq install csh
RUN apt-get -yq install xsltproc
RUN apt-get -yq install m4
RUN apt-get -yq install automake
RUN apt-get -yq install intltool
RUN apt-get -yq install libtool
RUN apt-get -yq install git

# qt deps see: http://doc.qt.io/qt-5/linux-requirements.html
RUN apt-get -yq install libxrender-dev
RUN apt-get -yq install libfontconfig1-dev
RUN apt-get -yq install libfreetype6-dev
RUN apt-get -yq install libxi-dev
RUN apt-get -yq install libxext-dev
RUN apt-get -yq install libx11-dev
RUN apt-get -yq install libx11-xcb-dev
RUN apt-get -yq install libsm-dev
RUN apt-get -yq install libice-dev
RUN apt-get -yq install libglu1-mesa-dev

# other deps
RUN apt-get -yq install liblzma-dev
RUN apt-get -yq install liblzo2-dev
RUN apt-get -yq install libudev-dev
RUN apt-get -yq install libfuse-dev
RUN apt-get -yq install libdb-dev
RUN apt-get -yq install libasound2-dev
RUN apt-get -yq install libffi-dev
RUN apt-get -yq install libmount-dev
RUN apt-get -yq install libbz2-dev
RUN apt-get -yq install libdbus-1-dev
RUN apt-get -yq install libcroco3-dev
RUN apt-get -yq install flex
RUN apt-get -yq install bison
RUN apt-get -yq install python-dev
RUN apt-get -yq install libxtst-dev
RUN apt-get -yq install xutils-dev
RUN apt-get -yq install libegl1-mesa-dev
RUN apt-get -yq install libdirectfb-dev
RUN apt-get -yq install libxcursor-dev

# wget cannot check SSL-certificate for some sites
RUN apt-get -yq install curl

# for synfigstudio-nsis
RUN apt-get -yq install unzip

# for portable versions
RUN apt-get -yq install zip

# build dir
RUN mkdir /build
