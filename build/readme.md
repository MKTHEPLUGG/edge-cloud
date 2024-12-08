# WIP - Create proper documentation

**maintain packer specific setup build and template to docs/packer and also the docs of the scripts used in packing the images then here put some docs refering to the official docs in the docs dir**

[//]: # (- https://sekureco42.ch/posts/deploy-ubuntu-24.04-with-autoinstall-to-proxmox/)
- https://github.com/nbarnum/packer-ubuntu-cloud-image/tree/main

- look into auto install / cloud init & autoinstall ( full os automation not only config after like cloud config ) / packer / ...

- add proper install docs for qemu env with virtman and kvm etc

- add deep dive docs in how cloud init works with the cdrom and label etc, since this is the solution we used to pack the vm and also check the other options ( http etc )

- Create proper guide 1. Architecture / 2. Setup environment / 3. Detail configuration / 4. Troubleshooting + extra's / 5. Automation via pipelines.

- Figure out how to build arm images on x86 [Link](https://linuxhit.com/build-a-raspberry-pi-image-packer-packer-builder-arm/)

## Cloud-config Architecture

1. **Software**
   - net-tools (done)
   - nfs-common (done)
   - fail2ban (TO DO)
   - zsh / ohmyzsh (TO DO)

2. **Config**
   - keyboard / locales / time


## Script Architecture

1. **Config**
   - users (seems to break cloud init ssh when trying to provision users via cloud config => investigate or put in script )
   - hostname
   - sshd config
   - zsh config + theme
   - custom MODT Message

### Zi a package manager for zsh

- https://github.com/z-shell/zi
- [zi install](https://wiki.zshell.dev/docs/getting_started/installation)