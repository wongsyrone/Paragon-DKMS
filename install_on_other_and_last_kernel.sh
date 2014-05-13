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

    echo -e "\033[32m>> Change dir to /usr/src/${pkgdir}\033[0m"
    cd /usr/src/${pkgdir}

    echo -e "\033[32m>> DKMS: Module add, build, and install\033[0m"
    dkms build -m ${pkgname} -v ${pkgver}
    dkms install -m ${pkgname} -v ${pkgver} --force

    echo -e "\033[32m>> Load kernel module: ${MODULE_NAME}\033[0m"
    modprobe ${MODULE_NAME} 2>&1

    echo -e "\033[33m Attention: Please add entry below when installing on the **LAST** kernel you want \033[0m"
    echo -e "\033[33m   Are you sure you are installing on the **LAST** kernel ? [yes/no]\033[0m"
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
