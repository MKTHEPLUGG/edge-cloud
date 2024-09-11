# Configure SSD as bootable device

## **Understanding Boot Partition Requirements**

### **Rock 5B Boot Process**

- **No FAT32 Partition Required**:
  - **Bootloader Flexibility**: The Rockchip RK3588 SoC used in the Rock 5B board has a more flexible bootloader that can read from various filesystem types, including ext4. This eliminates the strict requirement for a FAT32 partition.
  - **Unified Partition Scheme**: Armbian images for the Rock 5B typically use a single ext4 partition that contains both the boot files and the root filesystem. This simplifies the partitioning scheme and takes advantage of the SoC's capabilities.

- **Bootloader Location**:
  - **SPI Flash**: The bootloader can be installed on the board's SPI flash memory. Once installed, it knows how to locate and load the kernel and other necessary boot files from an ext4 partition on connected storage devices like NVMe SSDs.
  - **SD Card Booting**: If booting from an SD card, the bootloader is included within the image and properly configured to boot from the ext4 partition present on the card.

### Step 1: Initial Setup on Rock 5A

1. **Download and Write Armbian Image**:
   - Download the latest Armbian image for Rock 5A.
   - Write this image to an SD card using a tool like Balena Etcher.

2. **Boot the Board**:
   - Insert the SD card into the Rock 5A.
   - Connect the board to a network (with DHCP enabled) and power it on.
   - Ensure you use the correct power supply.

3. **Update and Verify Platform**:
   - Once booted, update the system:
     ```bash
     sudo apt-get update && sudo apt-get upgrade -y
     ```
   - Verify the installation and hardware with:
     ```bash
     uname -a
     lsblk
     ```

### Step 2: Configure Bootloader to Boot from NVMe SSD

1. **Run `armbian-install` Tool**:
   - Start the `armbian-install` tool:
     ```bash
     sudo armbian-install
     ```
   - During the process, you will be prompted to select:
     - The SPI flash as the boot device (where the bootloader will be installed).
     - The NVMe SSD as the root filesystem destination.

2. **Confirm Selections**:
   - Confirm the selections when prompted.
   - Wait for the installation to complete.

### Step 3 (optional): Prepare the NVMe SSD

**Remark**: this step is only needed if you don't prefer to just write a new image to the SSD via the imager tool.

1. **Connect the NVMe SSD**:
   - Connect an NVMe SSD to the Rock 5B.
   - Ensure it is formatted with an ext4 filesystem.

2. **Partition and Format the NVMe SSD**:
   - Use `fdisk` or `parted` to create a partition on the NVMe SSD if it is not already partitioned.
   - Format the partition with ext4:
     ```bash
     sudo mkfs.ext4 /dev/nvme0n1p1
     ```
   - Mount the NVMe SSD to a temporary directory:
     ```bash
     sudo mkdir /mnt/nvme
     sudo mount /dev/nvme0n1p1 /mnt/nvme
     ```

### Step 4 (optional): Copy the Root Filesystem to the NVMe SSD

**Remark**: this step is only needed if you don't prefer to just write a new image to the SSD via the imager tool.

1. **Copy Filesystem**:
   - Use `rsync` to copy the entire root filesystem from the SD card to the NVMe SSD:
     ```bash
     sudo rsync -axv --progress / /mnt/nvme
     ```

### Step 5: Finalize and Boot

1. **Remove SD Card**:
   - Once the installation is complete, power off the board.
   - Remove the SD card from the Rock 5A.

2. **Boot from NVMe SSD**:
   - Power on the Rock 5A again. The board should now boot directly from the NVMe SSD.

---

## **Conclusion**

The Rock 5B's boot process is inherently more flexible compared to the Raspberry Pi, allowing it to boot directly from ext4 partitions without the need for a separate FAT32 partition. This design simplifies the setup process and leverages the capabilities of the Rockchip RK3588 SoC effectively.

**Key Takeaways**:

- **Raspberry Pi**:
  - Requires a FAT32 partition for booting due to firmware constraints.
  - Bootloader expects to find boot files on a FAT32 filesystem.

- **Rock 5B**:
  - Can boot directly from ext4 partitions.
  - Bootloader, when installed on SPI flash, can load the system from various storage devices formatted with ext4.






--- 

Troubleshoot

### 5. **Kernel Modules**

Ensure that the necessary kernel modules for PCIe and SPI are loaded:

- **List Loaded Modules**:
  - Use the `lsmod` command to list currently loaded modules:
    ```bash
    lsmod
    ```
  - Look for modules related to PCIe (`pcie-rockchip-dwc` or similar) and SPI.

- **Load Missing Modules**:
  - If the relevant modules aren't loaded, manually load them:
    ```bash
    sudo modprobe pcie-rockchip-dwc
    sudo modprobe spi-rockchip
    ```

- **Add Modules to Load at Boot**:
  - To ensure the modules load automatically at boot, add them to `/etc/modules`:
    ```bash
    echo "pcie-rockchip-dwc" | sudo tee -a /etc/modules
    echo "spi-rockchip" | sudo tee -a /etc/modules
    ```

### 6. **Check Boot Logs**

Analyze boot logs for more detailed information:

- **dmesg Output**:
  - Use `dmesg` to review boot logs and identify specific errors related to PCIe or SPI:
    ```bash
    dmesg | grep -i pcie
    dmesg | grep -i spi
    ```
  - Address any errors or warnings you find. These logs often provide hints about what might be misconfigured or failing to initialize.

