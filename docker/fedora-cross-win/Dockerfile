FROM fedora:25
MAINTAINER Konstantin Dmitriev <ksee.zelgadis@gmail.com>

#VOLUME /synfig-buildroot

#RUN dnf -y update

RUN dnf -y install git sudo

RUN dnf -y install intltool autoconf automake libtool libtool-ltdl-devel

RUN dnf -y install mingw32-gcc-c++ mingw32-cpp 

RUN dnf -y install mingw32-adwaita-icon-theme mingw32-hicolor-icon-theme mingw32-libxml++ mingw32-cairo mingw32-pango mingw32-boost mingw32-libjpeg-turbo mingw32-gtkmm30 mingw32-glibmm24 mingw32-libltdl mingw32-dlfcn mingw32-SDL mingw32-fftw

RUN dnf -y install mingw64-gcc-c++ mingw64-cpp

RUN dnf -y install mingw64-adwaita-icon-theme mingw64-hicolor-icon-theme mingw64-libxml++ mingw64-cairo mingw64-pango mingw64-boost mingw64-libjpeg-turbo mingw64-gtkmm30 mingw64-glibmm24 mingw64-libltdl mingw64-dlfcn mingw64-SDL mingw64-fftw

RUN dnf -y install mingw32-nsis

RUN dnf -y install p7zip ImageMagick

RUN dnf -y install make wget xz which

#RUN dnf -y install synfig

RUN cd /opt && git clone https://gitlab.com/morevnaproject-builds/synfig-linux64
COPY files/synfig /usr/local/bin/synfig
RUN chmod +x /usr/local/bin/synfig

RUN dnf -y install unzip zip

RUN dnf -y install dejavu-sans-fonts  dejavu-sans-mono-fonts dejavu-serif-fonts

# deps for synfig appimage
RUN dnf -y install fuse fuse-libs bzip2 bzip2-libs libXdmcp

# native build tools
RUN dnf -y install gcc gcc-c++ make automake autoconf flex
RUN dnf -y install bison
RUN dnf -y install zlib-devel
RUN dnf -y install libffi-devel
RUN dnf -y install libmount-devel
RUN dnf -y install python2-devel
RUN dnf -y install xorg-x11-util-macros
RUN dnf -y install mesa-libEGL-devel
RUN dnf -y install freetype-devel
RUN dnf -y install expat-devel
RUN dnf -y install libXi-devel
RUN dnf -y install dbus-devel
RUN dnf -y install libXtst-devel
RUN dnf -y install bzip2-devel

# additional mingw build tools
RUN dnf -y install mingw64-gcc-gfortran
RUN dnf -y install mingw32-gcc-gfortran

# great!
RUN rm /usr/local/bin/synfig


#RUN groupadd -g 1111 konstantin && useradd -u 1111 -g konstantin konstantin

#RUN groupadd sudo && usermod -aG sudo konstantin

#USER konstantin

CMD ["/bin/bash"]
