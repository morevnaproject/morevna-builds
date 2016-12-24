FROM fedora:21
MAINTAINER Konstantin Dmitriev <ksee.zelgadis@gmail.com>

#VOLUME /synfig-buildroot

#RUN yum -y update

RUN yum -y install git sudo

RUN yum -y install intltool autoconf automake libtool libtool-ltdl-devel

RUN yum -y install mingw32-gcc-c++ mingw32-cpp 

RUN yum -y install mingw32-adwaita-icon-theme mingw32-hicolor-icon-theme mingw32-libxml++ mingw32-cairo mingw32-pango mingw32-boost mingw32-libjpeg-turbo mingw32-gtkmm30 mingw32-glibmm24 mingw32-libltdl mingw32-dlfcn mingw32-SDL mingw32-fftw

RUN yum -y install mingw64-gcc-c++ mingw64-cpp

RUN yum -y install mingw64-adwaita-icon-theme mingw64-hicolor-icon-theme mingw64-libxml++ mingw64-cairo mingw64-pango mingw64-boost mingw64-libjpeg-turbo mingw64-gtkmm30 mingw64-glibmm24 mingw64-libltdl mingw64-dlfcn mingw64-SDL mingw64-fftw

RUN yum -y install mingw32-nsis

RUN yum -y install p7zip ImageMagick

RUN yum -y install make wget xz which

#RUN yum -y install synfig

RUN cd /opt && git clone https://gitlab.com/morevnaproject-builds/synfig-linux64
COPY files/synfig /usr/local/bin/synfig
RUN chmod +x /usr/local/bin/synfig

RUN yum -y install unzip

RUN yum -y install dejavu-sans-fonts  dejavu-sans-mono-fonts dejavu-serif-fonts

# deps for synfig appimage
RUN yum -y install fuse fuse-libs bzip2 bzip2-libs libXdmcp
RUN ln -s /usr/lib64/libbz2.so.1 /usr/lib64/libbz2.so.1.0

#RUN groupadd -g 1111 konstantin && useradd -u 1111 -g konstantin konstantin

#RUN groupadd sudo && usermod -aG sudo konstantin

#USER konstantin

CMD ["/bin/bash"]
