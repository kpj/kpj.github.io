# Rescuing a Broken Archlinux System

## Prolog

It's one of these days again: you unplugged your laptop's power supply, started a system update (`pacman -Syu`) and left to do something else.
Upon your return you notice your laptop is suspiciously quiet. Fear starts creeping through your veins. You frantically try to boot up your system, but to no avail. Everything fades to black as your system keeps refusing to boot.

If this sounds familiar to you, you should first and foremost rethink your power management strategy, and secondly follow these 6 simple steps to rescue your system.


## Step 1: Find a USB stick

Since your system won't boot by itself, it needs a little help from a friend, i.e. a live USB stick. Go find it!


## Step 2: Download an Archlinux ISO

To be able to boot into Arch, we need to have Arch. You can download an image from https://www.archlinux.org/download/.


## Step 3: Flash Installation Medium

To create a bootable USB stick, we need to [flash the ISO](https://wiki.archlinux.org/index.php/USB_flash_installation_medium) to it.

First, find the stick's block device (and make really, really sure it's the right one).
`lsblk` can be helpful here:
```bash
$ lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda            8:0    0  7.3T  0 disk
|-sda1         8:1    0    5M  0 part
`-sda2         8:2    0  7.3T  0 part
  `-crypt_hd 253:0    0  7.3T  0 crypt /mnt/HD
sdb            8:16   1  7.5G  0 disk               # <-- here it is
|-sdb1         8:17   1  679M  0 part
`-sdb2         8:18   1   64M  0 part
mmcblk0      179:0    0 14.8G  0 disk
|-mmcblk0p1  179:1    0  100M  0 part  /boot
`-mmcblk0p2  179:2    0 14.7G  0 part  /
```

Next, flash the ISO:
```bash
$ dd if=/path/to/arch.iso of=/dev/sdb bs=1M
```

<!-- Create bootable USB: https://wiki.archlinux.org/index.php/USB_flash_installation_medium
* find block device
* on macos: unmount, but do not eject: diskutil list && diskutil unmountDisk /dev/diskX
* macos: dd if=path/to/arch.iso of=/dev/rdiskX bs=1M (bote the r prefix of block device, do not include the s1 suffix) -->


## Step 4: Boot USB Stick on Computer

How this works depends on your hardware. Good luck!


## Step 5: Access Filesystem

It is now time to mount your lost system's partition.
You can again look for it using `lsblk` and then mount it:
```bash
$ mount /dev/sda2 /mnt
```

We can then [chroot](https://wiki.archlinux.org/index.php/Chroot#Using_arch-chroot) into the system:
```bash
$ arch-root /mnt
```

`arch-root` will take care of various steps needed to make the chrooted environment feel like a proper one (e.g. mount `/proc`).
Note: if your `/boot` folder lives on a separate partition you need to mount it in manually (after mounting `/dev/sda2`):
```bash
$ mount /dev/sda1 /mnt/boot
```


## Step 6: Fix your System

Now you get to play detective, as many things could have broken.
Here are a few suggestions:

* As `pacman` was interrupted quite rudely, you might have to manually delete `/var/lib/pacman/db.lck`.
* The packages involved in the update are most likely in a broken state. Identify them by looking at pacman's logs (`/var/log/pacman.log`) and subsequently [reinstall them](https://wiki.archlinux.org/index.php/pacman#Pacman_crashes_during_an_upgrade).
* In some cases the [initramfs can become corrupted](https://wiki.archlinux.org/index.php/pacman#%22Unable_to_find_root_device%22_error_after_rebooting). Run `mkinitcpio -p linux` to rebuild it.
