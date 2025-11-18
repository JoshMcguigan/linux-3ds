# Linux for 3DS

This is my personal / unofficial "distro" (using this phrase *extremely* loosely) of the upstream [Linux for 3DS](https://github.com/linux-3ds) project.

### Goals

- Provide a reproducible build environment for kernel, bootloader, and userspace
- Define tested commits of each upstream component known to work together
- Maintain a set of patches with the intent to upstream all of them

## Build

`make all` will build all necessary components and place them in an `output` directory in the root of this repository.

See `.devcontainer/Dockerfile` for the list of dependencies.

## Install

`output/firm_linux_loader.firm` should be copied to your SD card in the `luma/payloads` directory.

The following files should be copied to your SD card in a `linux` directory:
* `output/arm9linuxfw.bin`
* `output/initramfs.cpio.gz`
* `output/nintendo3ds_ctr.dtb`
* `output/nintendo3ds_ktr.dtb`
* `output/zImage`

Alternatively you can use write `sdcard.img` to the SD card.