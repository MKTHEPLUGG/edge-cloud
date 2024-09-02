# Migrate Bootable Device to new Storage Device

### Step 1: Prepare to Migrate your install to any Storage Device

1. **Connect the SSD to the Raspberry Pi**:
   - Ensure the SSD is connected to the system that's running the current OS.

2. **Check Disk Configuration**:
   - List all connected storage devices to identify the SSD and SD card:
     ```bash
     lsblk -f
     # or
     sudo fdisk -l
     ```
   - SD cards are typically `/dev/mmcblk0`, and usb devices might be `/dev/sda` or similar. Take note of these device names & fstypes as they will be needed for the next steps.

### Step 2 : Partition and Format your Storage Device

**Remark**: if your image doesn't use 2 partitions just create one.

1. **Partition the SSD**:
   - Open the `fdisk` tool to create two partitions on the SSD: one for `/boot` and one for `/`.
     ```bash
     sudo fdisk /dev/sda

     ```
     Replace `/dev/sda` with your Storage Device's device path.
   - In `fdisk`, perform the following:
     - Press `n` to create a new partition.
     - Choose `p` for a primary partition.
     - For the first partition (which will be `/boot`):
       - Choose the default partition number (1).
       - Set the first sector to the default.
       - For the last sector, specify `+200M` to create a 200MB partition for `/boot`.
     - Press `n` again to create the second partition (which will be `/`):
       - Choose the default partition number (2).
       - Set the first sector to the default (which follows immediately after the `/boot` partition).
       - Accept the default for the last sector to use the remaining space for the root filesystem.
     - Press `w` to write the changes and exit `fdisk`.

2. **Format the Partitions**:
   - **Remark**: When you have only one partition format it as ext4
   - Format the first partition (`/dev/sda1`) as FAT32 for the `/boot` partition:
     ```bash
     sudo mkfs.vfat /dev/sda1
     ```
   - Format the second partition (`/dev/sda2`) as ext4 for the root (`/`) partition:
     ```bash
     sudo mkfs.ext4 /dev/sda2
     ```

### Step 10: Copy the Operating System to the SSD

**Remark**: if your image doesn't use 2 partitions just mount 1.

1. **Mount the SSD Partitions**:
   - Create mount points for the SSD partitions and mount them:
     ```bash
     sudo mkdir /mnt/ssd_root
     sudo mkdir /mnt/ssd_boot
     sudo mount /dev/sda2 /mnt/ssd_root
     sudo mount /dev/sda1 /mnt/ssd_boot
     ```

2. **Copy the File System**:
   - Use the `rsync` command to copy the entire file system from the SD card to the SSD:
     ```bash
     sudo rsync -axv --progress / /mnt/ssd_root
     ```
   - Copy the contents of the `/boot` partition to the SSD’s `/boot` partition:
     ```bash
     sudo rsync -axv --progress /boot/ /mnt/ssd_boot
     ```

3. **Obtain the `PARTUUIDs` of the SSD Partitions**:
   - Run the following command to get the `PARTUUIDs` of the SSD partitions:
     ```bash
     sudo blkid /dev/sda1 /dev/sda2
     ```
   - The output will look something like this:
     ```
     /dev/sda1: UUID="ABCD-1234" TYPE="vfat" PARTUUID="12345678-01"
     /dev/sda2: UUID="abcd1234-5678-90ab-cdef-1234567890ab" TYPE="ext4" PARTUUID="12345678-02"
     ```

4. **Update the `fstab` on the SSD**:
   - Edit the `fstab` file on the SSD to use the correct `PARTUUIDs`:
     ```bash
     sudo nano /mnt/ssd_root/etc/fstab
     ```
   - Update the entries for the root (`/`) and boot (`/boot`) partitions:
     ```bash
     PARTUUID=12345678-02 / ext4 noatime,lazytime,rw 0 1
     PARTUUID=12345678-01 /boot vfat noatime,lazytime,rw 0 2
     ```
   - Replace `12345678-01` and `12345678-02` with the actual `PARTUUIDs` you obtained from the `blkid` command.

6. **Reload `systemd` Configuration**:
   - Before or after editing the `fstab` on the SSD (if it’s mounted), reload `systemd` to ensure it recognizes any new or changed mount configurations:
     ```bash
     sudo systemctl daemon-reload
     ```
    

### Step 11: Verify Boot from SSD

1. **Check the Boot Device**:
   - Once the Raspberry Pi has booted, log in and verify that the system is running from the SSD:
     ```bash
     lsblk
     ```
   - Ensure that the root filesystem (`/`) is mounted from the SSD (`/dev/sda2` or equivalent).

2. **Clean Up**:
   - If everything is working correctly, you can repurpose or securely erase the SD card.

---