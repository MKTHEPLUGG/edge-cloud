# **Config for ARMBian OS**

[//]: # (since we started using the ROCK5a Board as our main SBC the dietpi image doesn't seem to want to boot on this device. Possibly a firmware issue but I'm looking into using a more natively maintained distro and armbian seems to be quite nice.)

[//]: # ()
[//]: # (Images can be found at the [official download mirrors]&#40;https://fi.mirror.armbian.de/dl/rock-5a/archive/&#41;. I'm using the image ``Armbian_24.5.3_Rock-5a_noble_vendor_6.1.43_minimal.img.xz`` this one is based on ubuntu LTS. I was thinking of also trying ``Armbian_24.5.3_Rock-5a_bookworm_vendor_6.1.43_minimal.img.xz`` as this one is based on debian and probably less bloated.)

Description of all the OS flavors used in this project. Ubuntu based Armbian is the main supported distro. However only a desktop version is available on ``Quartz4a`` so I will be testing out the debain based one aswell.

## Images

### Raspberry Pi

Images can be found at the [official download mirrors](https://fi.mirror.armbian.de/dl/rpi4b/archive/). 

**Debian**
- Armbian_24.8.1_Rock-5a_bookworm_vendor_6.1.75_minimal.img.xz

**Ubuntu**
- Armbian_24.8.1_Rpi4b_noble_current_6.6.45_minimal.img.xz

### Quartz4a

Images can be found at the [official download mirrors](https://fi.mirror.armbian.de/archive/quartz64a/archive/). 

**Debian**
- Armbian_23.8.1_Quartz64a_bookworm_current_6.1.50.img.xz

**Ubuntu**
- Armbian_23.8.1_Quartz64a_jammy_current_6.1.50_xfce_desktop.img.xz



### Rock5a

Images can be found at the [official download mirrors](https://fi.mirror.armbian.de/dl/rock-5a/archive/). 

**Debian**
- Armbian_24.8.1_Rock-5a_bookworm_vendor_6.1.75_minimal.img.xz

**Ubuntu**
- Armbian_24.8.1_Rock-5a_noble_vendor_6.1.75_minimal.img.xz


## **Initial Setup**

### **Hostname & Network Settings Configuration**

Hostname & Network & Keyboard Settings Configuration can be automated using this script on the noble based hosts.

````shell
#!/bin/bash

read -p "Please provide the last digit of the IP (192.168.10.x): " ip_last_digit
read -p "Please provide the hostname: " hostname

# Vars
full_ip="192.168.10.$ip_last_digit"
gateway="192.168.10.1"
dns1="1.1.1.1"
interface="eth0"  # Adjust this if your network interface name is different
netplan_config="/etc/netplan/01-netcfg.yaml"

# Create the Netplan configuration file
cat <<EOL > $netplan_config
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses:
        - $full_ip/24
      routes:
        - to: 0.0.0.0/0
          via: $gateway
      nameservers:
        addresses:
          - $dns1
EOL

# Restrict permissions on the Netplan configuration file
chmod 600 $netplan_config

echo "Netplan configuration file created:"
cat $netplan_config

# Apply the new Netplan configuration
netplan apply

# Change hostname
hostnamectl set-hostname $hostname
echo "$hostname" > /etc/hostname

echo "Hostname changed to $hostname"

# Configure correct keyboard layout
sudo sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard
sudo setupcon

echo "Configuration completed successfully."

# set date and time
sudo timedatectl set-timezone Europe/Brussels
date
````


### **Repeat Process on Other ARMBian Systems**

Whenever you set up a new ARMBian system that boots from an SD card and runs from an SSD, follow these steps to ensure the necessary cgroup configurations are applied.

This guide ensures that your ARMBian system is correctly configured to run RKE2 by enabling the required cgroup features.

# Usefull stuff regarding Armbian OS


1. Restart first run script
    ````shell
    sudo /usr/lib/armbian/armbian-firstrun start
    ````

---



