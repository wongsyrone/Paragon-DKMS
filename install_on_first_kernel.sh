#!/bin/bash
set -e
set +x

## go to script dir

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

source VERSION

pkgname=paragon-ufsd
MODULE_NAME=ufsd

pkgdir=${pkgname}-${pkgver}

isrootuser() {
	[ $(id -u) = 0 ] || {
		echo -e "\e[00;31mThis script must be run as root\e[00m"
		exit 1
	}
}

install_dkms() {
    echo -e "\033[32m>> Install dkms\033[0m"
    if ! which dkms > /dev/null
    then
        apt-get update && apt-get install -y --no-install-recommends dkms 1>/dev/null
    fi

    echo -e "\033[32m>> check file: ${paragon_file}\033[0m"
    [ -f ${paragon_file} ] || {
        echo -e "\e[00;31mFile not found: ${paragon_file} \e[00m"
        echo -e "\e[00;31mdownload from: http://www.paragon-software.com/home/ntfs-linux-professional/release.html\e[00m"
        exit 1
    }

    echo -e "\033[32m>> uninstall old paragon-dkms\033[0m"
    echo -e "\033[33mAre you sure you have executed ./uninstall.sh before ? [yes/no]\033[0m"
    read answer
    case "$answer" in
    y|Y|yes|Yes|YeS|yEs|YES)
        echo -e "\033[32mLet us begin installaion!\033[0m" 
    ;;
    *)
        echo -e "\e[00;31mPlease execute ./uninstall.sh at first!\e[00m"
        exit 1
    ;;
    esac

    echo -e "\033[32m>> set paragon-dkms package dir\033[0m"
    mkdir -p ${pkgdir}
    cp dkms.conf ${pkgdir}/
    sed "s/PACKAGE_VERSION=VERSION/PACKAGE_VERSION=\"${pkgver}\"/" -i ${pkgdir}/dkms.conf
    tar -xzf ${paragon_file} -C ${pkgdir}

    echo -e "\033[32m>> Move paragon-dkms package to /usr/src/\033[0m"
    mv ${pkgdir} /usr/src/
    echo -e "\033[32m>> Change dir to /usr/src/${pkgdir}\033[0m"
    cd /usr/src/${pkgdir}

    echo -e "\033[32m>> \"./configure\" package source\033[0m"
    if ! ./configure
    then
        echo -e "\033[31mCan't prepare driver configuration\033[0m"
        exit 1
    fi

    echo -e "\033[32m>> Fix package Makefile\033[0m"
    perl -i -pe 's|/lib/modules/.*?/|\$\(KERNELDIR\)/|g' Makefile
    perl -i -pe 's|SUBDIRS=\"/.*?\"|SUBDIRS=\"\$\(CURDIR\)\"|g' Makefile

    echo -e "\033[32m>> DKMS: Module add, build, and install\033[0m"
    local ufsd_status=$(dkms status -m ${pkgname} -v ${pkgver})
    if [ "$ufsd_status" == ""  ]; then
	    dkms add -m ${pkgname} -v ${pkgver}
    fi
    dkms build -m ${pkgname} -v ${pkgver}
    dkms install -m ${pkgname} -v ${pkgver} --force

    echo -e "\033[32m>> Load kernel module: ${MODULE_NAME}\033[0m"
    modprobe ${MODULE_NAME} 2>&1

    echo -e "\033[33m Attention: Please add entry below when installing on the **last** kernel you want \033[0m"
    echo -e "\033[33m   >>>>>>>>>>>>>IF you have only ONE kernel, Please ADD entry <<<<<<<<<<<<<<<< \033[0m"
    echo -e "\033[33m   Do you want to add entry to /etc/fstab and /etc/modules ? [yes/no]\033[0m"
    read answer
    case "$answer" in
    y|Y|yes|Yes|YeS|yEs|YES)
        echo -e "\033[32m>> Add kernel module: ${MODULE_NAME} to /etc/modules\033[0m"
        if ! grep "ufsd" /etc/modules >/dev/null
        then
            echo "ufsd" >> /etc/modules
        fi
        echo -e "\033[32m>> Add mount ufsd prototype to /etc/fstab\033[0m"
        if ! grep "ufsd" /etc/fstab >/dev/null
        then
            # you can modify these settings if needed
            #  must be NTFS partitions, you can find this by executing "sudo blkid"
            echo '# NTFS mount settings using ufsd kernel module (including ufsd.ko and jnl.ko)' >> /etc/fstab
            echo 'UUID=0003E6990003C76F /media/SOFT ufsd defaults,user,rw,iocharset=utf8,umask=000,nls=utf8 0 3' >> /etc/fstab
            echo 'UUID=0005031200015EBC /media/Other ufsd defaults,user,rw,iocharset=utf8,umask=000,nls=utf8 0 3' >> /etc/fstab
            echo 'UUID=0004532E0008E51B /media/SOFT2 ufsd defaults,user,rw,iocharset=utf8,umask=000,nls=utf8 0 3' >> /etc/fstab
            echo 'UUID=68D466FDD466CCBE /media/OTHER2 ufsd defaults,user,rw,iocharset=utf8,umask=000,nls=utf8 0 3' >> /etc/fstab
        fi
    ;;
    *)
        echo -e "\e[00;31mWe will not add entry to /etc/modules and /etc/fstab \e[00m"
    ;;
    esac
}

main() {
	isrootuser
    install_dkms
}

main "$@"
exit 0
