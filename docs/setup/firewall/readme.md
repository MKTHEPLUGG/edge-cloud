# **Firewall Setup for ClusterMode Project**

## **Introduction**

The goal of this clustermode project is to create a multi site kubernetes cluster to be able to create 1 giant or multiple smaller clusters at multiple sites and linking them through Rancher.

To achieve a multi site setup we'll ofcourse need a firewall capable of creating a Virtual Private Network. I'll probably be using `wireguard` for this. I had previously setup a firewall using [opensense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html) but for some reason this will no longer boot.

Untill I can try flashing the hardware with latest firmware I was thinking about using OpenWRT instead, as it offers the same functionality and is more lightweight. Since we will have multiple sites and possibily need firewalls everywhere it looks best to me to base it on as few resources as possibly needed.


## **Install OpenWRT**

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

## Configure interfaces

### 1. Determine the Current LAN Interface Configuration

First, you need to check the current configuration of the LAN interface.

```bash
uci show network.lan
```

This command will display the current settings for the LAN interface, including the IP address and subnet.

### 2. Change the LAN IP Address and Subnet

You can update the LAN interface to use a new IP range. For example, if you want to change the LAN IP address to `192.168.2.1` with a subnet mask of `255.255.255.0` (or `/24`), you can do so with the following commands:

```bash
uci set network.lan.ipaddr='192.168.2.1'
uci set network.lan.netmask='255.255.255.0'
```

If you want to change the IP range to something else, just replace `192.168.2.1` and `255.255.255.0` with the desired IP address and subnet mask.


### 3. Update the DHCP Range

If you are using DHCP on the LAN interface, you should also update the DHCP range to match the new IP range:

```bash
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.lan.dhcp_option='3,192.168.2.1'
```

Replace `192.168.2.1` with your new LAN IP address, and adjust the `start`, `limit`, and `leasetime` values as needed.

### 4. Apply and Commit the Changes

After making the changes, you need to commit the configuration and restart the network service for the changes to take effect:

```bash
uci commit network
uci commit dhcp
service network restart
service dnsmasq restart
```


## **Configure Wireguard [Server](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)**

### 1. Preparation

Install the required packages and specify configuration parameters for the VPN server.

#### Install Packages
```bash
opkg update
opkg install wireguard-tools
```

#### Configuration Parameters
```bash
VPN_IF="vpn"
VPN_PORT="51820"
VPN_ADDR="192.168.9.1/24"
VPN_ADDR6="fd00:9::1/64"
```

### 2. Key Management

Generate and exchange keys between the server and client.

#### Generate Keys
```bash
umask go=
wg genkey | tee wgserver.key | wg pubkey > wgserver.pub
wg genkey | tee wgclient.key | wg pubkey > wgclient.pub
wg genpsk > wgclient.psk
```

#### Store Keys
```bash
# Server private key
VPN_KEY="$(cat wgserver.key)"

# Pre-shared key
VPN_PSK="$(cat wgclient.psk)"

# Client public key
VPN_PUB="$(cat wgclient.pub)"
```

### 3. Firewall Configuration

Consider the VPN network as private. Assign the VPN interface to the LAN zone to minimize firewall setup. Allow access to the VPN server from the WAN zone.

#### Configure Firewall
```bash
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${VPN_IF}"
uci add_list firewall.lan.network="${VPN_IF}"
uci -q delete firewall.wg
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${VPN_PORT}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. Network Configuration

Configure the VPN interface and peers.

#### Configure Network
```bash
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="wireguard"
uci set network.${VPN_IF}.private_key="${VPN_KEY}"
uci set network.${VPN_IF}.listen_port="${VPN_PORT}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR6}"
```

#### Add VPN Peers
```bash
uci -q delete network.wgclient
uci set network.wgclient="wireguard_${VPN_IF}"
uci set network.wgclient.public_key="${VPN_PUB}"
uci set network.wgclient.preshared_key="${VPN_PSK}"
uci add_list network.wgclient.allowed_ips="${VPN_ADDR%.*}.2/32"
uci add_list network.wgclient.allowed_ips="${VPN_ADDR6%:*}:2/128"
uci commit network
service network restart
```

## **Configure Wireguard [client](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client)**