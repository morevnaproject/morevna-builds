FROM multiarch/crossbuild

RUN apt-get update \
 && apt-get install -y -q \
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
 
# fix ca-certificates issue - https://github.com/multiarch/crossbuild/issues/63
# RUN apt-get -yq update
# RUN apt-get -yq upgrade
RUN apt-get -yq install libssl1.0.2 openssl libgnutls30

# Image metadata
ENTRYPOINT ["/usr/bin/crossbuild"]
CMD ["/bin/bash"]
WORKDIR /workdir