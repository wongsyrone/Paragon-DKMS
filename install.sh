#!/bin/bash
set -e
set +x

#VVV#  you can change this value

## paragon_file   --- should be full name of tarball file
paragon_file="Paragon-147-FRE_NTFS_Linux_8.9.0_Express.tar.gz"

#^^^##   MOSTLY YOU WILL NOT WANT TO CHANGE CONTENT BELOW

## go to script dir

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

source VERSION

pkgname=paragon-ufsd
MODULE_NAME=ufsd


main() {
	isrootuser

	install_dkms
	check_paragon_file
	uninstall_old_dkms
	set_package_dir
	move_package_dir
	chdir_package_dir
	configure_package_src
	fix_makefile
	add_install_build_dkms_module
	load_kernel_module
	add_kernel_module_to_etc_modules
	add_fstab_prototype
}



pkgdir=${pkgname}-${pkgver}

install_dkms() {
	echo ">> Install dkms"
		if ! which dkms > /dev/null
		then
			apt-get update && apt-get install -y --no-install-recommends dkms 1>/dev/null
		fi
	exit_func $?
}

check_paragon_file() {
	echo ">> check file: ${paragon_file}"
		[ -f ${paragon_file} ] || {
			echo "File not found: ${paragon_file}"
			echo "download from: http://www.paragon-software.com/home/ntfs-linux-professional/release.html"
			exit 1
		}
	exit_func $?
}

uninstall_old_dkms() {
	echo ">> uninstall old paragon-dkms"
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
}

set_package_dir() {
	echo ">> set paragon-dkms package dir"
		mkdir -p ${pkgdir}
		cp dkms.conf ${pkgdir}/
		sed "s/PACKAGE_VERSION=VERSION/PACKAGE_VERSION=\"${pkgver}\"/" -i ${pkgdir}/dkms.conf
		tar -xzf ${paragon_file} -C ${pkgdir}
	exit_func $?
}

move_package_dir() {
	echo ">> Move paragon-dkms package to /usr/src/"
		mv ${pkgdir} /usr/src/
	exit_func $?
}

chdir_package_dir() {
	cd /usr/src/${pkgdir}
}

configure_package_src() {
	echo ">> \"./configure\" package source"
		if ! ./configure
		then
			echo -e "\033[31mCan't prepare driver configuration\033[0m"
			exit 1
		fi
	exit_func $?
}

fix_makefile() {
	echo ">> Fix package Makefile"
		perl -i -pe 's|/lib/modules/.*?/|\$\(KERNELDIR\)/|g' Makefile
		perl -i -pe 's|SUBDIRS=\"/.*?\"|SUBDIRS=\"\$\(CURDIR\)\"|g' Makefile
	exit_func $?
}

add_install_build_dkms_module() {
	echo ">> DKMS: Module add, build, and install"
		local ufsd_status=$(dkms status -m ${pkgname} -v ${pkgver})
		if [ "$ufsd_status" == ""  ]; then
			dkms add -m ${pkgname} -v ${pkgver}
		fi
		dkms build -m ${pkgname} -v ${pkgver}
		dkms install -m ${pkgname} -v ${pkgver} --force
	exit_func $?
}

load_kernel_module() {
	echo ">> Load kernel module: ${MODULE_NAME}"
		modprobe ${MODULE_NAME} 2>&1
	exit_func $?
}

add_kernel_module_to_etc_modules() {
	echo ">> Add kernel module: ${MODULE_NAME} to /etc/modules"
		if ! grep "ufsd" /etc/modules >/dev/null
		then
			echo "ufsd" >> /etc/modules
		fi
	exit_func $?
}

add_fstab_prototype() {
	echo ">> Add mount ufsd prototype to /etc/fstab"
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
	exit_func $?
}

isrootuser() {
	[ $(id -u) = 0 ] || {
		echo -e "\e[00;31mThis script must be run as root\e[00m"
		exit 1
	}
}

exit_func() {
	local exitcode=${1}
	if [ $exitcode == 0 ]; then 
		echo -e "\e[00;32mGood\e[00m"
	else 
		echo -e "\e[00;31mFAIL\e[00m"
	fi
}


main "$@"
exit 0
