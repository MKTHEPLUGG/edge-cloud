# Mikeshop Project

## Overview

In this project, I will detail how to set up a local cloud from scratch using Linux and Rancher Kubernetes environment 2 (RKE2).

The local cloud will be able to host various managed services like PaaS (Platform as a Service), FaaS (Function as a Service), and others.

--

## Sections

### 1. Build
This folder is used to hold all the scripts and configs for creating our custom images with packer
### 2. docs
This folder holds all the documentation related to the mikeshop project.
### 3. manifests
This folder holds all the kubernetes manifest files used in the mikeshop clusters. This folder is referenced by the rootapp. 

[//]: # (1. Router / Firewall setup => openwrt)

[//]: # ()
[//]: # (### Storage)

[//]: # (1. DIY NAS)

[//]: # (2. Longhorn)

[//]: # ()
[//]: # (### OS)

[//]: # (1. Ubuntu)

[//]: # (    1. Cloud-init config)

[//]: # (2. Armbian &#40;Ubuntu-based&#41; for easy integration with our SBCs)

[//]: # (    1. Boot config)

[//]: # (    2. Cloud-init config )

[//]: # ()
[//]: # (### Software)

[//]: # (1. RKE)

[//]: # (2. Packer)

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
