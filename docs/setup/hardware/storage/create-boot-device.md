# Create Boot Device

This guide will walk you through the process of flashing an Storage Device with a linux image using a Linux operating system. It includes steps to clean the Storage Device, remove any existing partitions, prepare it as a single block, extract the `.xz` file, and flash the image.

## Step 1: Download the Image
1. **Find an image supported by your board, my personal favorites**:
   - [DietPi](https://dietpi.com).
   - [ARMBian](https://fi.mirror.armbian.de/dl/).
   - Download the appropriate DietPi image file for your device, usually provided as a compressed `.xz` file.

## Auto Creation

There are many tools available for this I will list a few links to commonly used ones

1. **Cross-Platform**:
   - [RPI Imager (Preferred)](https://www.raspberrypi.com/software/)
   - [Etcher](https://etcher.balena.io/)
   - [UNetbootin](https://unetbootin.github.io/)
1. **Linux**:
   - [Popsicle](https://github.com/pop-os/popsicle)
1. **Windows**:
   - [Rufus](https://rufus.ie/en/)


## Manual Creation

### Step 1: Extract the Image from the .xz File
1. **Extract the Image**:
   - Most images are provided as compressed `.xz` files. You need to extract the `.img` file before flashing it.
   - Use the `unxz` command to extract the image:
     ```bash
     unxz Linux*.xz
     ```
   - Alternatively, you can use the `xz` command:
     ```bash
     xz -d Linux*.xz
     ```
   - This will extract the `.img` file from the `.xz` archive, ready for flashing.

### Step 2: Prepare the Storage Device
1. **Insert the Storage Device into Your Computer**:
   - Insert the Storage Device into your computer using a card reader if necessary.
   - Determine the device path for the Storage Device by running:
     ```bash
     lsblk
     ```
   - Look for the device corresponding to your Storage Device (e.g., `/dev/sdX` or `/dev/mmcblkX`).

   **Important**: Make sure to correctly identify your Storage Device’s device path to avoid data loss.

2. **Remove Existing Partitions**:
   - If your Storage Device has been used previously, it might have multiple partitions. These need to be removed before flashing the image.
   - Use the `fdisk` utility to clean the Storage Device:
     ```bash
     sudo fdisk /dev/sdX
     ```
     Replace `/dev/sdX` with your Storage Device’s device path.
   - Within `fdisk`, follow these steps:
     - Press `p` to list the current partitions.
     - Press `d` to delete a partition. If there are multiple partitions, repeat this step until all are deleted.
     - Press `w` to write the changes and exit `fdisk`.

   This process will remove all existing partitions, leaving the Storage Device as one unallocated block of space.

3. **Create a New Partition Table (Optional)**:
   - If you want to create a new partition table to ensure the Storage Device is clean, you can do so:
     ```bash
     sudo fdisk /dev/sdX
     ```
   - Press `o` to create a new DOS partition table.
   - Press `w` to write the changes and exit.



### Step 3: Flash the Image to any storage Device

1. **Flash the Image**:
   - Use the `dd` command to write the DietPi image to the Storage Device:
     ```bash
     sudo dd if=/path/to/linux.img of=/dev/sdX bs=4M status=progress conv=fsync
     ```
   - **Explanation of Options**:
     - `if=/path/to/linux.img`: This specifies the input file (`if`) that you want to write to the Storage Device. Replace `/path/to/linux.img` with the path to your extracted DietPi image file.
     - `of=/dev/sdX`: This specifies the output file (`of`), which is the device path of your Storage Device. Replace `/dev/sdX` with the correct device path for your Storage Device.
     - `bs=4M`: The `bs` option sets the block size to 4 megabytes, which determines the amount of data written in each block. Using a larger block size can speed up the writing process.
     - `status=progress`: This option provides real-time progress updates, showing the amount of data written and the speed of the operation.
     - `conv=fsync`: This option ensures that all data is physically written to the Storage Device before the process completes. It forces `dd` to synchronize the data, reducing the risk of corruption if the Storage Device is removed too quickly after the command finishes.

2. **Wait for the Process to Complete**:
   - The `dd` command may take some time to complete, depending on the size of the image and the speed of your Storage Device.
   - Once finished, ensure the process is complete without errors.

3. **Sync the Data**:
   - Run the `sync` command to ensure all data has been written to the Storage Device:
     ```bash
     sudo sync
     ```
   - The `sync` command ensures that any remaining data in the buffer is fully written to the Storage Device, providing an additional layer of safety.


### Step 4: Safely Eject the Storage
1. **Eject the Storage Device**:
   - Safely eject the Storage Device from your computer:
     ```bash
     sudo eject /dev/sdX
     ```

### Step 5: Boot your image
1. **Insert the Storage Device into Your Device**:
   - Insert the Storage Device into your device, such as a Raspberry Pi.

2. **Power On the Device**:
   - Power on your device. It should automatically boot from the Storage Device.

3. **Initial Setup**:
   - Follow the on-screen instructions to complete the initial setup.

### Troubleshooting Tips
- **Permission Denied Error**: Ensure you are using `sudo` with the `dd` command.
- **Incomplete Flash**: If the flashing process was interrupted, repeat the `dd` process after ensuring the Storage Device is unmounted.
- **Wrong Device Path**: Double-check the device path using `lsblk` before proceeding with the `dd` command.

### Additional Resources
- **DietPi Documentation**: For more detailed setup and configuration options, refer to the [DietPi documentation](https://dietpi.com/docs/).
- **ARMbian Documentation**: For more detailed setup and configuration options, refer to the [ARMbian documentation](https://docs.armbian.com/).

---