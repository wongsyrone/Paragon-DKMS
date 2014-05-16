#!/bin/bash
set -e
set +x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

# load_file_version()
source VERSION

if ! [ $(id -u) = 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

pkgname=paragon-ufsd
pkgdir=${pkgname}-${pkgver}

ufsd_status=$(dkms status -m ${pkgname} -v ${pkgver})
if ! [ "$ufsd_status" == ""  ]; then
    rmmod -f -v -w ufsd
    rmmod -f -v -w jnl
    # remove previous added loading module and mount item  
    sed -i '/ufsd/d' /etc/modules
    sed -i '/ufsd/d' /etc/fstab
    dkms uninstall -m ${pkgname} -v ${pkgver}
	dkms remove -m ${pkgname} -v ${pkgver} --all
	rm -rf /var/lib/dkms/${pkgname}
	rm -rf /usr/src/${pkgdir}
	rm -rf ${pkgdir}
    # remount all devices via /etc/fstab
    depmod -a
fi

# remove kernel module again if something went wrong
ufsd_module_status=$(lsmod | grep -i "ufsd")
if ! [ "$ufsd_module_status" == "" ]; then
    rmmod -f -v -w ufsd
    rmmod -f -v -w jnl
fi
