# **Firewall Setup for ClusterMode Project**

## **Introduction**

The goal of this clustermode project is to create a multi site kubernetes cluster to be able to create 1 giant or multiple smaller clusters at multiple sites and linking them through Rancher.

To achieve a multi site setup we'll ofcourse need a firewall capable of creating a Virtual Private Network. I'll probably be using `wireguard` for this. I had previously setup a firewall using [opensense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html) but for some reason this will no longer boot.

Untill I can try flashing the hardware with latest firmware I was thinking about using OpenWRT instead, as it offers the same functionality and is more lightweight. Since we will have multiple sites and possibily need firewalls everywhere it looks best to me to base it on as few resources as possibly needed.


## **Installing OpenWRT**

1. **Create Bootable USB**:
    obtain the [image](https://downloads.openwrt.org/) and flash it onto a USB.

2. **Install [OpenWRT](https://openwrt.org/docs/guide-quick-start/start)**:
    