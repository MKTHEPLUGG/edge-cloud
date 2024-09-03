# Configure SSD as bootable device

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
