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
- dedicated loadbalancer (nginx/rpi 4gb?)
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
  - configure ssd as boot device
    - [rock5a](./2_setup/infrastructure/OS/armbian/ssd-boot-device/rock5a/readme.md)
    - [rpi4b](./2_setup/infrastructure/OS/armbian/ssd-boot-device/rpi4b/readme.md)
- Ubuntu Server (Custom Cloud Image)
  - Create Custom Image using packer
  - [cloud init test environment](./2_setup/infrastructure/OS/ubuntu-server/cloud-init-test-env.md)


## [Software](./2_setup/software/)

### Build tools
- Packer
- Github Actions

### [GitOps](./2_setup/software/GitOps)
- External Secrets
- ArgoCD
  - rootapp setup

# [kubernetes](./2_setup/software/kubernetes)
- RKE2
- envoy gateway
- metalLB
- reloader

### Infrastack
- Longhorn
- key management system = to decide, hashicorp vault? look at integrations.
- identity provider (keyclock / goauthentik)

---


## [3. Roadmap](./3_roadmap)

---
