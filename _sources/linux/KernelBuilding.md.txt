# Building a Custom Linux Kernel

## Getting the source

The latest (stable) source can be downloaded from the [official kernel page](https://www.kernel.org/).


## Creating the config

The used configuration can either be adapted from another distribution or generated from scratch by running

```bash
$ make menuconfig
```

The controls are as follows

* `/`: Search for an item
* `y`: Enable item
* `n`: Disable item

I'd suggest to alter the following parameters

* `CONFIG_LOCALVERSION`: Give your kernel some name

## Compilation & Installation

As you probably already suspected, the kernel can be compiled by simply running

```bash
$ make
```

In order to be able to boot into your kernel, it has to be installed to `/boot`

```bash
$ cp arch/x86/boot/bzImage /boot/vmlinuz-custom
```

You might want to replace `custom` with something you can remember more easily.

Finally, don't forget to install your modules

```bash
$ make modules_install
```


## Creating the initial ramdisk (initrd)

The initial ramdisk can be easily created by calling

```bash
$ mkinitcpio -k <kernel> -g <image>
```

In our case, `<kernel>` would be '/boot/vmlinuz-custom' and `<image>` would be '/boot/initrd-custom.img'.

## Adding the boot entry

In order to actually find your custom kernel on boot, you have to tell grub about it.
Do so by adding a new entry to `/etc/grub.d/40_custom` (or a similarly named file in that directory).

You can also skip this step and let grub generate a default entry by simply calling `grub-mkconfig` as shown below.

In the former case, the entry should look something like

```bash
menuentry 'Linux, the custom one' {
    set root=<partition>
    linux <kernel>
    initrd <image>
}
```

(with `<kernel>`='/boot/vmlinuz-custom' and `<image>`='/boot/initrd-custom.img')

Setting `<partition>` correctly can be a bit tricky. It's of the form '(hdX,Y)', where 'X' encodes the hard drive (0=sda, 1=sdb, ...) and 'Y' the partition.
Consequently, '(hd0,gpt4)' would code for `sda4`.

These changes can then be committed to `/boot/grub/grub.cfg` by running

```bash
$ grub-mkconfig -o /boot/grub/grub.cfg
```
