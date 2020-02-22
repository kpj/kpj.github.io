# Setting up and Encrypted Archlinux

## Preparing the Installation Image

The first step is obviously to acquire some archlinux installation medium. The easiest way is probably to download the image from the [official download page](https://www.archlinux.org/download/) and burn it to a usb-stick (assumed to be at `/dev/sdb`)

```bash
$ dd bs=4M if=archlinux.iso of=/dev/sdb
$ sync
```

You are now able to boot your computer using the stick.


## Setting up Partitions

After booting the arch system from the usb-stick, it is time to set up all needed partitions.

Here's a list of mount points I'd recommend to use together with the size of their corresponding partition (for an overall drive size of 500GB)

* `/boot` (500MB)
* `/` (50GB)
* `/var` (15GB)
* `/home` (rest)

For simplicity reasons (or because I am lazy) I am only going to create two partitions, one for `/boot` and one for `/`.

These partitions can then be created using `fdisk`

```bash
$ fdisk /dev/sda

Command (m for help): g
Created a new GPT disklabel (GUID: [..]).

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-976773134, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-976773134, default 976773134): +500M

Created a new partition 1 of type 'Linux filesystem' and of size 500 MiB.

Command (m for help): n
Partition number (2-128, default 2):
First sector (1026048-976773134, default 1026048):
Last sector, +sectors or +size{K,M,G,T,P} (1026048-976773134, default 976773134):

Created a new partition 2 of type 'Linux filesystem' and of size 465.3 GiB.

Command (m for help): p
Disk /dev/sda: 465.8 GiB, 500107862016 bytes, 976773168 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: [..]

Device       Start       End   Sectors    Size Type
/dev/sda1     2048   1026047   1024000    500M Linux filesystem
/dev/sda2  1026048 976773134 975747087  465.3G Linux filesystem

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```


## Enabling Encryption

In order the encrypt all partitions (except for `/boot`) we are going to use `cryptsetup` as follows

```bash
$ cryptsetup -y -v luksFormat /dev/sda2

WARNING!
========
This will overwrite data on /dev/sda2 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase:
Verify passphrase:
Command successful.
$ cryptsetup open /dev/sda2 rootfs
Enter passphrase for /dev/sda2:
$ mke2fs -L rootfs -t ext4 /dev/mapper/rootfs
[..]
$ cryptsetup close rootfs
```

Don't forget that the boot partition needs a filesystem as well

```bash
$ mke2fs -L bootfs -t ext4 /dev/sda1
[..]
```


## Installing the System

Before installing the system, we have to mount all partitions the the correct mount point

```bash
$ mkdir /mnt
$ cryptsetup open /dev/sda2 rootfs
Enter passphrase for /dev/sda2:
$ mount -t ext4 /dev/mapper/rootfs /mnt
$ mkdir /mnt/boot
$ mount -t ext4 /dev/sda1 /mnt/boot
```

The archlinux system can now be installed and prepared

```bash
$ pacstrap /mnt base
$ genfstab -p /mnt >> /mnt/etc/fstab
$ arch-chroot /mnt
```


## Creating an Initial RAM Disk

The only thing to notice here is that `encrypt` has to be added to the HOOKS array in `/etc/mkinitcpio.conf` before `filesystems`.
You might also want to add `keyboard` (before `encrypt`) as this will allow you to use USB keyboards in early userspace.

The RAM disk can then be created as follows

```bash
$ mkinitcpio -p linux
```


## Setting up a Boot Loader

We are going to use `syslinux` whose simplicity was confirmed by credible sources [citation needed].

To do so, install the `syslinux` and `gptfdisk` packages and execute the `syslinux-install_update` script with the following parameters

```bash
$ syslinux-install_update -i -a -m
```

Don't forget to add the right kernel parameter to `/boot/syslinux/syslinux.cfg`.

```bash
LABEL arch
	APPEND root=/dev/mapper/rootfs rw cryptdevice=/dev/sda2:rootfs allow-discards
```

Hereby, `allow-discards` allows to forward TRIM commands via LUKS, which is helpful for SSDs.


## Cleaning Up

As the final step, leave the chroot environment by calling `exit` and unmount `/mnt` recursively.

```bash
$ umount -R /mnt
```

Now reboot and login with the root account.
