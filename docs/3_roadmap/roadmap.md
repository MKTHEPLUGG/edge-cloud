# **ROADMAP**

1. Create physical infrastructure = DONE
2. Create main tool server used to be the egg in the chicken egg story.
3. Create customized image
4. Properly define Architecture for RKE2 Setup Goal is to create a PaaS/FaaS environment.

## Networking Stack

### CNI

For the networking stack my eye has fallen on ´Canal´. Because it provides easy to configure VXLAN with Flannel and the advanced features of the Calico project.

- [CANAL WITH WG](https://docs.tigera.io/calico/latest/network-policy/encrypt-cluster-pod-traffic#enable-wireguard-for-a-cluster)

### Firewall/Router

For the router I have an old firewall that can be used. I'm trying to setup a wifi adapter to provide wifi access to the firewall. Currently need to test a driver that works in AP mode

- https://github.com/gnab/rtl8812au
- https://github.com/morrownr/8812au

## Hardware Stack

the Rock5A SBC with 16GB of ram and 8 cores seems to be the perfect solution for worker nodes. Due to costs I will first use some old 8gb SBC's I still have laying around.