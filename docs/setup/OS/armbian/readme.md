# **RKE2 Config for ARMBian OS**

since we started using the ROCK5a Board as our main SBC the dietpi image doesn't seem to want to boot on this device. Possibly a firmware issue but I'm looking into using a more natively maintained distro and armbian seems to be quite nice.

Images can be found at the [official download mirrors](https://fi.mirror.armbian.de/dl/rock-5a/archive/). I'm using the image ``Armbian_24.5.3_Rock-5a_noble_vendor_6.1.43_minimal.img.xz`` this one is based on ubuntu LTS. I was thinking of also trying ``Armbian_24.5.3_Rock-5a_bookworm_vendor_6.1.43_minimal.img.xz`` as this one is based on debian and probably less bloated.

## **Prereqs before deploying RKE2**

### **Hostname & Network Settings Configuration**

Hostname & Network Settings Configuration can be semi-automated using this script on the debian based hosts.
ARMBian Already by default offers a network config while deploying so in theory this can be skipped but added a detailed script that can handle the already existing config and replace it if necessary.

````shell
#!/bin/bash

read -p "Please provide the last digit of the IP (192.168.1.x): " ip_last_digit
read -p "Please provide the hostname: " hostname

# vars
full_ip="192.168.1.$ip_last_digit"
gateway="192.168.1.1"
dns1="1.1.1.1"
interface="eth0"  # adjust this if your network interface name is different
dropin_path="/etc/network/interfaces.d/$interface"
main_config="/etc/network/interfaces"

# Check if the interface is already defined in the main config
if grep -q "iface $interface inet" $main_config; then
    echo "Interface $interface is already defined in $main_config."
    echo "Would you like to move this configuration to a drop-in file and replace it? (y/n)"
    read -r response
    if [[ $response == "y" ]]; then
        # Backup the main config file
        cp $main_config $main_config.bak

        # Remove the existing configuration for the interface
        sed -i "/iface $interface inet/,/^$/d" $main_config

        # Create the drop-in configuration file
        cat <<EOL > $dropin_path

# Static IP configuration for $interface
auto $interface
iface $interface inet static
    address $full_ip
    netmask 255.255.255.0
    gateway $gateway
    dns-nameservers $dns1

EOL

        echo "Moved configuration to drop-in file:"
        cat $dropin_path
    else
        echo "Exiting without changes."
        exit 1
    fi
else
    # Create the drop-in configuration file
    cat <<EOL > $dropin_path

# Static IP configuration for $interface
auto $interface
iface $interface inet static
    address $full_ip
    netmask 255.255.255.0
    gateway $gateway
    dns-nameservers $dns1

EOL

    echo "Created drop-in file:"
    cat $dropin_path
fi

# Restart the networking service to apply changes
systemctl restart networking

# Change hostname
hostnamectl set-hostname $hostname
echo "$hostname" > /etc/hostname

echo "Hostname changed to $hostname"
````

### **Enabling cgroup Memory and Hierarchy on Systems Booting from SD and Running from SSD**

#### **Step 1: Identify the SD Card’s Boot Partition**
The first step is to identify the SD card’s boot partition so you can mount it and edit the boot parameters.

1. **List Block Devices:**
   Use the `lsblk` command to identify the SD card and its partitions:
   ```bash
   lsblk
   ```

   You should see an output similar to this:
   ```
   NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   sda           8:0    0 232.9G  0 disk 
   ├─sda1        8:1    0   200M  0 part /boot
   └─sda2        8:2    0 232.7G  0 part /
   mmcblk0     179:0    0 119.1G  0 disk 
   ├─mmcblk0p1 179:1    0   128M  0 part 
   └─mmcblk0p2 179:2    0   119G  0 part 
   ```

   In this example:
   - `/dev/mmcblk0p1` is the boot partition on the SD card.
   - `/dev/mmcblk0p2` is the root partition on the SD card.

#### **Step 2: Mount the SD Card’s Boot Partition**

2. **Create a Mount Point:**
   If you don’t already have a mount point, create one:
   ```bash
   sudo mkdir -p /mnt/sdboot
   ```

3. **Mount the Boot Partition:**
   Mount the SD card’s boot partition to this directory:
   ```bash
   sudo mount /dev/mmcblk0p1 /mnt/sdboot
   ```

#### **Step 3: Edit the `cmdline.txt` File**

4. **Open `cmdline.txt`:**
   Use a text editor to open the `cmdline.txt` file located in the boot partition:
   ```bash
   sudo nano /mnt/sdboot/cmdline.txt
   ```

5. **Add Kernel Parameters:**
   Add the following parameters to the end of the existing line:
   ```bash
   systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory
   ```

   Your `cmdline.txt` file should now look something like this:
   ```
   coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_headphones=0 bcm2708_fb.fbwidth=0 bcm2708_fb.fbheight=0 bcm2708_fb.fbdepth=16 bcm2708_fb.fbswap=1 smsc95xx.macaddr=D8:3A:DD:0E:8D:67 vc_mem.mem_base=0x3f000000 vc_mem.mem_size=0x3f600000 root=PARTUUID=e72d462f-02 rootfstype=ext4 rootwait net.ifnames=0 logo.nologo console=tty1 systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory
   ```

   **Note:** Ensure all parameters are on a single line with spaces between them.

6. **Save and Exit:**
   - Press `Ctrl + X`, then `Y`, and then `Enter` to save the changes and exit.

#### **Step 4: Unmount the Boot Partition**

7. **Unmount the Boot Partition:**
   Unmount the SD card’s boot partition:
   ```bash
   sudo umount /mnt/sdboot
   ```

#### **Step 5: Reboot the System**

8. **Reboot:**
   Reboot the system to apply the changes:
   ```bash
   sudo reboot
   ```

#### **Step 6: Verify the Changes**

9. **Verify cgroup v2 and Memory Controller:**
   After the system reboots, verify that the memory cgroup and unified cgroup hierarchy are enabled:

   - Check if cgroup v2 is active:
     ```bash
     mount | grep cgroup2
     ```

   - Check if the `memory` controller is enabled:
     ```bash
     cat /sys/fs/cgroup/cgroup.controllers
     ```

     You should see something like this:
     ```
     cpuset cpu io memory pids
     ```

### **Repeat Process on Other DietPi Systems**

Whenever you set up a new DietPi system that boots from an SD card and runs from an SSD, follow these steps to ensure the necessary cgroup configurations are applied.

This guide ensures that your DietPi system is correctly configured to run RKE2 by enabling the required cgroup features.

---



