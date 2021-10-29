# Configuring a fresh Archlinux Install

## Intro

This entry will provide you with the first few steps needed to get a fresh Arch install running and happy.


## Setting up a Network Connection

In order to install all missing programs on-the-fly, a working internet connection is important.

We first make sure that the `systemd-networkd` and `systemd-resolved` services automatically start when booting:

```bash
$ systemctl enable --now systemd-networkd.service
$ systemctl enable --now systemd-resolved.service
```

We then configure it to establish a wired connection by editing `/etc/systemd/network/20-wired.network`:

```bash
[Match]
Name=<network interface>

[Network]
DHCP=yes
```

Finally, we restart the service to make it aware of our recent changes:

```bash
systemctl restart systemd-networkd.service
```


## "Essential" Programs

In order to complete the following steps, some additional programs might be needed. In order to install those and other cool ones, update the pacman database (`pacman -Syy`) and install the following applications:

* `vim-minimal` - text editing and much more
* `paru` - easy installation of AUR packages
* `mplayer`/`mpv` - multimedia player
* `htop` - resource usage stats
* `wget` - network downloader
* `bash-completion` - guess what
* `evince-gtk` - pdf viewer
* `feh` - image viewer
* `scrot` - screenshot application
* `downgrade` - downgrad packages
* `pkgfile` - find out which package a program is in
* `strace` - trace system calls and signals
* `gdb` - GNU debugger
* `mtr` - ping + traceroute
* `ncdu` - `du` with curses interface
* `ssh-copy-id` - copy ssh public key to other host's authorized_hosts file
* `pacgraph` - see which packages are installed and more

* `radare2` - analyze binary files
* `hashcat` - crack hashes
* `iodine` - tunnel IPV4 via DNS

* `mps-youtube` - youtube player in terminal
* `syncthing` - share files between computers


## Initial Configuration

This section will list a few common first steps after installing the basic system

### Set a Hostname
```bash
$ hostnamectl set-hostname <hostname>
```


### Set your Timezone
```bash
$ timedatectl set-timezone Europe/Berlin
```

### Set locale
```bash
$ vim /etc/locale.gen # uncomment: "en_US.UTF-8 UTF-8"
$ locale-gen
$ locale -a # list available types

$ vim .config/locale.conf # export entries from `locale` as env vars
or
$ localectl set-locale LANG=en_US.UTF-8
```

### Handle keyboard layout (console)
Adjust your keyboard layout according to your needs.
```bash
$ localectl status # show current configuration
$ localectl list-keymaps # list available layouts
$ loadkeys de-latin1 # temporarily load layout
$ vim /etc/vconsole.conf # add "KEYMAP=de-latin1" for permanent layout
```

### Handle keyboard layout (Xorg)
It might be necessary to adjust X to the layout of your specific keyboard. For german ones, something like the following could be used.
```bash
$ vim ~/.xinitrc # add "setxkbmap de nodeadkeys &" at bottom
```

### Set root Password
```bash
$ su
$ passwd
```

### Setup Zsh
```bash
$ pacman -S zsh zsh-completions 
```

You can now create a new user with Zsh as their default shell (see next section).

### Add a Default User
```bash
$ useradd --create-home -g users --groups wheel --shell /usr/bin/zsh kpj
$ passwd kpj
[..]
```


## Setting up the GUI

In order to have a fancy window manager, we have to install X and a driver first (the exact packages required depend on your particular GPU setup)

```bash
$ pacman -S xorg xorg-xinit
$ cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

To then automatically start X on login, add

```bash
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
```

to the bottom of your `~/.zprofile`.

In order to automatically login after booting, simply create the file `/etc/systemd/system/getty@tty1.service.d/autologin.conf` (assuming you're using systemd) and paste the following content

```bash
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin <username> --noclear %I 38400 linux
Type=simple
```

Afterwards, e.g. `i3` can then be easily installed and set to automatically start on boot

```bash
$ pacman -S i3
$ vim ~/.xinitrc # add "exec i3" at bottom
```

`i3` needs the following packages to work correctly

* `dmenu`
* `rxvt-unicode`


Logitech Marble mouse config
Section "InputClass"
    Identifier      "Marble Mouse"
    MatchProduct    "Logitech USB Trackball"
    Driver          "evdev"

    Option          "ButtonMapping"             "1 2 3 4 5 6 7 2 2"

    Option          "Emulate3Buttons"           "false"

    Option          "EmulateWheel"	            "true"
    Option          "EmulateWheelButton"        "8"
EndSection


## Enabling Sound

Start setting up `pulseaudio` by installing it

```bash
$ pacman -S pulseaudio
```

It should now automatically start on boot. Otherwise add this to your `.xinitrc`

```bash
pulseaudio -D &
```


## Clock Synchronization

We haven't used `systemd` so far, so let's do it (Ba Dum Tss!)

```bash
$ systemctl enable systemd-networkd
$ systemctl enable systemd-timesyncd
```


## Using SSH

```bash
$ pacman -S openssh
$ ssh-keygen
$ systemctl enable sshd.service
```


## Handle sudo

```bash
$ pacman -S sudo
$ EDITOR=vim visudo # -> %sudo   ALL=(ALL) ALL
$ groupadd sudo
$ usermod -a -G sudo <user>
```


## Init vim

Install [this](https://github.com/gmarik/Vundle.vim) plugin manager and look [here](https://github.com/kpj/dotfiles/blob/master/vimrc) for an exemplary configuration file.


## Useful `.bashrc` edits

Colorful prompt for normal user:

```bash
PS1='\[\e[1;32m\][\u@\h \W]$\[\e[0m\] '
```

for root (same color but as background):

```bash
PS1='\[\e[1;32m\e[7m\][\u@\h \W]$\[\e[0m\] '
```


## Weechat usage

```bash
$ pacman -S weechat
$ weechat
-> /server add freenode chat.freenode.net
-> /set irc.server.freenode.autoconnect on
-> /set irc.server.freenode.autojoin "#channel1,#channel2"
-> /set irc.server.freenode.nicks "kpj"
-> /set irc.server.freenode.command "/msg nickserv identify <password>"
-> /save
```
