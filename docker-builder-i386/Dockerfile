FROM my/debian-i386:wheezy

# Update
RUN apt-get -yq update

# Upgrade
RUN apt-get -yq upgrade

# Install tools
RUN apt-get -yq install \
    sudo \
    realpath \
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
    
# xcb (for qt)
#RUN apt-get -yq install \
#    libxcb1-dev \
#    libxcb-glx0-dev \
#    libxcb-icccm4-dev \
#    libxcb-image0-dev \
#    libxcb-keysyms1-dev \
#    libxcb-randr0-dev \
#    libxcb-render0-dev \
#    libxcb-render-util0-dev \
#    libxcb-shape0-dev \
#    libxcb-sync0-dev \
#    libxcb-shm0-dev \
#    libxcb-xfixes0-dev \
#    libxcb-xinerama0-dev

# other deps

RUN apt-get -yq install liblzma-dev
RUN apt-get -yq install liblzo2-dev
RUN apt-get -yq install gfortran
RUN apt-get -yq install csh
RUN apt-get -yq install xsltproc
RUN apt-get -yq install libudev-dev
RUN apt-get -yq install m4

CMD mkdir /build
