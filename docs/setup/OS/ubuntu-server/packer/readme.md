## automate image creation with packer

### How Packer Works
Packer uses **builders** to create images, **provisioners** to configure the system (install software, set up users, etc.), and **post-processors** to handle the output (convert the image, compress, etc.). You can define the process in a single JSON or HCL configuration file.

### Steps to Automate Image Creation with Packer

1. **Install Packer**

   First, you’ll need to install Packer on your system:

   ```bash
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install packer
   packer plugins install github.com/hashicorp/qemu
   ```

2. **Create a Packer Template**

   You’ll create a Packer template that defines how to build your image. Here’s an example template in JSON format for building an Ubuntu cloud image:

   ```json
   {
     "builders": [
       {
         "type": "qemu",
         "iso_url": "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img",
         "output_directory": "output-ubuntu-image",
         "disk_size": 20000,
         "format": "raw",
         "headless": true,
         "qemuargs": [["-m", "2048"]]
       }
     ],
     "provisioners": [
       {
         "type": "shell",
         "inline": [
           "sudo apt-get update",
           "sudo apt-get install -y curl",
           "echo 'Customizing the image'",
           "sudo cloud-init clean"
         ]
       },
       {
         "type": "file",
         "source": "user-data",
         "destination": "/etc/cloud/cloud.cfg.d/99_custom.cfg"
       }
     ],
     "post-processors": [
       {
         "type": "shell-local",
         "inline": [
           "qemu-img convert -O raw output-ubuntu-image/packer-qemu output-ubuntu-image/ubuntu-custom-image.raw"
         ]
       }
     ]
   }
   ```

   In this example:
   - The **builder** uses QEMU to create the image, starting from the `focal-server-cloudimg-amd64.img`.
   - The **provisioners** run shell commands and copy the Cloud-init `user-data` file into the appropriate directory.
   - The **post-processor** converts the final image to `raw` format.

3. **Create the `user-data` File** (Cloud-init Configuration)

   Make sure you have a `user-data` file ready. Refer to [this](packer/cloud-config.yaml) for an example

   Save this file as `user-data` in the same directory as the Packer template.

4. **Run Packer**

   Once the Packer template is ready, you can run it:

   ```bash
   packer build ubuntu-packer-template.json
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

---

### Next Steps
- Automate the image creation by integrating Packer into a CI/CD pipeline or scheduling builds as needed.

