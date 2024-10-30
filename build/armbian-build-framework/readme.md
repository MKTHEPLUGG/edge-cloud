# Use Armbian build framework to create custom image

we'll use this as a place to filter everything from docs to create 1 proper doc and then move it back

this doc will go over the main install of the framework and setting up stuff that is the same in all envs, we'll then create docs in sub dir per board


## Steps to Rebuild Armbian Image for Rock5A with Cloud-Init:

### 1. **Set Up Armbian Build Environment**

You’ll need a Linux machine (or VM) with the necessary build dependencies to compile the Armbian image.

- First, clone the official [Armbian build repository]https://github.com/armbian/build to the path `edge-cloud/`:
  
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
     

# configure cloud init

[Official Docs Cloud-Init Config](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)


# Other customizations


# Deploy via pipeline

# Device specific docs can be found here
- [Rock5a](./rock5a/readme.md)
- [RaspberryPi 4b](./rpi4b)


