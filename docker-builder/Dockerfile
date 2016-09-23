FROM debian:7

# Update
RUN apt-get -yq update

# Upgrade
RUN apt-get -yq upgrade

# Install compilers
RUN apt-get -yq install \
    g++ \
    make

# Install base libs
RUN apt-get -yq install \
    sudo \
    multiarch-support \
    libpng12-dev \
    libfreetype6-dev \
    libxml2-dev \
    libjasper-dev \
    libffi-dev \
    libasound2-dev \
    libdirectfb-dev \
    x11proto-xext-dev \
    libxfixes-dev \
    libxinerama-dev \
    libxdamage-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxft-dev \
    libxrender-dev \
    libxt-dev \
    libxrandr-dev \
    libxi-dev \
    libxext-dev \
    libx11-dev \
    libxtst-dev \
    x11proto-gl-dev \
    libx11-xcb-dev \
    libpthread-stubs0-dev \
    libxml-parser-perl \
    libdb-dev uuid-dev \
    libdbus-1-dev \
    python-dev \
    gettext \
    autopoint \
    libpciaccess-dev \
    libudev-dev \
    bzip2

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

# additional tools
RUN apt-get -yq install \
    realpath \
    libxcb-xfixes0-dev \
    bash

# Launcher
ADD conf/launch.sh /
CMD /bin/bash -c /launch.sh
