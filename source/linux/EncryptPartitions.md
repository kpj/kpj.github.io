# Encrypting Partitions using LUKS

## Before you start

You might want to format your device as the first step, but this is only optional.
More important is to create a proper partition layout on your device, namely a small one to store some meta information and a larger one to store the actual data.

In the following I am going to assume that the matching block device is `/dev/sdb` (you can find yours using e.g. 'lsblk').
In order to create the two partitions fire up 'fdisk' and create a new partition table

```bash
$ fdisk /dev/sdb

Command (m for help): g
Created a new GPT disklabel (GUID: [..]).

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

In the next step, we are going to add the two new partitions. One of size 5M (to store meta data) and one to span the rest. We can thus take the default value for all but the last sector of the first partition.

```bash
$ fdisk /dev/sdb

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-15667166, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-15667166, default 15667166): +5M

Command (m for help): n
Partition number (2-128, default 2):
First sector (12288-15667166, default 12288):
Last sector, +sectors or +size{K,M,G,T,P} (12288-15667166, default 15667166):
```

Print the partition table to make sure everything worked out

```bash
Command (m for help): p
Disk /dev/sdb: 7.5 GiB, 8021606400 bytes, 15667200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: [..]

Device     Start      End  Sectors  Size Type
/dev/sdb1   2048    12287    10240    5M Linux filesystem
/dev/sdb2  12288 15667166 15654879  7.5G Linux filesystem
```

and save your changes

```bash
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Executing `ls /dev/sdb*` will now reveal the two new block devices `/dev/sdb1` and `/dev/sdb2`.
As the first one will store helpful information it is formatted to ext4 using 'mke2fs' (`-L` will set the volume label).

```bash
$ mke2fs -L sticky-hint -t ext4 /dev/sdb1
Creating filesystem with 5120 1k blocks and 1280 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Writing superblocks and filesystem accounting information: done
```

Useful information about our partitions can then be stored as follows

```bash
$ mount /dev/sdb1 /mnt/
$ fdisk -l /dev/sdb > /mnt/partitions
$ umount /mnt
```


## Getting started with encrypting

In the following, [LUKS](http://en.wikipedia.org/wiki/Linux_Unified_Key_Setup) is used as it offers a metadata header.
This can be done by using the 'cryptsetup' tool. If you want to use an extra long passphrase, a key file can be used with the `--key-file <file>` parameter. For the sake of simplicity I am going to provide a password from stdin here.

```bash
$ cryptsetup -v luksFormat /dev/sdb2

WARNING!
========
This will overwrite data on /dev/sdb2 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase:
Verify passphrase:
Command successful.
```

The header and keyslot area can then be backuped (assuming that the meta info partition is still mounted as before)

```bash
$ cryptsetup luksHeaderBackup /dev/sdb2 --header-backup-file /mnt/header
```


## Accessing the encrypted partition

We can open our newly create drive which is backed by `/dev/sdb2` by executing

```bash
$ cryptsetup -v luksOpen /dev/sdb2 sticky
Enter passphrase for /dev/sdb2:
Key slot 0 unlocked.
Command successful.
```

This command is going to create a mapping in `/dev/mapper` called 'sticky', which we can use to access our partition.
Right now, we obviously cannot use it since there is no filesystem on it. Let's change that.

```bash
$ mke2fs -L sticky -t ext4 /dev/mapper/sticky
Creating filesystem with 1956347 4k blocks and 489600 inodes
Filesystem UUID: 57d5effc-7d34-4866-aa5c-3a1a95c04f81
Superblock backups stored on blocks:
    32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

To be extra secure, its output can be saved to the hint partition as well.
The encrypted partition can then be mounted and subsequently used by executing

```bash
$ mount /dev/mapper/sticky /mnt/
```


## Unmounting the encrypted partition

The device mounted through the mapping can be unmounted by simply using

```bash
$ umount /mnt
```

In order to remove the mapping another call to 'cryptsetup' is necessary

```bash
$ cryptsetup -v luksClose sticky
Command successful.
```

Where `sticky` is simply the name of the mapping.


## Normal Workflow

To wrap everything up, this is the usual order of commands when using a device encrypted as described before

```bash
$ cryptsetup -v luksOpen <block device> <map name>
$ mount /dev/mapper/<map name> <mount point>
$ # do work...
$ umount <mount point>
$ cryptsetup -v luksClose <map name>
```
