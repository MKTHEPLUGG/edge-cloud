# Official Documentation for the cluster-mode / mikeshop2.0 project

**Create table of contents for all the documentation here**

---
# 1. Architecture

1. Main Architecture Drawing
2. infastructure devices / choices / reasoning
3. [Flows Overview](./1_architecture/flows)

---
# [2. Setup](./2_setup/)

## [Infrastructure](./2_setup/infrastructure)

### [Hardware](./2_setup/infrastructure/hardware)

- x86 custom ubuntu server main tooling host
- SBC & other edge devices downstream
- dual-boot docs
- storage docs
  - DIY NAS on main host

### [Network](./2_setup/infrastructure/network)

- OpenWRT Firewall
- Network policies
- Security Hardening

### [OS](./2_setup/infrastructure/OS)

- Armbian (ubuntu based) => to customize with packer
  - Create Custom Image using packer
    - rock5a:
      - configure-ssd-boot-device
    - rpi4b
      - configure-ss-boot-device
- Ubuntu Server (Custom Cloud Image)
  - Create Custom Image using packer
  - cloud init test environment

## [Software](./2_setup/software/)

- Packer
- Github Actions
- External Secrets
- RKE2
- Longhorn
- ArgoCD

---


## [3. Roadmap](./3_roadmap)

---
