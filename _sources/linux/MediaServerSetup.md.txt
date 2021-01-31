# Setting up a media server

## Intro

In this tutorial, we assume that a hard-drive containing various types of media is mounted on some server.
Its content will then be made accessible via `NFS`, streamed to e.g. your TV using `DLNA`, while being continuously monitored with `munin`.


## Setting up DLNA

DLNA is short for 'Digital Living Network Alliance' and allows media access from various types of rendering devices, most notably Smart TVs.

Its setup is fairly easy.
Firstly, install a DLNA server on the device hosting the media data:
```bash
$ pacman -S minidlna
```

Then configure it by editing `/etc/minidlna.conf` and adjusting the following values:
```bash
media_dir=/HD/media
friendly_name=kpj's friendly DLNA server
```

Finally, just start/enable it:
```bash
$ systemctl enable --now minidlna.service
```

It will now appear as a DLNA source on your respective rendering device.

Due to "some" reason, DLNA does sometimes not synchronize new files (even after restarts).
In order to fix this, simply delete `/var/cache/minidlna/files.db` and restart again.


## Setting up NFS

NFS (Network File System) will allow you add new data to the media storage via a network connection.
Install the needed applications:
```bash
$ pacman -S nfs-utils
```

Furthermore, it's a good idea to enable time-synchronization:
```bash
$ systemctl enable --now systemd-timesyncd
```

### Server

The server is the device which has a physical (direct) connection to the hard-drive, which is assumed to be mounted in `/mnt/media/`.

It is good practice to store all tentative NFS shares in a joint root (here: `/srv/nfs/`):
```bash
$ mkdir -p /srv/nfs/media
$ mount --bind /mnt/media/ /srv/nfs/media/
```

In order to make this persistent across reboots, add the following line to `/etc/fstab`:
```bash
/mnt/media /srv/nfs/media/  none   bind   0   0
```

To publish a shared directory, its configuration needs to be appended to `/etc/exports`:
```bash
/srv/nfs/media     192.168.1.0/24(rw,sync,crossmnt,fsid=0,no_subtree_check)
```


If NFS was already running, we need to notify it of our changes:
```bash
$ exportfs -rav
```

Otherwise, simply start the NFS service:
```bash
$ systemctl enable --now nfs-server.service
```

In the end, list all exports to make sure everything worked out:
```bash
$ exportfs -v
```


### Client

Assuming that the server is reachable using its ip, setting up the client is fairly straight-forward.

First, make sure that the exports are available:
```bash
$ showmount -e <server ip>
```

And then mount them accordingly:
```bash
$ mount -t nfs <server ip>:/srv/nfs/media /mnt/HD/media/
```


## Server health monitoring

To keep you media server running for a long time, monitoring its health and resource usage is important.
Check out how to achieve this using [Munin](MonitoringWithMunin.md).
