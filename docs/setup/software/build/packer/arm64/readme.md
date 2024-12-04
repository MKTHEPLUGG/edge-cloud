## automate image creation with packer for ARM64 Images

### How Packer Works for ARM64
Packer uses **builders** to create images, **provisioners** to configure the system (install software, set up users, etc.), and **post-processors** to handle the output (convert the image, compress, etc.). You can define the process in a single JSON or HCL configuration file.

Since we'll be building an arm based image we'll need a compatible host to be able to build it. Anything with an ARM arch will work.

### Images

You can find the armbian (ubuntu based) images at this [location](https://fi.mirror.armbian.de/)


### Steps to Automate Image Creation with Packer

1. **Install Packer**

   First, you’ll need to install Packer on your system:

   ```bash
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt install software-properties-common
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt update -y && sudo apt install packer qemu-system-arm qemu-system-aarch64 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager genisoimage guestfs-tools
   packer plugins install github.com/hashicorp/qemu
   ```
   

2. find out proper arguments for qemu and if you want to use kvm make sure it's enabled

    ```bash
    qemu-system-aarch64 -cpu help
    qemu-system-aarch64 -machine help
    lsmod | grep kvm
    # if nothing is found use
    sudo modprobe kvm
    ```

3. Verify the Image Format
   ````bash
   qemu-img info path/to/your/image
   ````

3. Use QEMU to Boot and Access the Shell [DOCS](https://gist.github.com/wuhanstudio/e9b37b07312a52ceb5973aacf580c453)

   Alternatively, if you prefer to boot the image directly and access the shell from a running system, you can use QEMU:

   ```bash
   sudo qemu-system-aarch64 -m 2048 -cpu cortex-a72 \
     -M virt \
     -drive file=~/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img,format=raw \
     -serial mon:stdio \
     -netdev user,id=user.0 \
     -device virtio-net,netdev=user.0,romfile=

   sudo qemu-system-aarch64 -m 2048 -cpu cortex-a72 \
     -M virt \
     -drive file=./output-noble/ubuntu-noble.qcow2,format=qcow2 \
     -nographic -serial mon:stdio

   ```

4. **Create a Packer Template**

   You’ll create a Packer template that defines how to build your image. Here’s an example template in the hcl format for building an Armbian image:

   ````hcl
        **TO BE REFINED GET FROM ARMBIAN IMAGE**

   ````



   In this example:
   - The **builder** uses QEMU to create the image, starting from the `Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img`.
   - The **provisioners** run shell commands and copy the Cloud-init `user-data` file into the appropriate directory.
   - The **post-processor** converts the final image to `raw` format.





3. **Create the `user-data` File** (Cloud-init Configuration)

   Make sure you have a `user-data` (config) file ready. in the template above this is handled by copying cloud config to the standard dir `/etc/cloud/cloud.cfg.d/99_custom.cfg`


4. **Run Packer**

   Once the Packer template is ready, you can run it:

   ```bash
   packer build .
   ```

   This will automatically:
   - Download the image.
   - Customize it with your Cloud-init configuration and other provisions.
   - Convert the final output to `raw` format.

5. **Result: The Final Image**

   After running the Packer build, you’ll find the final raw image in the `output-ubuntu-image` directory. You can directly copy this image to a USB drive or deploy it on any other system.

6. **Flash the Image**

   Once the build is complete, the image will be saved in the `output/images/` directory. You can flash it to your Rock5A’s storage medium (e.g., microSD card or eMMC module) using `dd` or another flashing tool like Balena Etcher.
   
   Example `dd` command to flash the image:
   
   ```bash
   sudo dd if=output/images/Armbian_*.img of=/dev/sdX bs=1M status=progress
   ```
   
   Make sure to replace `/dev/sdX` with the actual device identifier for your storage medium.

7. **Automating Future Builds**

   Once you have the Packer template, you can automate your builds. You can integrate it with CI/CD pipelines (e.g., GitHub Actions, Jenkins) to rebuild the image whenever changes are made to the configuration.


### Troubleshooting

If you run into issues:
- **Logs**: Check the build logs in the `output/debug` directory to identify any build issues.
- **Cloud-Init Issues**: Ensure the `cloud-init` package is properly installed by booting into the image and verifying with:
  ```bash
  sudo cloud-init status
  ```
---

### Example Workflow

- **Builders**: Define the base image (e.g., Ubuntu Cloud Image) and settings (memory, disk size, etc.).
- **Provisioners**: Run shell scripts to install packages, copy files, and configure the image.
- **Post-processors**: Convert the final image to a desired format (like raw for USB deployment).

---

# everything below is related to taking the image and trying to pack it with packer & qemu, this might just be stupid, above we should explore to just use the framework for everything. There was a recent patch to armbian to be able to boot now in qemu so this option might become available again.

### Alternatives (Using Packer):
If you want to avoid manually modifying the build framework, you could also use a tool like **Packer** to customize the existing prebuilt image by adding `cloud-init` and other modifications. However, using the Armbian Build Framework ensures better compatibility with the Rock5A board.

Let me know if you need more detailed help with any of these steps!

[//]: # (    sudo qemu-system-aarch64 -m 2048 -cpu cortex-a72 \)

[//]: # (      -M virt \)

[//]: # (      -drive file=~/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img,format=raw \)

[//]: # (      -serial mon:stdio \)

[//]: # (      -netdev user,id=user.0 \)

[//]: # (      -device virtio-net,netdev=user.0,romfile=)

[//]: # ()
[//]: # ()
[//]: # (   sudo qemu-system-aarch64 -m 2048 -cpu cortex-a72 \)

[//]: # (     -drive file=~/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img,format=raw \)

[//]: # (     -netdev user,id=user.0 \)

[//]: # (     -smp 2 \)

[//]: # (     -device virtio-net,netdev=user.0,romfile=)


---

https://forum.armbian.com/topic/38258-running-self-build-image-on-qemu-arm64/ => docs to build on qemu and how to boot with u boot new method


# boot armbian with new method

To extract the U-Boot binary (`u-boot.bin`) from your Armbian image and set up QEMU to boot it with U-Boot, here's a full guide to walk you through the process:

### Full Guide: Extracting U-Boot and Running Armbian in QEMU for Rock5A

#### Step 1: **Mount the Image and Extract U-Boot**


2. **Mount the Image**:
   Now, mount the image using the calculated offset:

   ```bash
   sudo mount /path/to/your/armbian-image.img /mnt
   mkdir -p /mnt/armbian
   sudo mount -o loop,offset=16777216 /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img /mnt/armbian
    # you have to set offset or it won't work find out how to below, rework docs don't forget
   ```

3. **Copy U-Boot Binary**:
   Once mounted, navigate to the `/boot` or `/` directory in `/mnt` and locate the U-Boot binary, which may be named something like `u-boot.bin` or similar, and copy it to your current working directory.

   ```bash
   sudo cp /mnt/boot/u-boot.bin ./
   ```

   If you don’t see a file named `u-boot.bin`, check in the `/boot` or root directory for anything that looks like a U-Boot binary (e.g., `u-boot-rock5a.bin`).

4. **Unmount the Image**:
   After copying the necessary files, unmount the image:

   ```bash
   sudo umount /mnt
   ```

#### Step 2: **Set Up the Armbian Image for QEMU**

If your image format is `qcow2` or raw, you can directly use it in QEMU. If it's in another format, you may want to convert it to `qcow2` for better performance and flexibility.

1. **Convert to QCOW2 (Optional)**:
   If you want to convert your raw image to `qcow2`, use the following command:

   ```bash
   qemu-img convert -O qcow2 /path/to/your/armbian-image.img /path/to/your/armbian-image.qcow2
   ```

#### Step 3: **Run the Image with QEMU**

Now that you have the `u-boot.bin` and the image file, you can boot the system using QEMU with the following command:

```bash
qemu-system-aarch64 \
    -machine virt -cpu cortex-a72 -m 2048 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -serial stdio \
    -bios ./u-boot.bin \
    -drive if=none,file=/path/to/your/armbian-image.qcow2,id=mydisk \
    -device ich9-ahci,id=ahci \
    -device ide-hd,drive=mydisk,bus=ahci.0
```

### Explanation of the Command:

- **`-bios ./u-boot.bin`**: This points to the extracted U-Boot binary that QEMU will use to boot the system.
- **`-drive if=none,file=/path/to/your/armbian-image.qcow2,id=mydisk`**: Specifies the Armbian image file. You can use either raw or `qcow2`.
- **`-device ich9-ahci,id=ahci` and `-device ide-hd`**: Emulates a SATA/IDE interface for the disk.

### Step 4: **Debugging U-Boot and Boot Process**

1. **Interact with U-Boot**:
   Once you start QEMU, you should see U-Boot starting in the terminal. If U-Boot successfully loads, it will try to boot the kernel from the Armbian image.

2. **Check U-Boot Environment**:
   If U-Boot starts but doesn’t automatically boot the kernel, you can interrupt the boot process by pressing a key during the U-Boot countdown.

   From the U-Boot prompt, you can run the following commands to check its environment and ensure it’s correctly set up to boot from the disk:

   ```bash
   printenv
   ```

   Look for `bootcmd` or any variables related to the boot process. Make sure it’s pointing to the correct disk and partition.

3. **Manual Boot (if needed)**:
   If U-Boot doesn't automatically boot the system, you can manually boot from the disk:

   ```bash
   boot
   ```

### Step 5: **Connect to the System via SSH (Optional)**

If the system boots successfully and you’ve set up networking, you can use SSH to connect to the virtual machine.

If you used the `-nic user,hostfwd=tcp::2022-:22` option for port forwarding, you can connect via SSH:

```bash
ssh -p 2022 user@localhost
```

Replace `user` with your username on the Armbian system.

### Summary:

1. **Extract U-Boot**: Mount the image, find the U-Boot binary, and copy it.
2. **Convert Image (Optional)**: Convert the image to `qcow2` for better flexibility.
3. **Run QEMU**: Use the appropriate QEMU command with `-bios` pointing to the U-Boot binary and boot the Armbian image.
4. **Debug with U-Boot**: Check U-Boot’s environment variables and ensure it’s set up to boot the kernel from the disk.
5. **SSH (Optional)**: Set up port forwarding and connect via SSH if necessary.

This guide should help you get the Armbian image booting on QEMU using U-Boot for the Rock5A. Let me know if you run into any issues or need further assistance!


The error you're encountering when trying to mount the image likely means that the filesystem type is not automatically recognized or there's an issue with the image structure. Here are some steps you can take to troubleshoot and resolve the issue:

### Step 1: **Check the Image Partition Table**

First, let's confirm the partition structure of the image using `fdisk` to check the partitions and their offsets.

```bash
fdisk -lu /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img
```

This will give you a list of partitions inside the image. You will see something like this:

```
Device         Boot Start      End  Sectors  Size Id Type
img1           *     8192  5324799  5316608  2.5G 83 Linux
img2                5324800 10485759 5160960  2.5G 83 Linux
```

Look for the **Start** sector of the partition you're trying to mount, then multiply it by 512 (the sector size) to get the correct offset.

### Step 2: **Mount the Partition with the Correct Offset**

Once you’ve identified the start sector, calculate the offset by multiplying it by 512.

For example, if the start sector is `8192`, the offset is:

```bash
8192 * 512 = 4194304
```

Then, mount the partition using the correct offset:

```bash
sudo mount -o loop,offset=4194304 /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img /mnt/armbian
```

### Step 3: **Check dmesg for More Information**

If the mount still fails, check `dmesg` for more detailed information:

```bash
dmesg | tail
```

This will show you the most recent system messages and may provide more specific details about what went wrong.

### Step 4: **Ensure the Correct Filesystem Type**

If the image uses a specific filesystem type (e.g., `ext4`, `btrfs`, etc.), you might need to specify it manually when mounting.

Try specifying the filesystem type explicitly (assuming `ext4`):

```bash
sudo mount -t ext4 -o loop,offset=4194304 /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img /mnt/armbian
```

### Step 5: **Check for Corrupted Image**

If the image is corrupted, it might be causing the mount issue. You can check the integrity of the image with `fsck`:

```bash
sudo fsck -f /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img
```

### Step 6: **Inspect Image with `losetup` (Loop Device)**

You can use `losetup` to create a loop device for the image and inspect it more thoroughly:

```bash
sudo losetup -fP /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img
```

This will create a loop device for each partition. You can then inspect these with:

```bash
sudo lsblk
```

Check if any of the loop devices (`/dev/loop0p1`, `/dev/loop0p2`, etc.) are detected as partitions, and mount the appropriate one:

```bash
sudo mount /dev/loop0p1 /mnt/armbian
```

### Summary

- Use `fdisk -lu` to identify the correct partition offset.
- Mount the image using the calculated offset.
- Specify the filesystem type if necessary (`ext4`, `btrfs`).
- Check `dmesg` for additional error information.
- If the image is corrupted, use `fsck` to repair it.
- Use `losetup` and `lsblk` to inspect and mount the loop device.

Let me know how it goes or if you need further help!

Based on the output from `fdisk`, it looks like there’s a single partition starting at sector `32768` and spanning 1.3GB. To mount this partition, you need to calculate the offset and use it with the `mount` command.

Here’s the step-by-step process:

### Step 1: **Calculate the Offset**

The partition starts at sector `32768`, and each sector is `512` bytes. To get the correct offset in bytes, multiply the sector number by `512`:

```
32768 * 512 = 16777216
```

So, the offset is `16777216` bytes.

### Step 2: **Mount the Image with the Correct Offset**

Now that you have the offset, you can mount the partition using the `-o loop,offset=` option:

```bash
sudo mount -o loop,offset=16777216 /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img /mnt/armbian
```

### Step 3: **Check Mounted Filesystem**

Once the partition is mounted, you can navigate to `/mnt/armbian` and check for the U-Boot binary (`u-boot.bin` or similar) and other boot-related files (kernel, `dtb`, `initrd`).

```bash
cd /mnt/armbian
ls
```

### Step 4: **Unmount the Partition**

After extracting the necessary files, unmount the partition:

```bash
sudo umount /mnt/armbian
```

### Summary

- The partition starts at sector `32768`, and the calculated offset is `16777216` bytes.
- Mount the partition using the correct offset and check for the required files (`u-boot.bin`, kernel, etc.).
- If everything mounts correctly, you should be able to extract the necessary boot components and proceed with the QEMU setup.

Let me know how it goes or if you encounter any issues!


# old way seems to be what we need ?

It looks like you have everything you need to boot the system using QEMU. Here’s how you can use these files to boot your Armbian image for the Rock5A board in QEMU.

### Files You Have in `/boot`:

- **`Image`**: This is the kernel image.
- **`dtb-6.1.75-vendor-rk35xx`**: This is the directory containing device tree blobs (DTBs), which describe the hardware.
- **`uInitrd` or `initrd.img-6.1.75-vendor-rk35xx`**: This is the initial RAM disk used during boot.

### Booting the Image in QEMU

Now, you need to set up the QEMU command to boot the image using the extracted kernel, DTB, and initrd.

#### Step 1: **Identify the Correct DTB**

You’ll need to identify the correct device tree file (`.dtb`) for your Rock5A board. Since you have a directory `dtb-6.1.75-vendor-rk35xx`, list the contents:

```bash
ls /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip
ls /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip | grep rock
cp /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb
```

Look for a `.dtb` file that corresponds to the Rock5A board (it might be named `rk3588-rock5a.dtb` or something similar).

#### Step 2: **Prepare the QEMU Command**

https://gist.github.com/wuhanstudio/e9b37b07312a52ceb5973aacf580c453
https://forum.armbian.com/topic/7547-run-armbian-into-qemu/

Here’s how you can construct the QEMU command to boot the Armbian image using the extracted files.

```bash
qemu-system-aarch64 \
    -machine virt -cpu cortex-a72 -m 2048 \
    -serial mon:stdio \
    -kernel /mnt/armbian/boot/Image \
    -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \
    -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx \
    -drive file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/vda1" \
    -netdev user,id=user.0 \
    -device virtio-net,netdev=user.0,romfile=
```

qemu-system-aarch64 -m 1G,slots=3,maxmem=4G \
                            -machine virt -cpu cortex-a72 -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \
                            -smp 4 \
                            -kernel /mnt/armbian/boot/vmlinuz-6.1.75-vendor-rk35xx -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx -append "earlyprintk #loglevel=8 earlycon=uart8250,mmio32,0x1c28000,115200n8 console=ttyS0 root=/dev/mmcblk0p1" \
                            -no-reboot -nographic -serial stdio -monitor none \
                            -drive format=raw,file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img \
                            -netdev user,id=net0,hostfwd=tcp::50022-:22 \
                            -device virtio-net-pci,netdev=net0

qemu-system-aarch64 -m 1G,slots=3,maxmem=4G \
                            -machine virt -cpu cortex-a72 -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \
                            -smp 4 \
                            -kernel /mnt/armbian/boot/vmlinuz-6.1.75-vendor-rk35xx -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx -append "earlyprintk #loglevel=8 earlycon=uart8250,mmio32,0x1c28000,115200n8 console=ttyS0 root=/dev/mmcblk0p1" \
                            -no-reboot -nographic -serial stdio -monitor none \
                            -drive format=raw,file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img \
                            -netdev user,id=net0,hostfwd=tcp::50022-:22 \
                            -device virtio-net-pci,netdev=net0,romfile=""


qemu-system-aarch64 -m 1G,slots=3,maxmem=4G \
                            -machine virt -cpu cortex-a72 -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \
                            -smp 4 \
                            -kernel /mnt/armbian/boot/vmlinuz-6.1.75-vendor-rk35xx -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx -append "earlyprintk #loglevel=8 earlycon=uart8250,mmio32,0x1c28000,115200n8 console=ttyS0 root=/dev/mmcblk0p1" \
                            -no-reboot -nographic -serial stdio -monitor none \
                            -drive format=raw,file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img \
                            -netdev user,id=net0,hostfwd=tcp::50022-:22 \
                            -device e1000,netdev=net0

-hda Armbian_21.02.1_Nanopineo_buster_current_5.10.12.img \

**NEED TO FIGURE OUT HOW TO BOOT IT LOL**
https://www.google.com/search?client=firefox-b-d&q=boot+armbian+with+qemu
https://raspberrypi.stackexchange.com/questions/73699/run-armbian-in-qemu

hex dump of image to check if using EFI or U-Boot or whatever
dd if=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img bs=512 count=2048 | hexdump -C | less

---

## EFI setup => default when compiling our image with build framework and choosing minimal ubuntu, or maybe u boot is baked in, figure out how u boot is used in armbian

### Download the EFI Firmware and enlarge it to 64mb for qemu to work with itµ

1. Mount the created image with build framework
   sudo mount -o loop,offset=16777216 /home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img /mnt/armbian


apt install qemu-efi-aarch64
sudo chmod 777 /usr/share/qemu-efi-aarch64/QEMU_EFI.fd
dd if=/dev/zero bs=1M count=62 >> /usr/share/qemu-efi-aarch64/QEMU_EFI.fd

2. Create nvram iso for EFI to store it's data inside of, qemu needs this to emulate proper setup.

truncate -s 64M nvram.img


qemu-system-aarch64 -m 1G,slots=3,maxmem=4G \
    -machine virt -cpu cortex-a72 \
    -drive if=pflash,format=raw,file=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd,readonly=on \
    -drive if=pflash,format=raw,file=/home/sysadmin/build/output/images/nvram.img \
    -drive format=raw,file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img \
    -netdev user,id=net0,hostfwd=tcp::50022-:22 \
    -device virtio-net-pci,netdev=net0,romfile="" \
    -serial stdio -monitor none \
    -kernel /mnt/armbian/boot/vmlinuz-6.1.75-vendor-rk35xx -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx -append "earlyprintk #loglevel=8 earlycon=uart8250,mmio32,0x1c28000,115200n8 console=ttyS0 root=/dev/mmcblk0p1" \
    -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \

=> probably ditch qemu for packer and just build natively using build framework. Can't get this to work for some reason.
=> explore u-boot to be able to use QEMU

qemu-system-aarch64 -m 1G,slots=3,maxmem=4G \
    -machine virt -cpu cortex-a72 \
    -dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588s-rock-5a.dtb \
    -kernel /mnt/armbian/boot/vmlinuz-6.1.75-vendor-rk35xx \
    -initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx \
    -append "earlyprintk loglevel=8 earlycon=uart8250,mmio32,0x1c28000,115200n8 console=ttyS0 root=/dev/vda1" \
    -drive if=pflash,format=raw,file=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd,readonly=on \
    -drive if=pflash,format=raw,file=/home/sysadmin/build/output/images/nvram.img \
    -drive if=virtio,format=raw,file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img \
    -netdev user,id=net0,hostfwd=tcp::50022-:22 \
    -device virtio-net-pci,netdev=net0,romfile="" \
    -nographic -serial stdio -monitor none


---
## U-boot Setup

???


---
### Explanation:

- **`-kernel /mnt/armbian/boot/Image`**: This points to the kernel image (`Image`).
- **`-dtb /mnt/armbian/boot/dtb-6.1.75-vendor-rk35xx/rockchip/rk3588-rock5a.dtb`**: This points to the correct DTB file for the Rock5A board (replace this path with the correct DTB if needed).
- **`-initrd /mnt/armbian/boot/initrd.img-6.1.75-vendor-rk35xx`**: This points to the initial RAM disk.
- **`-drive file=/home/sysadmin/build/output/images/Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75_minimal.img,format=raw`**: This is the image file with the root filesystem.
- **`-append "console=ttyAMA0,115200 root=/dev/vda1"`**: This passes kernel parameters, including:
  - `console=ttyAMA0,115200`: Redirects the console to the serial interface.
  - `root=/dev/vda1`: Specifies the root filesystem on the first virtual disk (`/dev/vda1`).

- **`-nographic`**: Disables graphical output and routes everything to the terminal.




[//]: # (OLD WAY)
[//]: # (To include `cloud-init` in the image, you’ll modify the Armbian build configuration files.)

[//]: # ()
[//]: # (1. **Edit the Build Configuration**:)
   
[//]: # (   - Navigate to the `userpatches` directory and create a new `lib.config` file if it doesn’t already exist:)

[//]: # (     ```bash)

[//]: # (     mkdir -p userpatches)

[//]: # (     nano userpatches/lib.config)

[//]: # (     ```)

[//]: # ()
[//]: # (   - Add the following line to ensure the `cloud-init` package is installed during the build process:)

[//]: # (     ```bash)

[//]: # (     PACKAGE_LIST_ADDITIONAL="$PACKAGE_LIST_ADDITIONAL cloud-init")

[//]: # (     ```)


[//]: # (2. **Add Cloud-Init Configuration Files**:)

[//]: # ()
[//]: # (   - Create a directory for overlays:)

[//]: # (     ```bash)

[//]: # (     mkdir -p userpatches/overlay/cloud-init)

[//]: # (     ```)

[//]: # ()
[//]: # (   - Add your `user-data` and `meta-data` files in this folder.)

[//]: # (   )
[//]: # (   - Then, modify the `userpatches/customize-image.sh` script to copy these files into the image’s boot partition:)

[//]: # (     ```bash)

[//]: # (     nano userpatches/customize-image.sh)

[//]: # (     ```)

[//]: # ()
[//]: # (   - Add the following lines to the script:)

[//]: # (     ```bash)

[//]: # (     #!/bin/bash)

[//]: # (     cp -r /tmp/overlay/cloud-init /boot/cloud-init)

[//]: # (     echo "extraargs=ds=nocloud;s=/boot/cloud-init/" >> /boot/armbianEnv.txt)

[//]: # (     ```)

[//]: # ()
[//]: # (   This ensures that your Cloud-Init files will be placed in the boot partition and properly referenced.)
