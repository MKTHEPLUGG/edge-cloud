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

### TLDR - Quick Fix

When you install the base image of armbian the SPI controller is not configured as SPI NOR FLASH, which is what we want if we want to upload the bootloader there. To enable this functionallity you need to add an overlay to the boot env file.

````shell
ls /boot/dtb/rockchip/overlay/rock-5a-spi-nor-flash.dtbo
echo "overlays=rock-5a-spi-nor-flash" >> /boot/armbianEnv.txt
reboot
lsblk   # or ls /dev/mtd*
````



### Steps to Enable the `rock-5a-spi-nor-flash.dtbo` Overlay:

#### 1. **Verify the Overlay Exists**
First, confirm that the overlay file `rock-5a-spi-nor-flash.dtbo` is available in your system:

```bash
ls /boot/dtb/rockchip/overlay/rock-5a-spi-nor-flash.dtbo
```

If the file exists, proceed with enabling it.

#### 2. **Edit the `armbianEnv.txt` File**
To enable the overlay, you need to modify the **Armbian environment file** (`/boot/armbianEnv.txt`). This file controls the configuration of the system at boot, including the device tree overlays.

Open the file with a text editor:

```bash
sudo nano /boot/armbianEnv.txt
```

#### 3. **Enable the Overlay**
Find the line that starts with `overlays=` (or add it if it doesn’t exist), and append the `rock-5a-spi-nor-flash` overlay. It should look like this:

```bash
overlays=rock-5a-spi-nor-flash
```

If there are already overlays listed, separate them with a space or comma, like so:

```bash
overlays=other-overlay rock-5a-spi-nor-flash
```

#### 4. **Save and Reboot**
After making the change, save the file and reboot the system to apply the overlay:

```bash
sudo reboot
```

#### 5. **Verify the SPI NOR Flash is Enabled**
After the reboot, check if the SPI NOR flash device is recognized as an MTD device:

```bash
ls /dev/mtd*
```

You should see something like `/dev/mtd0` and `/dev/mtdblock0`.

Also, check `/proc/mtd` for more details:

```bash
cat /proc/mtd
```

You should see entries for the MTD partitions, like:

```
dev:    size   erasesize  name
mtd0: 00080000 00010000 "spi-nor"
```

#### 6. **Flash the Bootloader to SPI NOR**

Once the SPI NOR is properly configured and detected as an MTD device, you can proceed with flashing a bootloader. The process typically involves erasing the flash and writing the bootloader image.

The Official Documentation for this can be found [here](https://wiki.radxa.com/Rock5/install/spi#3.29_Flash_the_SPI_flash)


1. **Easy Way**:
   use armbian install docs [here](https://fieldday.io/armbian-rock5b/)

2. **Manual Way**
   outlined in this [doc](https://wiki.radxa.com/Rock5/install/spi#3.29_Flash_the_SPI_flash)




**BELOW NOT NEEDED, KEEP INTERESTING STUFF**

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
        # in this file you can see which dtb is being used
        cat /boot/armbianEnv.txt
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


### Device not by default configured as SPI ROM


[//]: # (#### 3.2 **SPI Communication Test**)

[//]: # (Since your SPI device &#40;`spi2.0`&#41; is visible in `/sys/bus/spi/devices/`, you should test communication over the SPI bus to verify if data is being transmitted correctly.)

[//]: # ()
[//]: # (Here's a comprehensive guide on how to enable the `spidev` module, install `spi-tools`, test the SPI interface, and ensure that the `spidev` module persists across reboots.)

[//]: # ()
[//]: # (### Step 1: **Enable `spidev` Kernel Module**)

[//]: # ()
[//]: # (The `spidev` module is essential for exposing SPI devices as character devices in `/dev`. Follow these steps to enable it:)

[//]: # ()
[//]: # (1. **Check if `spidev` is loaded:**)

[//]: # (   Open a terminal and run:)

[//]: # (   ```bash)

[//]: # (   lsmod | grep spidev)

[//]: # (   ```)

[//]: # (   If no output is returned, the `spidev` module isn't loaded.)

[//]: # ()
[//]: # (2. **Load the `spidev` module:**)

[//]: # (   To load the `spidev` module manually:)

[//]: # (   ```bash)

[//]: # (   sudo modprobe spidev)

[//]: # (   ```)

[//]: # ()
[//]: # (3. **Verify the Module:**)

[//]: # (   After loading the module, confirm that `spidev` is now active:)

[//]: # (   ```bash)

[//]: # (   lsmod | grep spidev)

[//]: # (   ```)

[//]: # ()
[//]: # (4. **Check for SPI Devices:**)

[//]: # (   Once the module is loaded, check `/dev/` for `spidevX.Y` entries:)

[//]: # (   ```bash)

[//]: # (   ls /dev/spidev*)

[//]: # (   ```)

[//]: # (### Step 2: **Install SPI-Tools**)

[//]: # ()
[//]: # (`spi-tools` is a package containing tools that help in interacting with SPI devices. Here’s how to download, build, and install it.)

[//]: # ()
[//]: # (1. **Install via package manager:**)

[//]: # (   ```bash)

[//]: # (   apt install spi-tools)

[//]: # (   ```)

[//]: # ()
[//]: # (2. **Confirm Installation:**)

[//]: # (   After installation, you should be able to use the `spi-config` and `spi-pipe` tools:)

[//]: # (   ```bash)

[//]: # (   spi-config -h)

[//]: # (   spi-pipe -h)

[//]: # (   ```)

[//]: # ()
[//]: # (### Step 3: **Test the SPI Device**)

[//]: # ()
[//]: # (You can now use `spi-tools` to test your SPI device.)

[//]: # ()
[//]: # (#### 1. **Check the current configuration of an SPI device:**)

[//]: # ()
[//]: # (   You can use the `spi-config` command to check the SPI device's current configuration. Replace `X.Y` with the actual SPI bus and chip select number &#40;for example, `spidev2.0`&#41;:)

[//]: # (   ```bash)

[//]: # (   spi-config -d /dev/spidevX.Y -q)

[//]: # (   ```)

[//]: # ()
[//]: # (   This command will output the mode, speed, bits per word, etc.)

[//]: # ()
[//]: # (#### 2. **Change the SPI device’s configuration &#40;optional&#41;:**)

[//]: # ()
[//]: # (   To change the SPI device’s clock speed or mode, you can use the `spi-config` tool as follows:)

[//]: # (   ```bash)

[//]: # (   spi-config -d /dev/spidevX.Y -s 1000000 -m 0)

[//]: # (   ```)

[//]: # ()
[//]: # (   This sets the speed to 1 MHz and mode to 0.)

[//]: # ()
[//]: # (#### 3. **Send and receive data using `spi-pipe`:**)

[//]: # ()
[//]: # (   You can use `spi-pipe` to send and receive data. Here's how you can send data from one process and receive it in another:)

[//]: # ()
[//]: # (   ```bash)

[//]: # (   echo "test data" | spi-pipe -d /dev/spidevX.Y)

[//]: # (   ```)

[//]: # ()
[//]: # (   To receive data from the SPI device, use:)

[//]: # (   ```bash)

[//]: # (   spi-pipe -d /dev/spidevX.Y < /dev/zero)

[//]: # (   ```)

[//]: # ()
[//]: # (### Step 4: **Make the `spidev` Module Persistent Across Reboots**)

[//]: # ()
[//]: # (By default, the `spidev` module will not be loaded automatically upon reboot. To make sure it loads at boot time, follow these steps:)

[//]: # ()
[//]: # (1. **Edit the `modules` file:**)

[//]: # ()
[//]: # (   Add `spidev` to the list of modules to be loaded at boot. Open the `/etc/modules` file in a text editor:)

[//]: # (   ```bash)

[//]: # (   sudo nano /etc/modules)

[//]: # (   ```)

[//]: # ()
[//]: # (   Add the following line:)

[//]: # (   ```bash)

[//]: # (   spidev)

[//]: # (   ```)

[//]: # ()
[//]: # (2. **Update the `initramfs`:**)

[//]: # ()
[//]: # (   After editing the `modules` file, regenerate the `initramfs` to ensure the module is loaded during boot:)

[//]: # (   ```bash)

[//]: # (   sudo update-initramfs -u)

[//]: # (   ```)

[//]: # ()
[//]: # (3. **Reboot and Verify:**)

[//]: # ()
[//]: # (   Reboot your system:)

[//]: # (   ```bash)

[//]: # (   sudo reboot)

[//]: # (   ```)

[//]: # ()
[//]: # (   After rebooting, verify that the `spidev` module is loaded and the SPI device is present in `/dev/`:)

[//]: # (   ```bash)

[//]: # (   lsmod | grep spidev)

[//]: # (   ls /dev/spidev*)

[//]: # (   ```)


### Verify Kernal Configuration

````shell
zcat /proc/config.gz | grep MTD
````

