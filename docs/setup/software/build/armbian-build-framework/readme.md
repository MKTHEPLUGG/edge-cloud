# Use Armbian Build framework for custom image

seems to me like the best way is not to try boot it via qemu and use packer but just use the build framework for everything, you can use the userpatches/customize-image.sh https://docs.armbian.com/Developer-Guide_User-Configurations/

we need to figure out how armbian is handling the boot process from start to finish, I'm getting conflicting info

https://forum.armbian.com/topic/38258-running-self-build-image-on-qemu-arm64/ => docs to build on qemu and how to boot with u boot new method

Armbian doesn't support cloud-init by default like the cloud images of ubuntu do, we'll have to use the build framework to create our custom image. first figure out how it works then automate it via pipelines.

https://forum.armbian.com/topic/14616-cloud-init/ => **DEPRECATED** cloud init seems to have been added in:

To rebuild the Ubuntu-based Armbian image specifically for the Rock5A and include Cloud-Init, you can use the **Armbian Build Framework**. This will allow you to start with the same base image but customize it to include Cloud-Init and any other packages or configurations you want. Here’s a step-by-step guide to achieve that.

### Steps to Rebuild Armbian Image for Rock5A with Cloud-Init:

#### 1. **Set Up Armbian Build Environment**

You’ll need a Linux machine (or VM) with the necessary build dependencies to compile the Armbian image.

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


To include `cloud-init` in the image, you’ll modify the Armbian build configuration files and enable the extension.

1. **Edit the Build Configuration**:
   
   - Navigate to the `userpatches` directory and create a new `lib.config` file if it doesn’t already exist:
     ```bash
     mkdir -p userpatches
     nano userpatches/lib.config
     ```

   - Add the following line to ensure the `cloud-init` extension is enabled during the build process:
     ```bash
     EXTENSIONS="$EXTENSIONS cloud-init"
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


