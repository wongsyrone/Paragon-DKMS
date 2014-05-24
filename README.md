# Paragon UFSD kernel module with DKMS support

##### Support DKMS framework on Ubuntu 12.04 LTS, you need Express(FREE) version to do this trick. :)

## Kernel Supported

Paragon-express-8.9.0 ... supported up to Linux 3.11.x, be careful when you upgrade your Linux distribution.

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

    $ chmod +x uninstall.sh
    # ./uninstall.sh
    
