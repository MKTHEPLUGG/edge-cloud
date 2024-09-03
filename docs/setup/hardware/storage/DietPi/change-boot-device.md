# Change Boot Device

## Native Boot straight from SSD.

1. **Obtain the `PARTUUIDs` of the SSD Partitions**:
   - Run the following command to get the `PARTUUIDs` of the SSD partitions:
     ```bash
     sudo blkid /dev/sda1 /dev/sda2
     ```
   - The output will look something like this:
     ```
     /dev/sda1: UUID="ABCD-1234" TYPE="vfat" PARTUUID="12345678-01"
     /dev/sda2: UUID="abcd1234-5678-90ab-cdef-1234567890ab" TYPE="ext4" PARTUUID="12345678-02"
     ```

2. **Update the `fstab` on the SSD**:
   - Edit the `fstab` file on the SSD to use the correct `PARTUUIDs` or `UUIDs`:
     ```bash
     sudo nano /mnt/ssd_root/etc/fstab
     ```
   - Update the entries for the root (`/`) and boot (`/boot`) partitions:
     ```bash
     PARTUUID=12345678-02 / ext4 noatime,lazytime,rw 0 1
     PARTUUID=12345678-01 /boot vfat noatime,lazytime,rw 0 2
     ```
   - Replace `12345678-01` and `12345678-02` with the actual `PARTUUIDs` you obtained from the `blkid` command.


3. **Edit the Boot Configuration**:
   - Edit the `cmdline.txt` file on the SSD's boot partition to use the correct `PARTUUID` for the root partition:
     ```bash
     sudo nano /mnt/ssd_boot/cmdline.txt
     ```
   - Replace the `root=PARTUUID=...` entry with the `PARTUUID` of the SSD’s root partition:
     ```
     root=PARTUUID=12345678-02 rootfstype=ext4 rootwait
     ```
   - Save and exit the file.


4. **Reload `systemd` Configuration**:
   - Before or after editing the `fstab` on the SSD (if it’s mounted), reload `systemd` to ensure it recognizes any new or changed mount configurations:
     ```bash
     sudo systemctl daemon-reload
     ```
    

### Step 4: Verify Boot from SSD

1. **Check the Boot Device**:
   - Once the Raspberry Pi has booted, log in and verify that the system is running from the SSD:
     ```bash
     lsblk
     ```
   - Ensure that the root filesystem (`/`) is mounted from the SSD (`/dev/sda2` or equivalent).

2. **Clean Up**:
   - If everything is working correctly, you can repurpose or securely erase the SD card.

--- 

## Hybrid Setup - Boot from SD Card, Root on SSD

In this hybrid setup, the SBC will use the SD card to boot but will then switch to the SSD for the root filesystem. This can provide faster boot times and reduce wear on the SD card.

### ARMbian


### DietPi

#### 1. Prepare the SD Card

1. **Retain the Boot Partition on the SD Card**:
   - Leave the `/boot` partition on the SD card as it is. This partition contains the bootloader and other necessary files to start the boot process.

2. **Update the `cmdline.txt` on the SD Card**:
   - The `cmdline.txt` file on the SD card tells the bootloader where to find the root filesystem.
   - Open `cmdline.txt` for editing:
     ```bash
     sudo nano /boot/cmdline.txt
     ```
   - Modify the `root=` parameter to point to the SSD’s root partition using the `PARTUUID` you obtained earlier:
     ```
     root=PARTUUID=<Your-SSD-Root-PARTUUID> rootfstype=ext4 rootwait
     ```
   - For example, if the `PARTUUID` of the SSD's root partition is `e72d462f-02`, your `cmdline.txt` should include:
     ```
     root=PARTUUID=e72d462f-02 rootfstype=ext4 rootwait
     ```
   - Save and exit the file.

#### 2. Ensure Proper Mounting of the SSD

1. **Edit the `fstab` on the SSD**:
   - Ensure that the `/boot` partition on the SD card is still mounted correctly by adding or updating the `/boot` entry in the SSD’s `fstab` file:
     ```bash
     sudo nano /mnt/ssd_root/etc/fstab
     ```
   - Add the following line to mount the SD card's boot partition:
     ```
     PARTUUID=<Your-SD-Card-Boot-PARTUUID> /boot vfat defaults 0 2
     ```
   - Replace `<Your-SD-Card-Boot-PARTUUID>` with the actual `PARTUUID` of the SD card's boot partition. You can find this by running:
     ```bash
     sudo blkid /dev/mmcblk0p1
     ```
   - Ensure the root partition on the SSD is correctly listed as `/` in the `fstab` file.

2. **Unmount and Sync Changes**:
   - After editing, ensure all filesystems are properly unmounted and synced:
     ```bash
     sudo umount /mnt/ssd_root
     sudo sync
     ```

#### 3. Finalize the Setup

1. **Reboot the Raspberry Pi**:
   - With the updated `cmdline.txt` and `fstab`, reboot the Raspberry Pi:
     ```bash
     sudo reboot
     ```

2. **Verify the Boot Process**:
   - After rebooting, verify that the system has successfully booted using the SD card's boot partition but is running the root filesystem from the SSD:
     ```bash
     lsblk
     ```
   - Ensure that `/boot` is mounted from the SD card and `/` is mounted from the SSD.

---

list directorie sizes

du -ah / | sort -rh | head -n 20


sudo sed -i 's/^rootdev=.*/rootdev=UUID=5175c507-d1d7-4190-b0dc-84ea2e68ae3f/' /mnt/ssd_root/boot/armbianEnv.txt
---