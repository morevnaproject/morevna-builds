FROM morevna/debian-i386:wheezy
ARG ALL_PROXY

# Update
RUN apt-get -yq update

# Upgrade
RUN apt-get -yq upgrade

# Install tools
RUN apt-get -yq install \
    sudo \
    pkg-config \
    g++ \
    make

# qt deps see: http://doc.qt.io/qt-5/linux-requirements.html
RUN apt-get -yq install \
    libxrender-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libxi-dev \
    libxext-dev \
    libx11-dev \
    libx11-xcb-dev \
    libsm-dev \
    libice-dev \
    libglib2.0-dev \
    libglu1-mesa-dev
    
# other deps

RUN apt-get -yq install liblzma-dev
RUN apt-get -yq install liblzo2-dev
RUN apt-get -yq install libudev-dev
RUN apt-get -yq install libfuse-dev
RUN apt-get -yq install libdb-dev
RUN apt-get -yq install libasound2-dev

RUN apt-get -yq install gfortran
RUN apt-get -yq install csh
RUN apt-get -yq install xsltproc
RUN apt-get -yq install m4
RUN apt-get -yq install automake
RUN apt-get -yq install intltool
RUN apt-get -yq install libtool

RUN apt-get -yq install git
RUN apt-get -yq install wget
RUN apt-get -yq install bzip2

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
RUN apt-get -yq install libarchive-dev
RUN apt-get -yq install zsync

RUN mkdir /build
