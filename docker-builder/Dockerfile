FROM debian:7

# Update
RUN apt-get -yq update

# Upgrade
RUN apt-get -yq upgrade

# Install compilers
RUN apt-get -yq install \
    g++ \
    make

# Install tools
RUN apt-get -yq install \
    sudo \
    multiarch-support \
    realpath \
    pkg-config

# qt deps see: http://doc.qt.io/qt-5/linux-requirements.html
RUN apt-get -yq install \
    libxrender-dev \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-sync0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-glx0-dev \
    libxcb-xfixes0-dev \
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

RUN apt-get -yq install \
	liblzma-dev \
	liblzo2-dev \
	freeglut3-dev
	
RUN apt-get -yq install gfortran
RUN apt-get -yq install ratfor
RUN apt-get -yq install csh
RUN apt-get -yq install libxcb-xinerama0-dev
RUN apt-get -yq install xsltproc
RUN apt-get -yq install libudev-dev

CMD mkdir /build