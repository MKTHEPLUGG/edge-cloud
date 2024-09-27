# Official Documentation for the cluster-mode / mikeshop2.0 project

**Create table of contents for all the documentation here**

---
# 1. Architecture

1. Main Architecture Drawing
2. infastructure devices / choices / reasoning
3. [Flows Overview](./architecture/flows)

## 2. [Roadmap](./roadmap)

---

---
#3. [Setup](./setup/)

## [Infrastructure](./setup/infrastructure)

### [Hardware](./setup/infrastructure/hardware)

- x86 custom ubuntu server main tooling host
- SBC & other edge devices downstream
- dedicated loadbalancer (nginx/rpi 4gb?)
- dual-boot docs
- storage docs
  - DIY NAS on main host

### [Network](./setup/infrastructure/network)

- OpenWRT Firewall
- Network policies
- Security Hardening

### [OS](./setup/infrastructure/OS)

- Armbian (ubuntu based) => to customize with packer
  - configure ssd as boot device
    - [rock5a](./setup/infrastructure/OS/armbian/ssd-boot-device/rock5a/readme.md)
    - [rpi4b](./setup/infrastructure/OS/armbian/ssd-boot-device/rpi4b/readme.md)
- Ubuntu Server (Custom Cloud Image)
  - [cloud init test environment](./setup/infrastructure/OS/ubuntu-server/cloud-init-test-env.md)


## [Software](./setup/software/)

### Build tools
- Packer
  - Use packer to create custom images
- Github Actions

### [GitOps](./setup/software/GitOps)
- External Secrets
- ArgoCD
  - rootapp setup
  - Kustomize

# [kubernetes](./setup/software/kubernetes)
- RKE2
  - security hardening
    - oidc
    - network policies
    - kubeconfig file, create something like azure has for AKS.
- envoy gateway
- metalLB
- reloader

### Infrastack
- Longhorn
- key management system = to decide, hashicorp vault? look at integrations.
- identity provider (keyclock / goauthentik)

---



