# **Firewall Setup for ClusterMode Project**

## **Introduction**

The goal of this clustermode project is to create a multi site kubernetes cluster to be able to create 1 giant or multiple smaller clusters at multiple sites and linking them through Rancher.

To achieve a multi-site setup we'll ofcourse need a firewall capable of creating a Virtual Private Network. I'll probably be using `wireguard` for this. I had previously setup a firewall using [opensense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html) but for some reason this will no longer boot.

Untill I can try flashing the hardware with latest firmware I was thinking about using OpenWRT instead, as it offers the same functionality and is more lightweight. Since we will have multiple sites and possibily need firewalls everywhere it looks best to me to base it on as few resources as possibly needed.

## improvements:

- add ssl config to admin interface


## **Install OpenWRT**

1. **Create Bootable USB**:
    obtain the [image](https://downloads.openwrt.org/), look for your specific [device](https://openwrt.org/toh/views/toh_standard_all)  and flash it onto a USB.

2. **Flash the firmware** (if needed, if you use the combined image and flash it to the interal storage with SSD you don't need to perform this step):
    Consult this [link](https://openwrt.org/toh/views/toh_standard_all) to find your device and correct image. Afterwards follow this [guide](https://openwrt.org/docs/guide-quick-start/factory_installation)

3. **Install [OpenWRT](https://openwrt.org/docs/guide-quick-start/start)**:
    
   3.1 **Identify Target Device**:  
   Since `lsblk` is not available, you can use `df` or `cat /proc/partitions` to get more information about your available disks.

   ```bash
   cat /proc/partitions
   ```
   
   3.2 **Set Root Password**:  
   Set a root password to secure access:

   ```bash
   passwd
   ```
   
   3.2 **Flash the Target Disk**:  
   Assuming you have identified your internal storage (let's say it's `/dev/sda`), the next step is to copy the OpenWRT root filesystem from the USB drive to the internal storage.

   ```bash
   dd if=/dev/sdb of=/dev/sda bs=4M
   ```

   3.3 **Sync and Reboot**:  
   After copying, ensure all data is written to the disk:

   ```bash
   sync
   ```
   
   Then, reboot your machine and remove the USB device: 

   ```bash
   reboot
   ```

   3.4 **(optional) Install `parted` and `resize2fs`**:
   After rebooting, you will need to install the tools required to resize the partition and filesystem:

   - **Update the package list** to ensure the latest packages are available:

     ```bash
     opkg update
     ```

   - **Install `parted`** to manage partition resizing:

     ```bash
     opkg install parted
     opkg install fdisk
     ```

   - **Install `resize2fs`** (part of the `e2fsprogs` package) to resize the ext4 filesystem:

     ```bash
     opkg install e2fsprogs
     ```

   3.5 **Resize Partition and Filesystem**:
   Now that `parted` and `resize2fs` are installed, you can resize the partition to use the full disk space:

   - **Identify the Disk Partition**:
   
     Use `lsblk` or `fdisk` to verify the partitions on your target disk (e.g., `/dev/sda`):

     ```bash
     lsblk
     fdisk -l
     ```

   - **Resize the Partition Using `parted`**:

     Launch `parted` to modify the partition:

     ```bash
     parted /dev/sda
     ```

     In the `parted` prompt, resize the partition to use the full disk (assuming the partition to resize is `/dev/sda2`):

     ```bash
     resizepart 2 100%
     ```

     Exit `parted`:

     ```bash
     quit
     ```

   - **Resize the Filesystem**:

     Now that the partition has been resized, use `resize2fs` to expand the filesystem to fill the new partition size:

     ```bash
     resize2fs /dev/sda2
     ```

   - **Verify the Resize**:

     Check that the filesystem now uses the full disk space:

     ```bash
     df -h
     ```

--- 

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
uci set network.lan.netmask='255.255.255.0' # if not already set
```

If you want to change the IP range to something else, just replace `192.168.2.1` and `255.255.255.0` with the desired IP address and subnet mask.


### 3. Update the DHCP Range

Check your current DHCP config
```bash
cat /etc/config/dhcp
```

If you are using DHCP on the LAN interface, you should also update the DHCP range to match the new IP range:

```bash
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.lan.dhcp_option='3,192.168.2.1'
```

Replace `192.168.2.1` with your new LAN IP address, and adjust the `start`, `limit`, and `leasetime` values as needed. More docs about the dhcp options [here](https://www.iana.org/assignments/bootp-dhcp-parameters/bootp-dhcp-parameters.xhtml)

You can combine multiple options in one command by separating them with spaces:
````shell
uci set dhcp.lan.dhcp_option='3,192.168.2.1 6,8.8.8.8 42,192.168.2.5'
````

### 4. Set wan IP to static

To set your WAN interface to a static IP in OpenWRT, you'll need to configure it through UCI (Unified Configuration Interface) or by directly editing the network configuration file (`/etc/config/network`).

Here are the steps to set a static IP for your WAN interface:

### Option 1: Using UCI Commands

check your current network settings with 
   ```bash
   cat /etc/config/network
   ```

1. **Set the protocol to static**:
   This tells the WAN interface to use a static IP configuration rather than DHCP.

   ```bash
   uci set network.wan.proto='static'
   ```

2. **Set the static IP address**:
   Replace `192.168.1.2` with your desired static IP.

   ```bash
   uci set network.wan.ipaddr='192.168.1.2'
   ```

3. **Set the netmask**:
   Specify the appropriate subnet mask.

   ```bash
   uci set network.wan.netmask='255.255.255.0'
   ```

4. **Set the gateway IP**:
   This is the IP address of the gateway (router).

   ```bash
   uci set network.wan.gateway='192.168.1.1'
   ```

5. **Set DNS servers** (optional):
   You can set one or more DNS servers for your WAN interface.

   ```bash
   uci set network.wan.dns='8.8.8.8 8.8.4.4'
   ```

6. **Commit the changes**:
   This applies the new configuration.

   ```bash
   uci commit network
   ```

7. **Restart the network service**:

   ```bash
   /etc/init.d/network restart
   ```

### Option 2: Editing `/etc/config/network` Directly

1. **Edit the network file**:

   ```bash
   vi /etc/config/network
   ```

2. **Modify the WAN section**:
   Find the `config interface 'wan'` section and modify it to include the static IP settings.

   Example configuration:
   ```bash
   config interface 'wan'
       option proto 'static'
       option ipaddr '192.168.1.2'
       option netmask '255.255.255.0'
       option gateway '192.168.1.1'
       option dns '8.8.8.8 8.8.4.4'
   ```

3. **Save and exit**: After editing, save the file and exit the text editor.

4. **Restart the network service**:

   ```bash
   /etc/init.d/network restart
   ```

### 5. Apply and Commit the Changes

After making the changes, you need to commit the configuration and restart the network service for the changes to take effect:

```bash
uci commit network
uci commit dhcp
service network restart
service dnsmasq restart
```

---

## Configure USB Wi-Fi Adapter

### 1. Obtain Correct Drivers

I have a ``TP-Link AC1300 model Archer T4U``. After some research, I've found that this chipset is based on ``Realtek RTL8812AU``.

### 2. Install the Driver on OpenWrt

To get this USB Wi-Fi adapter working on OpenWrt, follow these steps:

#### Step 1: Update the Package List

First, make sure your package list is up-to-date by running the following command:

```bash
opkg update
```

#### Step 2: Install the Appropriate Driver

Install the driver that supports the Realtek RTL8812AU chipset:

```bash
opkg install kmod-rtl8812au-ct
```

If this driver doesn't work, you can alternatively try:

```bash
opkg install kmod-rtl8812au
```

but it is highly recommended to use the ``CT packages`` as this stands for ``Community Tuned``. These packages are tuned by the community for OpenWRT and thus are considerd to be stable.

#### Step 3: Reboot Your Device

After the driver is installed, reboot your OpenWrt device to load the new driver:

```bash
reboot
```

### 3. Verify That the Device is Recognized

After the reboot, you need to verify that the USB Wi-Fi adapter is recognized and functioning correctly.

#### Step 1: Check USB Device Recognition

You can check if the device is recognized by running:

```bash
dmesg | grep -i usb
```

Look for output lines that indicate your USB Wi-Fi adapter, such as references to the Realtek chipset or similar.

#### Step 2: Check Wireless Interfaces

To ensure that the wireless interface has been correctly initialized, run:

```bash
iw dev
```

This command lists all wireless interfaces. You should see a new interface, typically named `wlan0` or similar, representing your USB Wi-Fi adapter.

#### Step 3: Verify Interface in LuCI

Finally, you can also verify the presence of the wireless interface via the OpenWrt web interface (LuCI):

1. Log into your OpenWrt LuCI web interface.
2. Navigate to **Network > Wireless**.
3. You should see your USB Wi-Fi adapter listed as an available wireless device.

If all these checks pass, your TP-Link Archer T4U Wi-Fi adapter is successfully recognized and ready to be configured for your network.

### 4. Configure the USB Adapter as an Access Point in OpenWRT via the CLI

To enable our router to advertise a wireless connection we will configure the USB Adapter as an access point. This will be usefull for connecting devices to troubleshoot the router.

#### Step 1: SSH into Your OpenWrt Device

First, you'll need to SSH into your OpenWrt device from a terminal on your computer.

```bash
ssh root@192.168.10.1
```

Replace `192.168.10.1` with the IP address of your OpenWrt device if it's different.

#### Step 2: Verify the Wireless Interface

List your network interfaces to identify the wireless interface:

```bash
iw dev
```

Typically, the wireless interface will be named something like `wlan0`.

#### Step 3: Install Necessary Packages (If Not Already Installed)

Ensure that the necessary packages for Wi-Fi functionality are installed:

```bash
opkg update
opkg install wpad kmod-rtl8812au-ct
```

If you already have these installed, you can skip this step.

#### Step 4: Configure the Wireless Interface

Edit the wireless configuration file to set up the interface as an access point:

```bash
vi /etc/config/wireless
```

In this file, you should see an existing configuration block for your `wlan0` interface. If not, you can create one. The configuration should look something like this:

```bash
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'pci0000:00/0000:00:1d.0/usb1/1-1/1-1.2/1-1.2:1.0'
        option channel '36'  # Keep 36 if using 5GHz; change to a 2.4GHz channel like 6 if using 2.4GHz
        option band '5g'  # Use '2g' if switching to 2.4GHz
        option htmode 'VHT20'  # Or VHT40/VHT80 for 5GHz, HT20/HT40 for 2.4GHz
        option disabled '0'  # Enable the Wi-Fi

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OpenWrt'  # Change to your desired SSID
        option encryption 'psk2'  # WPA2 encryption
        option key 'yourpassword'  # Replace with a strong password
```

### Explanation of Key Options:
- **`channel`**: Choose a channel that is not heavily used in your environment. Channel 36 is for 5GHz; if using 2.4GHz, you might select channel 6.
- **`band`**: Specifies the frequency band (`5g` for 5GHz, `2g` for 2.4GHz).
- **`htmode`**: High Throughput mode. For 5GHz, use `VHT20`, `VHT40`, or `VHT80`. For 2.4GHz, use `HT20` or `HT40`.
- **`ssid`**: Set this to the name you want your Wi-Fi network to broadcast.
- **`encryption` and `key`**: Use `psk2` for WPA2 encryption and set a strong password.

#### Step 5: Configure the Network Interface

This step is not needed because your `br-lan` device already acts as a bridge, automatically including all interfaces assigned to it, including the Wi-Fi interface, which we have linked to the LAN by setting the `option network 'lan'` in the wireless setup.

#### Step 6: Commit Changes and Restart the Network

After making these changes, commit the changes and restart the network services:

```bash
/etc/init.d/network restart
```

This command will apply the changes and restart the network services on your OpenWrt device.

#### Step 7: Verify the Wireless AP

Finally, you can verify that the Wi-Fi AP is up and running by checking the status of the wireless interface:

```bash
iw dev wlan0 info

# or Troubleshoot
logread | grep wlan0
```

This command should display information about the Wi-Fi interface, including its SSID, mode, and operational channel. You can also scan for available networks from a laptop or another device to confirm that your new Wi-Fi network is visible and accessible.


---

## **Configure Wireguard [Server](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)**

### 1. Preparation

Install the required packages and specify configuration parameters for the VPN server. Login with the root user.

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
mkdir -p pki
cd pki
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
# by default zones are not used. rename your interfaces with the correct zone
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

## **Configure Wireguard [Client](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client)**

however in this case we will not be linking an openwrt router via vpn. We'll mainly be using it for desktop based clients to connect. Below some docs for this.

### Step 1: Install WireGuard on the Client

#### For Linux:
```bash
sudo apt update
sudo apt install wireguard
```

#### For Windows:
1. Download and install the WireGuard client from [WireGuard for Windows](https://www.wireguard.com/install/).
2. Open the WireGuard app after installation.

### Step 2: Configure the Client

Now that you have the keys, the next step is to configure your client with them.

#### **Create a WireGuard Client Configuration File**

Create a WireGuard configuration file on the client (for Linux, place it under `/etc/wireguard/wg0.conf`; for Windows, you will paste it into the GUI). Here’s what the configuration would look like:

```ini
[Interface]
PrivateKey = <client_private_key>        # Use the content of wgclient.key
Address = 192.168.9.2/24, fd00:9::2/64   # IPs you assign to the client
DNS = 192.168.9.1                       # Optional, point to the server for DNS

[Peer]
PublicKey = <server_public_key>          # Use the content of wgserver.pub
PresharedKey = <preshared_key>           # Use wgclient.psk if you're using a pre-shared key
Endpoint = <server_public_ip>:51820      # The public IP and port of your OpenWRT server
AllowedIPs = 0.0.0.0/0, ::/0             # Route all traffic through the VPN
PersistentKeepalive = 25
```

Replace the placeholders with the following:

- **`<client_private_key>`**: This is the content of the `wgclient.key` file you generated earlier.
- **`<server_public_key>`**: This is the content of the `wgserver.pub` file from the server.
- **`<preshared_key>`**: This is optional, only include if you are using a pre-shared key (`wgclient.psk`).
- **`<server_public_ip>`**: This should be the public IP address (or domain name) of your WireGuard server, along with the port (`51820` by default).

#### **For Linux**:
Save the configuration as `/etc/wireguard/wg0.conf`. Then, start the VPN connection:

```bash
sudo wg-quick up wg0
```

#### **For Windows**:
1. Open the WireGuard client app.
2. Click **Add Tunnel**, then **Create from File**.
3. Paste the configuration file content into the editor.
4. Click **Activate** to start the connection.

### Step 3: Add the Client to the Server Configuration ( already done in server config )

Now, go back to your WireGuard server (OpenWRT) and add the client as a peer to your server configuration. You can edit your server configuration file (likely `/etc/wireguard/wg0.conf`) or modify the UCI settings via the command line.

#### **Add the Client Peer on the Server**:

If you're using UCI to configure the server, you can add the client peer like this:

```bash
uci set network.wgclient="wireguard_vpn"
uci set network.wgclient.public_key="<client_public_key>"      # Use wgclient.pub content
uci set network.wgclient.preshared_key="<preshared_key>"       # Only if you're using a pre-shared key (wgclient.psk)
uci add_list network.wgclient.allowed_ips="192.168.9.2/32"     # Client's VPN IP
uci add_list network.wgclient.allowed_ips="fd00:9::2/128"      # Client's IPv6 VPN IP
uci commit network
service network restart
```

Or, if you're editing the `/etc/wireguard/wg0.conf` directly, add the following to your `wg0.conf` on the server:

```ini
[Peer]
PublicKey = <client_public_key>          # Use wgclient.pub content
PresharedKey = <preshared_key>           # Only if you're using a pre-shared key
AllowedIPs = 192.168.9.2/32, fd00:9::2/128  # Client's VPN IP
```

### Step 4: Test the Connection

- **On Linux**: Run `sudo wg-quick up wg0` to bring up the connection and check the status using `wg`.
- **On Windows**: Click **Activate** in the WireGuard app to start the connection.

No extra config is needed all traffic is routed via the tunnel because we set 0.0.0.0/0 as allowed IP.

## extra vpn [config](https://openwrt.org/docs/guide-user/services/vpn/wireguard/extras)

---

## Troubleshooting



### Common config files

1. **`/etc/config/firewall`** rules / nat / ...
2. **`/etc/config/network`** interfaces
3. **`/etc/config/dhcp`** for dns and dhcp


4. **Restart the Firewall**:

   After adjusting the configuration, restart the firewall to apply the new rule:

   ```bash
   /etc/init.d/firewall restart
   ```





[//]: # (### Step 1: Ensure Outbound NAT for VPN Clients)

[//]: # ()
[//]: # (This step is crucial to allow VPN clients to access the internet. It ensures that VPN traffic can be NATed to the WAN interface so it can route to external networks.)

[//]: # ()
[//]: # (1. **Enable Outbound NAT &#40;Masquerading&#41; on the WAN Zone**:)

[//]: # (   Ensure that masquerading is enabled on the WAN zone. This will allow traffic from your VPN clients &#40;coming through the LAN zone&#41; to be NATed when going out through the WAN.)

[//]: # ()
[//]: # (   Run the following commands: [ already enabled by default ])

[//]: # (   ```bash)

[//]: # (   uci set firewall.wan.masq='1'  # Masquerading enabled for the WAN zone)

[//]: # (   uci commit firewall)

[//]: # (   /etc/init.d/firewall restart)

[//]: # (   ```)

[//]: # ()
[//]: # (   This rule ensures that traffic from the VPN interface &#40;`vpn`&#41;, which is part of the `lan` zone, is translated when going out to the internet via the WAN interface.)

[//]: # ()
[//]: # (   to delete a rule run:)

[//]: # (   ```bash)

[//]: # (   uci show firewall)

[//]: # (   uci delete firewall.@rule[10]  # Remove any rule)

[//]: # (   uci commit firewall)

[//]: # (   /etc/init.d/firewall restart)

[//]: # (   ```)

[//]: # (---)

### Step 2: Verify DNS Forwarding

No additional DNS changes are needed in your setup since DNS is already functioning correctly. To verify or make any DNS-related changes:

1. **Check Current DNS Forwarding**:
   To see the upstream DNS servers your router is using, run:
   ```bash
   cat /tmp/resolv.conf.d/resolv.conf.auto
   ```

   This will show which DNS servers your router forwards queries to. Typically, this should list external DNS servers like `8.8.8.8`.

2. **(Optional) Set a Specific Upstream DNS Server**:
   If necessary, you can set the upstream DNS server:
   ```bash
   uci set dhcp.@dnsmasq[0].server='8.8.8.8'  # Google DNS as an example
   uci commit dhcp
   /etc/init.d/dnsmasq restart
   ```

---

### Step 3: No Extra Firewall Rules Needed

Since your **VPN** interface is already part of the **LAN zone** (`firewall.lan.network='lan' 'vpn'`), traffic between VPN clients and the LAN is automatically allowed. No additional firewall rules (such as `Allow-DNS-VPN`) are required.

### Step 4: Testing DNS and Internet Access

1. **Test DNS from VPN Client (Linux)**:
   You can verify DNS resolution from your VPN client:
   ```bash
   nslookup google.com 192.168.9.1
   ```

2. **Test Internet Access from VPN Client**:
   Verify internet access from your VPN client by using `curl` or similar tools:
   ```bash
   curl -I https://www.google.com
   ```

---

