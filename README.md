# Cluster Mode Project

## Project Overview

In this project, I will detail how to set up a local cloud from scratch using Linux and Rancher Kubernetes environment 2 (RKE2).

The local cloud will be able to host various managed services like PaaS (Platform as a Service), FaaS (Function as a Service), and others.

[//]: # (## Table of Contents)

[//]: # ()
[//]: # (1. [Physical / Hardware]&#40;#physical--hardware&#41;)

[//]: # (    - [Devices]&#40;docs/hardware/devices.md&#41;)

[//]: # (    - [Connectivity]&#40;docs/hardware/connectivity.md&#41;)

[//]: # (2. [Network]&#40;#network&#41;)

[//]: # (    - [Router / Firewall Setup &#40;OpenWRT&#41;]&#40;docs/network/firewall.md&#41;)

[//]: # (3. [Storage]&#40;#storage&#41;)

[//]: # (    - [DIY NAS]&#40;docs/storage/nas.md&#41;)

[//]: # (    - [Longhorn]&#40;docs/storage/longhorn.md&#41;)

[//]: # (4. [Operating Systems &#40;OS&#41;]&#40;#os&#41;)

[//]: # (    - [Ubuntu]&#40;docs/os/ubuntu.md&#41;)

[//]: # (        - [Cloud-init Config]&#40;docs/os/ubuntu/cloud-init.md&#41;)

[//]: # (    - [Armbian &#40;Ubuntu-based&#41;]&#40;docs/os/armbian.md&#41;)

[//]: # (        - [Boot Config]&#40;docs/os/armbian/boot-config.md&#41;)

[//]: # (        - [Cloud-init Config]&#40;docs/os/armbian/cloud-init.md&#41;)

[//]: # (5. [Software]&#40;#software&#41;)

[//]: # (    - [RKE]&#40;docs/software/rke.md&#41;)

[//]: # (    - [Packer]&#40;docs/software/packer.md&#41;)

## Sections

### Physical / Hardware
1. Devices
2. Connectivity

### Network
1. Router / Firewall setup => openwrt

### Storage
1. DIY NAS
2. Longhorn

### OS
1. Ubuntu
    1. Cloud-init config
2. Armbian (Ubuntu-based) for easy integration with our SBCs
    1. Boot config
    2. Cloud-init config 

### Software
1. RKE
2. Packer

## TODO

- Look into cloud-init (done) => automate with packer => pipeline for packer, local host the runners.
- Netboot / usb/nvme boot => Raspberry Pi done, Rock5a issues with SPI boot (likely power delivery issue).
- Create [Storage Docs](docs/setup/hardware/storage/NAS/readme.md) => NAS config
- Create RKE2 setup docs
- find secret management solution
- explore wake on lan capabilities
- ~~Create Firewall Docs~~
- encrypt openwrt admin interface with ssl
- tryout istio
