# **Firewall Setup for ClusterMode Project**

## **Introduction**

The goal of this clustermode project is to create a multi site kubernetes cluster to be able to create 1 giant or multiple smaller clusters at multiple sites and linking them through Rancher.

To achieve a multi site setup we'll ofcourse need a firewall capable of creating a Virtual Private Network. I'll probably be using `wireguard` for this. I had previously setup a firewall using [opensense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html) but for some reason this will no longer boot.

Untill I can try flashing the hardware with latest firmware I was thinking about using OpenWRT instead, as it offers the same functionality and is more lightweight. Since we will have multiple sites and possibily need firewalls everywhere it looks best to me to base it on as few resources as possibly needed.


## **Installing OpenWRT**

1. **Create Bootable USB**:
    obtain the [image](https://downloads.openwrt.org/) and flash it onto a USB.

2. **Flash the firmware**:
    Consult this [link](https://openwrt.org/toh/views/toh_standard_all) to find your device and correct firmware. Afterwards follow this [guide](https://openwrt.org/docs/guide-quick-start/factory_installation)

3. **Install [OpenWRT](https://openwrt.org/docs/guide-quick-start/start)**:
    
    3.1 **Identify Target Device**:
        Since lsblk is not available, you can use `df` or `cat /proc/partitions` to get more information about your available disks.

    ```bash
    cat /proc/partitions
    ```

    3.2 **Prepare the Target Disk**:
    Assuming you have identified your internal storage (let's say it's `/dev/sda`), the next step is to copy the OpenWRT root filesystem from the USB drive to the internal storage.

    ```bash
    dd if=/dev/sdb of=/dev/sda bs=4M
    ```

    3.3 **Sync and Reboot**:
    After copying, ensure all data is written to the disk:

    ```bash
    sync
    ```

    3.4 **Set Root Password**:
    set a root password to secure access.:

    ```bash
    passwd
    ```

    Then, reboot your machine:

    ```bash
    reboot
    ```


## **Configure Wireguard**

[docs](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)



