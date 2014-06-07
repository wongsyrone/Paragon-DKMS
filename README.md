# Paragon UFSD kernel module with DKMS support

##### Support DKMS framework on Ubuntu 12.04 LTS, you need Express(FREE) version to do this trick. :)

## Licence

MIT
ps: Modified from [this repo](https://github.com/bySabi/paragon-dkms)

## Kernel Supported

Paragon-express-8.9.0 ... support up to Linux 3.11.x, be careful when you upgrade your Linux distribution.

## Usage

**YOU MUST EXECUTE ./uninstall.sh FIRST TO CLEANUP ALL PREVIOUS UFSD MODULE FILES**


#### First Kernel Install
**DO NOT ADD /etc/fstab and /etc/modules ITEM IF YOU HAVE MULTI-KERNEL**

    $ chmod +x install_on_first_kernel.sh
    # ./install_on_first_kernel.sh

#### Other Kernel Install
**DO NOT ADD /etc/fstab and /etc/modules ITEM**

    $ chmod +x install_on_other_and_last_kernel.sh
    # ./install_on_other_and_last_kernel.sh
    
#### Last Kernel Install
**BE SURE TO ADD /etc/fstab and /etc/modules ITEM AT LAST**

    $ chmod +x install_on_other_and_last_kernel.sh
    # ./install_on_other_and_last_kernel.sh
    
#### Uninstall 

**WILL REMOVE ALL KERNEL MODULES ON ALL KERNEL**

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
    
