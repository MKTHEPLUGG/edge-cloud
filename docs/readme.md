# Official Documentation for the cluster-mode / mikeshop2.0 project

**Create table of contents for all the documentation here**

---
## 1. Architecture

1. Main Architecture Drawing
2. Hardware / network layout + devices
3. Flows overview 

---
## 2. Setup

### Infrastructure Layer

- x86 custom ubuntu server main tooling host
- SBC & other edge devices downstream

### Network layer

- OpenWRT Firewall
- Network policies
- Security Hardening

### OS Layer

- Armbian (ubuntu based) => to customize with packer
- Ubuntu Server (Custom Cloud Image)

### Software layer

- Packer
- Github Actions
- External Secrets
- RKE2
- Longhorn
- ArgoCD

---


## 3. [Roadmap](./3_roadmap)

---
