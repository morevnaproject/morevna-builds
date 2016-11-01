#!/bin/bash -x

set -e

arch=amd64
suite=wheezy
chroot_dir="/var/chroot/$suite"
apt_mirror="ftp://ftp.debian.org/debian/"

OLDDIR=`pwd`
SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
cd "$OLDDIR"
BASE_DIR=`dirname "$SCRIPT_DIR"`

CONFIG_FILE="$BASE_DIR/config.sh"
if [ -f $CONFIG_FILE ]; then
	source $CONFIG_FILE
fi


rm -rf $chroot_dir
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

tar cfz debian-$suite-$arch.tar.gz -C $chroot_dir .
rm -rf $chroot_dir
