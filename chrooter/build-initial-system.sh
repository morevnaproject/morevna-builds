#!/bin/bash -x

set -e

arch=i386
suite=wheezy
chroot_dir="/var/chroot/$suite"
apt_mirror="ftp://ftp.debian.org/debian/"

export DEBIAN_FRONTEND=noninteractive
debootstrap --arch $arch $suite $chroot_dir $apt_mirror

cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror $suite main
deb $apt_mirror $suite-updates main
deb http://security.debian.org/ $suite/updates main
EOF

chroot $chroot_dir apt-get update
chroot $chroot_dir apt-get upgrade -y
chroot $chroot_dir apt-get autoclean
chroot $chroot_dir apt-get clean
chroot $chroot_dir apt-get autoremove

olddir=`pwd`
pushd $chroot_dir
zip "$olddir/debian-$suite-$arch.zip" -qyr0 . || true # zip cannot process some files from /dev
popd

rm -rf $chroot_dir
