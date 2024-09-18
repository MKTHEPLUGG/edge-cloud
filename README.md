# Cluster Mode Project

In this Project I'll be detailing how to setup a local cloud from scratch using linux and rancher kubernetes environment 2.

A local cloud like this could be used to host various managed services like PaaS, FaaS, etc.

## Physical / Hardware
1. Devices
2. Connectivity

## Network
1. Router / Firewall setup => openwrt

## Storage
1. DIY NAS
2. Longhorn

## OS
1. ubuntu
    1. cloud-init config
2. armbian (ubuntu based version) for easy integration with our SBC's.
    1. boot config
    2. cloud-init config 

## Software
1. RKE
2. Packer

## TODO

- look into cloud init (done) => automate with packer => pipeline for packer, local host the runners.
- netboot / usb/nvme boot => rpi done rock5a issues with spi boot. Probably power delivery issue.
- Create Storage Docs => NAS config
- Create RKE Docs
- ~~Create Firewall Docs~~