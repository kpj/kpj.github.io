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


## Monitoring server health

We will monitor and display the server's health status using `munin`.
First, we'll focus on its general setup and subsequently on various useful plugins.


### Munin-Master setup

The master will gather data from all nodes and render them using HTML.

Install `munin`:
```bash
$ pacman -S munin
```

Then, instruct it to store HTML renders of the health-reports in `/srv/http/munin`. This will make them easily accessible using a webserver later on.
First, prepare the directory:
```bash
$ mkdir -p /srv/http/munin
$ chown munin:munin /srv/http/munin
```

And then edit `/etc/munin/munin.conf`:
```bash
htmldir /srv/http/munin
```

In order to generate graphs every 5 minutes, we will create a systemd-service which is going to be called from a systemd-timer.

The service (`/etc/systemd/system/munin-cron.service`) itself will call `munin-cron` and looks as follows:
```bash
[Unit]
Description=Survey monitored computers
After=network.target

[Service]
User=munin
ExecStart=/usr/bin/munin-cron
```

The timer `/etc/systemd/system/munin-cron.timer` is then:
```bash
[Unit]
Description=Survey monitored computers every five minutes

[Timer]
OnCalendar=*-*-* *:00/5:00

[Install]
WantedBy=multi-user.target
```

Before enabling them, we can try a manual test-run by running `munin-cron` as the munin user (remember that nothing will happen without enabling some plugins):
```bash
$ su - munin --shell=/bin/bash -c munin-cron
```

If we are sure that everything works, we can finally enable the timer:
```bash
$ systemctl daemon-reload
$ systemctl enable --now munin-cron.timer
```

And afterwards -- of course -- check the logs:
```bash
$ journalctl --unit munin-cron.service
```

#### Making the results available

To make the results accessible using a web-browser, we use `lighttpd`.
This will automatically serve `/srv/http/` on port 80 (make sure to checkout `/etc/lighttpd/lighttpd.conf`):
```bash
$ pacman -S lighttpd
$ systemctl start lighttpd
```

The reports can then be accessed under `<server ip>/munin/`.

In order to have interactive graphs, we will have to enable (fast) `CGI`:
```bash
$ pacman -S fcgi
```


```bash
$ touch /var/log/munin/munin-cgi-graph.log
$ chmod 777 /var/log/munin/munin-cgi-graph.log
$ chmod 777 /var/lib/munin/cgi-tmp
```

Test if the CGI-executable is able to run:
```bash
$ /usr/bin/perl -T /usr/share/munin/cgi/munin-cgi-graph
```


Add the following to `/etc/lighttpd/lighttpd.conf`:
```bash
server.modules += ("mod_fastcgi")
fastcgi.server += ("/munin-cgi/munin-cgi-graph" =>
    ((
        "socket" => "/var/run/lighttpd/munin-cgi-graph.sock",
        "bin-path" => "/usr/share/munin/cgi/munin-cgi-graph",
        "check-local" => "disable"
    ))
)
```

### Munin-Node setup

Each device for which health-summaries shall be reported needs to become a `munin-node` (this is also the case for the master).
Luckily, this is rather trivial:
```bash
$ pacman -S munin-node
```

On the node itself, we need to allow communication with the master (in `/etc/munin/munin-node.conf`):
```bash
host_name <my name>
allow ^<master ip>$
```

and start the node (don't forget to add plugins though):
```bash
$ systemctl enable --now munin-node
```

On the master-server, we have to add a configuration entry per node to `/etc/munin/munin.conf`:
```bash
[group_name;master-node]
    address 127.0.0.1

[group_name;machine01]
    address <node ip>
```


### Plugins

Without plugins, `munin` won't be reporting much.
In the following, a few useful ones will be listed. More plugins can be found, e.g. by calling `munin-node-configure --suggest`.

Each plugin can be installed by first copying them to `/usr/lib/munin/plugins/` and then linking with `/etc/munin/plugins/`.
Note that they must be executable (`chmod a+x /usr/lib/munin/plugins/<plugin name>`):
```bash
$ ln -s /usr/lib/munin/plugins/<plugin name> /etc/munin/plugins/
```

As a general rule, each individual plugin can be tested in isolation using the following command:
```bash
$ munin-run <command name>
```
For the CPU-plugin `<command name>` would be `cpu`.

Remember, that a node needs to be restarted after changing its plugin configuration:
```bash
$ systemctl restart munin-node
```

#### Common plugins

The following are plugins providing generally useful statistics:
* `cpu`: CPU-speed
* `df`: disk space usage
* `if_<interface>`: tx/rx rates on given interface
* `processes`: overview of process numbers
* `memory`: RAM usage

My own custom plugins can be found [here](https://github.com/kpj/munin-plugins).

#### SMART-plugin

`S.M.A.R.T.` provides a nice way of monitoring your disks (HDD, SSD, etc) health status.

Its basic usage if fairly straight-forward:
```bash
$ pacman -S smartmontools
$ smartctl -i /dev/sda  # show device info
$ smartctl -t short /dev/sda  # run a short test
$ smartctl -H /dev/sda  # show test results
```

To interlink it with `munin`, first configure the plugin by writing the following to `/etc/munin/plugin-conf.d/munin-node`:
```bash
[smart_*]
    user root
    group disk
```

and secondly enable it:
```bash
$ ln -s /usr/lib/munin/plugins/smart_ /etc/munin/plugins/smart_sda  # for disk /dev/sda
```


#### lm_sensors-plugin

`lm_sensors` allow the tracking of temperatures, voltages and more.

First, set them up as you normally would:
```bash
$ pacman -S lm_sensors
$ sensors-detect  # generate kernel-modules (always press enter)
$ sensors
```

Temperatures can then be monitored by adding the respective plugin:
```bash
$ ln -s /usr/lib/munin/plugins/sensors_ /etc/munin/plugins/sensors_temp
```


### Troubleshooting

#### General tips
A manual connection to a node is possible, and useful for debugging:
```bash
$ netcat <node ip> 4949
```
One can then enter e.g. one of the following commands:
* `list`: list enabled plugins
* `fetch <plugin name>`: check output of given plugin

Furthermore, `munin-cron` can be run with the `--debug` option to show what is going on in more detail.

More information can be found [here](http://guide.munin-monitoring.org/en/latest/tutorial/troubleshooting.html).

#### Corrupted database
The munin-databases can be found in `/var/lib/munin/<group name>`. Delete them to reset all data.

#### Certain nodes cannot be reached.
Check that their ip-address is set correctly in the master's `/etc/munin/munin.conf`.
Furthermore make sure that their own configuration (`/etc/munin/munin-node.conf`) allows the master to connect (`allow <master ip>`).
