# EdgeCloud

## Overview

This project details the creation of a fully containerized local cloud infrastructure, built entirely on Kubernetes and containers—no virtual machines. The setup is designed for scalability, leveraging low-powered servers and edge devices (such as Raspberry Pi 4B, Rock5A) to form a robust, distributed service mesh. By continuously expanding the system with additional edge clusters, this project showcases a highly flexible and scalable cloud environment.

The homelab uses an old desktop as the central tooling host, with Armbian and Ubuntu forming the base OS. Custom images are automated through pipelines and Packer, ensuring efficient deployment across all nodes. DevOps workflows are handled using GitOps tools like ArgoCD, and Kubernetes infrastructure is powered by RKE2, allowing seamless orchestration across multiple edge clusters.

The unique strength of this setup lies in its decentralized nature—scalability is achieved by adding more low-power devices, making it cost-effective and highly adaptable. This architecture not only makes it ideal for homelabs or smaller-scale environments but also opens up the potential for a decentralized, affordable alternative to expensive public cloud services. By creating a service mesh across many edge clusters, the project demonstrates the feasibility of running cloud services on distributed infrastructure, hinting at a potential SaaS solution that is both cost-effective and highly scalable.

This repository covers the entire process—from hardware, network, storage configuration, automated OS builds, Kubernetes orchestration, to establishing a service mesh—all aimed at building a dynamic, scalable local cloud.


[//]: # (This project details the creation of a fully containerized local cloud infrastructure, built entirely on Kubernetes and containers—no virtual machines. The setup is designed for scalability, leveraging low-powered servers and edge devices &#40;such as Raspberry Pi 4B, Rock5A&#41; to form a robust, distributed service mesh. By continuously expanding the system with additional edge clusters, this project showcases a highly flexible and scalable cloud environment.)

[//]: # ()
[//]: # (The homelab uses an old desktop as the central tooling host, with Armbian and Ubuntu forming the base OS. Custom images are automated through pipelines and Packer, ensuring efficient deployment across all nodes. DevOps workflows are handled using GitOps tools like ArgoCD, and Kubernetes infrastructure is powered by RKE2, allowing seamless orchestration across multiple edge clusters.)

[//]: # ()
[//]: # (The unique strength of this setup lies in its decentralized nature—scalability is achieved by adding more low-power devices, making it cost-effective and highly adaptable. The ultimate goal is to establish a comprehensive service mesh across numerous edge clusters, demonstrating the potential of distributed cloud services.)

[//]: # ()
[//]: # (This documentation covers the entire process—from hardware configuration, container-based OS builds, Kubernetes orchestration, to establishing a service mesh—all aimed at building a dynamic, scalable local cloud.)


[//]: # (This project outlines the setup of a complete local cloud infrastructure from scratch, transforming a homelab into a scalable environment for running services like Platform as a Service &#40;PaaS&#41; and Function as a Service &#40;FaaS&#41;.)

[//]: # ()
[//]: # (Leveraging a mix of hardware, including an old desktop serving as the primary tooling host and various SBCs &#40;Raspberry Pi 4B, Rock5A&#41;, mini servers, and custom networking &#40;OpenWRT firewall&#41;, I’ll build a flexible development and production-ready system.)

[//]: # ()
[//]: # (The stack will be based on Linux, primarily Armbian and Ubuntu, with custom images automated through pipelines and Packer. DevOps processes will be managed using GitOps tools like ArgoCD, while the Kubernetes infrastructure will rely on RKE2 for orchestration. Security, automation, CI/CD pipelines, and service management will all be integrated, providing a full view into how to design, deploy, and maintain a local cloud environment.)

[//]: # ()
[//]: # (This documentation covers the entire journey—from hardware configuration to custom OS builds, software setup, and Kubernetes orchestration—designed for anyone looking to recreate or extend such an environment.)

---

[//]: # (#DONT REMOVE BELOW -- this one might be better ???????)

[//]: # (This project details the creation of a self-hosted, decentralized edge cloud that is fully powered by Kubernetes and containers—without relying on virtual machines or public cloud services. Designed for homelab enthusiasts, small businesses, or developers, the project leverages low-powered edge devices like Raspberry Pi 4B and Rock5A to create a scalable, distributed service mesh. Unlike solutions like KubeEdge, which depend on hybrid cloud-edge architectures, this project is focused entirely on building a local, self-contained cloud environment that is independent of cloud infrastructure.)

[//]: # ()
[//]: # (By continuously expanding the system with additional edge clusters, this setup demonstrates the flexibility and scalability of cloud infrastructure that runs entirely on local hardware, without incurring the high costs of public clouds.)

[//]: # ()
[//]: # (The project uses an old desktop as the central tooling server, with Armbian and Ubuntu as the base OS. Custom images are built and deployed through pipelines and Packer, ensuring efficient automation across all nodes. GitOps processes are managed via ArgoCD, and Kubernetes &#40;RKE2&#41; handles orchestration across a distributed network of edge devices.)

[//]: # ()
[//]: # (The unique strength of this project lies in its decentralized architecture: scalability is achieved by adding more low-powered servers, making it a cost-effective alternative to expensive public cloud services. The ultimate goal is to create a service mesh that spans multiple edge clusters, demonstrating the power of distributed cloud services at a fraction of the cost.)

---

## Sections

### [Build](./build)
This folder is used to hold all the scripts and configs for creating our custom images with hashicorp's ``Packer``
### [docs](./docs)
This folder holds all the documentation related to the cluster-mode project.
### [manifests](./manifests)
This folder holds all the kubernetes manifest files used in the cluster-mode clusters. This folder is referenced by the rootapp.


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
