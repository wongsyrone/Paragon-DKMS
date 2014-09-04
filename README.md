# Paragon UFSD kernel module with DKMS support

##### Support DKMS framework on Ubuntu 14.04 LTS, you need Express(FREE) version to do this trick. :)

## Licence

MIT

ps: Modified from [this repo](https://github.com/bySabi/paragon-dkms)

## Kernel Supported

Paragon-express-9.0 ... Support modern Linux Kernels from 2.6.36 up to 3.14.x (According to official instructions, UFSD driver was internally tested with Kernels up to 3.14.4).

## ATTENTION !!

**You should read this carefully**

* You should cleanup all previous paragon ufsd(aka NTFS driver) kernel modules at first to avoid some wierd issues.
* You can use `uninstall.sh` to uninstall or use command given below if the script crashed.
* It should be noted that the uninstall procedure will remove all modules on all kernels, and you'd better try `$ dkms status` at the very beginning.
* `/etc/fstab` and `/etc/modules` will mount your ntfs partitions when booting, and you will get stuck when there was no `ufsd` module installed.
* ONLY add `/etc/fstab` and `/etc/modules` item when installing on the **LAST** kernel on your system

## Usage

#### First Kernel Install

    $ chmod +x install_on_first_kernel.sh
    # ./install_on_first_kernel.sh

#### Other Kernel Install

    $ chmod +x install_on_other_and_last_kernel.sh
    # ./install_on_other_and_last_kernel.sh
    
#### Last Kernel Install

    $ chmod +x install_on_other_and_last_kernel.sh
    # ./install_on_other_and_last_kernel.sh
    
#### Uninstall 

using scripts:

    $ chmod +x uninstall.sh
    # ./uninstall.sh
    
using command manually:

    # rmmod -f -v -w ufsd                              /* delete kernel modules                                */
    # rmmod -f -v -w jnl
    $ dkms status                                      /* check whether we have already installed paragon ufsd */
    # dkms uninstall -m ${pkgname} -v ${pkgver}        /* ${pkgname} and ${pkgver} is your previous setting    */
	# dkms remove -m ${pkgname} -v ${pkgver} --all
	# rm -rf /var/lib/dkms/${pkgname}                  /* delete all src and compiled files                    */
	# rm -rf /usr/src/${pkgdir}
	# rm -rf ${pkgdir}
	# depmod -a                                        /* remount via /etc/fstab                               */
    
