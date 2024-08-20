# **RKE2 Config for DietPi OS**

## **Prereqs before deploying RKE2**

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