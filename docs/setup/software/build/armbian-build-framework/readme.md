# Use Armbian Build framework for custom image

[//]: # (seems to me like the best way is not to try boot it via qemu and use packer but just use the build framework for everything, you can use the userpatches/customize-image.sh https://docs.armbian.com/Developer-Guide_User-Configurations/)

we need to figure out how armbian is handling the boot process from start to finish, I'm getting conflicting info

https://forum.armbian.com/topic/38258-running-self-build-image-on-qemu-arm64/ => docs to build on qemu and how to boot with u boot new method

Armbian doesn't support cloud-init by default like the cloud images of ubuntu do, we'll have to use the build framework to create our custom image. first figure out how it works then automate it via pipelines.

[//]: # (https://forum.armbian.com/topic/14616-cloud-init/ => **DEPRECATED** cloud init seems to have been added in.)

To rebuild the Ubuntu-based Armbian image specifically for the Rock5A and include Cloud-Init, you can use the **Armbian Build Framework**. This will allow you to start with the same base image but customize it to include Cloud-Init and any other packages or configurations you want. Here’s a step-by-step guide to achieve that.

### Steps to Rebuild Armbian Image for Rock5A with Cloud-Init:

#### 1. **Set Up Armbian Build Environment**

> [!IMPORTANT]
> This is fully automated using the Deploy script in ``build/armbian-build-framework``.

You’ll need a Linux machine (or VM) with the necessary build dependencies to compile the Armbian image.

- First clone our edge-cloud repo

  ```bash
  # if git is not installed: apt install git
  git clone https://github.com/MKTHEPLUGG/edge-cloud
  cd edge-cloud
  ```

- Navigate to the folder ``build/armbian-build-framework``

  ```bash
  cd build/armbian-build-framework
  ```

- First, clone the official [Armbian build repository]https://github.com/armbian/build:
  
  ```bash
  git clone https://github.com/armbian/build
  cd build
  ```

- Install the necessary dependencies. The build framework will guide you through the installation, or you can run:

  ```bash
  sudo apt-get install git curl zip unzip rsync bc
  ```

#### 2. **Add Cloud-Init to the Build**


https://github.com/armbian/build/issues/6197
https://github.com/armbian/build/pull/6205/files
https://github.com/rpardini/armbian-build/tree/extensions/userpatches/extensions

#### Reference
[Armbian Docs - User Provided Patches/Config/Customization script](https://docs.armbian.com/Developer-Guide_User-Configurations/#user-provided-patches)

To include `cloud-init` in the image, you’ll modify the Armbian build configuration files and enable the extension.

1. **Edit the Build Configuration**:
   
   - Navigate to the `userpatches` directory and create a new `lib.config` file if it doesn’t already exist:
     ```bash
     mkdir -p userpatches
     nano userpatches/lib.config
     ```

   - Add the following line to ensure the `cloud-init` extension is enabled during the build process.
     Alternatively you can set it as an env var when calling compile.sh
     ```bash
     echo "ENABLE_EXTENSIONS=\"cloud-init\"" > userpatches/lib.config"
     ```
     
   
   - Use the [native](https://github.com/armbian/build/pull/6205/files) way that has been added recently. Create a Directory for this with the defaults and pack it into the image.
     ```bash
     mkdir -p userpatches/extensions
     cp -r extensions/cloud-init userpatches/extensions/cloud-init
     ```
     

#### 3. **Set Overlay to enable SPI support**

Figure out how to do this with the build framework we need to enable to overlay

When you install the base image of armbian the SPI controller is not configured as SPI NOR FLASH, which is what we want if we want to upload the bootloader there. To enable this functionallity you need to add an overlay to the boot env file.

````shell
ls /boot/dtb/rockchip/overlay/rock-5a-spi-nor-flash.dtbo
echo "overlays=rock-5a-spi-nor-flash" >> /boot/armbianEnv.txt
reboot
lsblk   # or ls /dev/mtd*
````

#### 4. **Build the Image**

Once the configuration is ready, proceed with building the image.

- The `./compile.sh` command will download the necessary files, compile the kernel, and assemble the final image, including the `cloud-init` package and your custom Cloud-Init configuration.
- This process can take some time, depending on the machine you're using.

2. Use environment variables to configure the compile script
   ````shell
    ./compile.sh \
    BOARD=rock-5a \
    BRANCH=vendor \
    RELEASE=noble \
    BUILD_MINIMAL=yes \
    BUILD_DESKTOP=no \
    KERNEL_CONFIGURE=no
    ````


---


### Troubleshooting: Mounting Root Partition from Armbian Image

When working with Armbian images, you may want to check the image before trying to boot from it. Here are some troubleshooting steps to help you do that.

1. **Check the Loop Device**: Check which loop devices are currently in use
   ```bash
   sudo losetup -a
   ```

   This should show the loop device `/dev/loop0` with the associated partitions like `/dev/loop0p1` and `/dev/loop0p2`.

2. **Create the Loop Device with Partition Mapping with Kpartx**:

   Run this command to create partition mappings:
   ```bash
   sudo kpartx -av Armbian_24.8.1_Rock-5a_noble_vendor_6.1.75_minimal.img.xz
   sudo kpartx -av Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75-ci.img
   sudo kpartx -av Armbian-unofficial_24.11.0-trunk_Rock-5a_noble_vendor_6.1.75-ci_minimal.img
   ```

   This should create devices like `/dev/mapper/loop0p1` and `/dev/mapper/loop0p2`.

   After running this, try mounting the root partition again with:
   ```bash
   sudo mkdir -p /mnt/os
   sudo mkdir -p /mnt/boot
   sudo mount /dev/mapper/loop0p1 /mnt/boot
   sudo mount /dev/mapper/loop0p2 /mnt/os
   ```

3. **Check Kernel Messages**:
   ```bash
   dmesg | tail -n 20
   ```

   This can help identify if there are any specific errors related to the loop device or partitions.

4. **Unmount and Detach the Loop Device**: Once you're done troubleshooting, remember to clean up by unmounting and detaching the loop device:
   ```bash
   sudo umount /mnt/os
   sudo losetup -d /dev/loop0
   ```

### Summary
- First, use `losetup -a` to confirm that the loop device and its partitions are set up correctly.
- If needed, use `kpartx` to create partition mappings and then mount the partition.
- Use `dmesg` to check for any kernel-level issues related to the loop device.

---

In Armbian version 24.11.0, the SPI flash NOR overlay for the Rock5A was removed because the board's hardware design requires separate configurations for eMMC and SPI flash due to shared pins. To address this, Armbian now builds U-Boot twice for the Rock5A: once with SPI flash support and once with eMMC support. This approach eliminates the need for a separate overlay, as the necessary configurations are integrated directly into the respective U-Boot builds. 

When building your image using the Armbian Build Framework, you can select the appropriate U-Boot configuration to match your intended boot device. During the build process, the framework should prompt you to choose between SPI flash and eMMC support for U-Boot. Ensure you select the option that corresponds to your target boot medium.

If the build framework does not provide a clear option for selecting the U-Boot configuration, you may need to manually specify the desired configuration. This can involve editing specific configuration files or applying patches that enable the appropriate support. For detailed guidance on customizing U-Boot configurations within the Armbian Build Framework, refer to the Armbian documentation or community forums.

By selecting the correct U-Boot configuration during the build process, you ensure that your Rock5A board boots correctly from your chosen storage medium, whether it's SPI flash or eMMC. 