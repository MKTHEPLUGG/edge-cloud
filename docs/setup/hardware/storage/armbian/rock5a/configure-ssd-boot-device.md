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

## Troubleshooting guide SPI module not recognized

### 1. **Kernel Modules**

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

### 2. **Check Boot Logs**

Analyze boot logs for more detailed information:

- **dmesg Output**:
  - Use `dmesg` to review boot logs and identify specific errors related to PCIe or SPI:
    ```bash
    dmesg | grep -i pcie
    dmesg | grep -i spi
    ```
  - Address any errors or warnings you find. These logs often provide hints about what might be misconfigured or failing to initialize.





### 3. **SPI Device Tree (DTB) Configuration**
You mentioned a large list of `.dtb` files, but it's unclear which one is actively in use. The SPI might not be properly configured or enabled in the active device tree.

- **Steps to Explore:**
   1. **Identify the Active Device Tree**:
      - You can check which `.dtb` is being loaded by inspecting the bootloader configuration or environment variables.
      - For example, check the `/boot/extlinux/extlinux.conf` or equivalent file to see which `.dtb` file is referenced.
      - You can also run:
        ```bash
        cat /proc/device-tree/model
        ```
        This will provide insight into which board model your system is configured for.

   2. **Inspect and Modify the Device Tree**:
      - Extract the current device tree as mentioned earlier:
        ```bash
        dtc -I dtb -O dts -o extracted.dts /boot/<active-dtb>.dtb
        ```
      - **Check the SPI Node**: Look for nodes related to the SPI controller, particularly for entries like `spi@feb20000` or any other relevant SPI bus for the Rockchip platform. Ensure the node is marked as `status = "okay"` and has the correct configuration for chip select lines, clocks, and pins.
      - If you find that the SPI node is not enabled or misconfigured, modify it, recompile it, and apply it as described previously.

### 3.1. **SPI Runtime PM Issue**
The output shows that the system has runtime power management enabled (`CONFIG_PM=y`), but no specific runtime power management options for SPI were mentioned in the config output, and no runtime errors were logged when you loaded the SPI module.

- **Steps to Explore**:
   1. **Manually Manage Power**: Since you didn't find much related to runtime in the kernel config, you can manually force the SPI device's power state:
      ```bash
      echo "on" > /sys/bus/spi/devices/spi2.0/power/control
      ```
      This disables runtime PM for this SPI device. Check `dmesg` or run the test again after performing this step to see if the SPI device comes up.

   2. **Check `/sys` for SPI devices**: Even if the device isn’t appearing in `blkid`, it should still show up under `/sys/bus/spi/devices/`:
      ```bash
      ls /sys/bus/spi/devices/
      ```
      If the SPI device shows up here, then you can further investigate why it's not detected as a block device.



#### 3.2 **SPI Communication Test**
Since your SPI device (`spi2.0`) is visible in `/sys/bus/spi/devices/`, you should test communication over the SPI bus to verify if data is being transmitted correctly.

- **Install spidev-tools** and run the following test:
  ```bash
  apt-get install spidev-tools
  spidev_test -D /dev/spidev2.0
  ```
  This test sends and receives data over the SPI bus, which can verify if the bus and connected device are working as expected.

#### 3.3 **Check Device-Specific Driver**
- If your SPI device is not a generic one, make sure the specific device driver is enabled in the kernel. You may need to check if a module specific to the SPI device (e.g., a sensor or display) is loaded or built into the kernel.
  
- For example, if you have an external device that communicates over SPI, check its compatible drivers in the kernel configuration or load the appropriate kernel module using `modprobe`.

