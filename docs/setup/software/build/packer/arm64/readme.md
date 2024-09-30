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

3. Use QEMU to Boot and Access the Shell

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
        TO BE REFINED GET FROM ARMBIAN IMAGE

   ````



   In this example:
   - The **builder** uses QEMU to create the image, starting from the `focal-server-cloudimg-amd64.img`.
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
   - Download the cloud image.
   - Customize it with your Cloud-init configuration and other provisions.
   - Convert the final output to `raw` format.

5. **Result: The Final Image**

   After running the Packer build, you’ll find the final raw image in the `output-ubuntu-image` directory. You can directly copy this image to a USB drive or deploy it on any other system.

6. **Automating Future Builds**

   Once you have the Packer template, you can automate your builds. You can integrate it with CI/CD pipelines (e.g., GitHub Actions, Jenkins) to rebuild the image whenever changes are made to the configuration.




### Example Workflow

- **Builders**: Define the base image (e.g., Ubuntu Cloud Image) and settings (memory, disk size, etc.).
- **Provisioners**: Run shell scripts to install packages, copy files, and configure the image.
- **Post-processors**: Convert the final image to a desired format (like raw for USB deployment).
