# Ubuntu Server

Since we will be focussing on ubuntu based distro's it only seemed logical to me to select ubuntu-server as the OS for the x86 hosts. Since I'll be using a container orchestration platform as the main controle plane of my cloud i'm not even going to virtualize the hosts.

## Deploy the OS

Since we'll have to deploy and redeploy many instances we need some kind of default config for each of the OS's for that I've choosen to use a cloud init script.

Using Cloud-init for your local cloud project to create standard images for both Armbian (Ubuntu-based) and Ubuntu Server on x86 hosts is a great approach. Here’s a general workflow to help you get started with creating standard images using Cloud-init.

### Steps to Set Up Cloud-init for Your Hosts:

#### 1. **Install and Enable Cloud-init (if not pre-installed)**:
   - On Ubuntu-based systems (including Armbian), Cloud-init is typically pre-installed. But if it’s not available, you can install it:
     ```bash
     sudo apt update
     sudo apt install cloud-init
     ```

#### 2. **Create a Base Cloud-init Configuration**:
   - Cloud-init uses YAML-based configuration files to apply settings on the first boot. You can create a “base” configuration that defines what will be pre-configured for all hosts. Here's an example of what a Cloud-init YAML file might look like:

     ```yaml
     #cloud-config
     hostname: your-default-hostname
     manage_etc_hosts: true

     users:
       - name: yourusername
         sudo: ALL=(ALL) NOPASSWD:ALL
         ssh-authorized-keys:
           - ssh-rsa your-public-ssh-key-here

     package_update: true
     package_upgrade: true

     packages:
       - vim
       - htop
       - curl
       - docker.io
       - nfs-common

     write_files:
       - path: /etc/motd
         content: |
           Welcome to your custom server!

     runcmd:
       - systemctl enable docker
       - echo "Cloud-init completed." > /var/log/cloud-init-status.txt
     ```

   This configuration will:
   - Set a default hostname and manage `/etc/hosts`.
   - Create a user with SSH access and sudo privileges.
   - Update and upgrade the package list.
   - Install basic utilities (like Docker, vim, etc.).
   - Write a welcome message to `/etc/motd`.
   - Enable and start Docker on boot.
   - Run any custom commands in `runcmd` (like logging Cloud-init status).

#### 3. **Create a Custom Image**:
   - Once you’ve defined your Cloud-init configuration, the next step is to create an image that uses this configuration. On Ubuntu/Armbian, this can be done using `cloud-init` with pre-installed cloud images, or you can create a custom image using a tool like `Packer` or `qemu-img`.

   - For Armbian:
     - You can customize an Armbian image, then pre-configure it with Cloud-init by placing the Cloud-init configuration at `/etc/cloud/cloud.cfg.d/01_custom.cfg` or creating a `user-data` file and integrating it into the image.

   - For x86 Ubuntu:
     - Similarly, you can create an image from an Ubuntu server installation and pre-configure it with Cloud-init by placing the `user-data` file in the correct directory.

#### 4. **Preseed with Cloud-init**:
   - You can also leverage Cloud-init to preseed network settings, partitions, or other lower-level configurations.
   
   Example of configuring static network settings:
   ```yaml
   network:
     version: 2
     ethernets:
       eth0:
         dhcp4: false
         addresses: [192.168.1.100/24]
         gateway4: 192.168.1.1
         nameservers:
           addresses: [8.8.8.8, 8.8.4.4]
   ```

#### 5. **Testing and Bootstrapping**:
   - Once you’ve created your base image with Cloud-init, you can test the deployment by spinning up a VM or ARM-based device with the new image.
   - Cloud-init will automatically detect the user-data and apply it on the first boot.

#### 6. **Re-deploying Hosts**:
   - With the image configured, you can easily redeploy hosts. You can store your base image (or user-data) in your local network and configure your ARM devices and x86 hosts to boot from this image.
   - This process is especially helpful for your local cloud since Cloud-init provides flexible, reproducible deployment across different architectures (ARM and x86).

### Advanced Tips:

1. **Reusing and Extending Configurations**:
   - You can break down complex Cloud-init configurations into multiple YAML files (under `/etc/cloud/cloud.cfg.d/`), and include them in your images for modularity and reusability.

2. **Automating Image Creation**:
   - You can automate the image creation process with tools like Packer to build custom VM or ARM images that already include your desired Cloud-init configuration.

3. **Local Metadata Server (Optional)**:
   - If you want to use more dynamic configuration options, consider setting up a local metadata server to serve Cloud-init with instance-specific metadata for your redeployed hosts.

### Summary:
Cloud-init will allow you to create a base configuration that can be applied across your various hosts, whether they are ARM (Armbian) or x86 (Ubuntu Server). The key is setting up a `cloud-config` file that preconfigures network settings, user accounts, software packages, and services, which will be applied on the first boot of the host. This method avoids having to inventory and deploy hosts via tools like Ansible, providing a more native and streamlined approach.

To achieve a dynamic configuration where hostnames are unique but follow a specific pattern, you can leverage the flexibility of Cloud-init. You can create a config that dynamically sets the hostname, for example by using a combination of a fixed prefix and a randomly generated suffix.

Let’s start with the Cloud-init configuration for a dynamic hostname, and then build on that for other dynamic requirements.

### 1. **Dynamic Hostname Generation**:
You can use Cloud-init's `hostname` directive and combine it with built-in shell commands to generate a unique, random hostname on boot.

Here’s an example `cloud-config` that sets a dynamic hostname with a fixed prefix and a random 6-character suffix.

```yaml
#cloud-config
hostname: default-hostname
manage_etc_hosts: true

# Dynamic hostname generation: fixed prefix + random 6-character suffix
runcmd:
  - |
    PREFIX="myserver-"
    SUFFIX=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo '')
    NEW_HOSTNAME="$PREFIX$SUFFIX"
    echo "Setting hostname to: $NEW_HOSTNAME"
    hostnamectl set-hostname $NEW_HOSTNAME
    sed -i "s/default-hostname/$NEW_HOSTNAME/g" /etc/hosts

users:
  - name: michiel
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ssh-rsa your-public-ssh-key-here

package_update: true
package_upgrade: true

packages:
  - vim
  - curl
  - docker.io
  - nfs-common

runcmd:
  - systemctl enable docker
  - echo "Cloud-init configuration complete." > /var/log/cloud-init-done.log
```

### Explanation:
- **Dynamic Hostname Generation**: 
   - The hostname is built using a fixed prefix (`myserver-`) and a random suffix generated using `/dev/urandom`. This creates a unique hostname for each host.
   - The `runcmd` section handles the dynamic hostname assignment, and the `/etc/hosts` file is updated accordingly.

### 2. **Adding More Dynamic Elements**:
You might want other parts of the configuration to be dynamic. For example, you can:
- **Fetch Metadata**: Use metadata services (if available in your environment) to gather instance-specific information like IP addresses or region, and configure your system based on that.
- **Dynamic File Creation**: You can generate files or configuration dynamically based on hostname, IP, or other system properties.
  
Let’s add some more examples of how to make the config dynamic.

#### 2.1 **Dynamic Network Configuration**:
You could also make the network configuration dynamic by using DHCP, or you can script network settings dynamically using Cloud-init.

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
```

#### 2.2 **Dynamic File Creation Based on Hostname**:
Here’s how you could dynamically create a file based on the hostname:

```yaml
runcmd:
  - |
    HOSTNAME=$(hostname)
    echo "This is server $HOSTNAME" > /etc/my-server-info.txt
```

#### 2.3 **Random Password for the User**:
You can generate a random password for the default user on each deployment:

```yaml
users:
  - name: michiel
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $(openssl rand -base64 12)
    ssh-authorized-keys:
      - ssh-rsa your-public-ssh-key-here
```

In this case, you would need to find a way to securely communicate or store the password for later use, like sending it to a log or a monitoring system.

### 3. **Testing the Configuration**:
Once you’ve created your configuration file, you can start by testing it locally:

1. **Cloud-init Local Testing**:
   Cloud-init can be tested locally without redeploying the full image by using the `cloud-init single` command:
   ```bash
   sudo cloud-init single --name runcmd --mode init
   ```

   This will simulate the first-boot execution without needing a complete reboot.

2. **Cloud-init Logs**:
   Cloud-init writes logs to `/var/log/cloud-init.log` and `/var/log/cloud-init-output.log`, where you can verify if all steps executed as expected.


## Create the image

[//]: # (Yes, you can absolutely take the official Ubuntu Server image, add your Cloud-init configuration files directly to the `/etc` directory, and then use that image for deployment! This is a simpler and more direct approach. Here’s how you can do that:)

[//]: # ()
[//]: # (### Steps to Modify the Official Ubuntu Server Image with Cloud-Init)

[//]: # ()
[//]: # (1. **Download the Official Ubuntu Server Cloud Image**)

[//]: # ()
[//]: # (You can download the Ubuntu Server image &#40;for example, Ubuntu 20.04&#41; directly from the official website:)

[//]: # ()
[//]: # (```bash)

[//]: # (wget https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img)

[//]: # (```)

[//]: # ()
[//]: # (You can also use a more recent version if necessary.)

[//]: # ()
[//]: # (### 2. **Mount the ISO and Extract Files**)

[//]: # ()
[//]: # (To modify the image, you'll need to extract it and modify the contents.)

[//]: # ()
[//]: # (1. **Mount the ISO**:)

[//]: # ()
[//]: # (```bash)

[//]: # (mkdir /mnt/iso)

[//]: # (sudo mount -o loop ubuntu-24.04-server-cloudimg-amd64.img /mnt/iso)

[//]: # (```)

[//]: # ()
[//]: # (2. **Copy the Files** to a working directory:)

[//]: # ()
[//]: # (```bash)

[//]: # (mkdir ~/ubuntu-custom)

[//]: # (cp -r /mnt/iso/* ~/ubuntu-custom/)

[//]: # (```)

[//]: # ()
[//]: # (3. **Unmount the ISO**:)

[//]: # ()
[//]: # (```bash)

[//]: # (sudo umount /mnt/iso)

[//]: # (```)

[//]: # ()
[//]: # (### 3. **Modify the Cloud-Init Configuration**)

[//]: # ()
[//]: # (Now, let's add your Cloud-init configuration files to the extracted image.)

[//]: # ()
[//]: # (1. **Navigate to the `~/ubuntu-custom` directory** where you copied the files:)

[//]: # ()
[//]: # (```bash)

[//]: # (cd ~/ubuntu-custom)

[//]: # (```)

[//]: # ()
[//]: # (2. **Create the Cloud-init configuration files** inside the appropriate directories:)

[//]: # ()
[//]: # (- **Create `user-data`** in `/etc/cloud/cloud.cfg.d/99_custom.cfg`:)

[//]: # ()
[//]: # (```bash)

[//]: # (nano ~/ubuntu-custom/etc/cloud/cloud.cfg.d/99_custom.cfg)

[//]: # (```)

[//]: # ()
[//]: # (Add your Cloud-init logic here:)

[//]: # ()
[//]: # ()
[//]: # (This will allow your Cloud-init configuration to be applied on first boot.)

[//]: # ()
[//]: # (### 4. **Rebuild the ISO**)

[//]: # ()
[//]: # (Now that you've modified the image and added your Cloud-init configuration, you need to rebuild the ISO file.)

[//]: # ()
[//]: # (1. **Create the new ISO**:)

[//]: # ()
[//]: # (```bash)

[//]: # (cd ~/ubuntu-custom)

[//]: # (mkisofs -o ~/ubuntu-custom-server.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Custom Ubuntu Server" .)

[//]: # (```)

[//]: # ()
[//]: # (This command creates a bootable ISO named `ubuntu-custom-server.iso` with your Cloud-init configuration included.)

[//]: # ()
[//]: # ()

my docs below

---

### Use Ubuntu Cloud Images

Ubuntu Cloud Images are designed to work with Cloud-init out of the box and are ideal for creating custom deployments. You can download them, modify them, and directly write them to a USB drive.

[Ubuntu pre-installed images download page](https://cloud-images.ubuntu.com/releases/).

1. **Download the Ubuntu Cloud Image**:
   
   You can get the cloud image for Ubuntu Server (e.g., 20.04 LTS) from here:

   ```bash
   wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
   ```

2. **Modify the Image with Cloud-init Configuration**:
   
   Once downloaded, you can modify the image by adding your `user-data` configuration to the image or using a "seed" ISO for the Cloud-init configuration.

   - **Mount the Image** (using `guestmount` or `libguestfs`):
   
     ```bash
     sudo apt-get install libguestfs-tools
     sudo guestmount -a focal-server-cloudimg-amd64.img -i --rw /mnt/ubuntu
     ```
   
   - **Copy your Cloud-init configuration** to `/etc/cloud/cloud.cfg.d/99_custom.cfg`:

     ```bash
     sudo cp user-data /mnt/ubuntu/etc/cloud/cloud.cfg.d/99_custom.cfg
     ```

   - **Unmount the Image**:

     ```bash
     sudo umount /mnt/ubuntu
     ```

3. **Write the Image to USB**:

   You can now directly write the image to a USB drive using `dd`:

   ```bash
   sudo dd if=focal-server-cloudimg-amd64.img of=/dev/sdX bs=4M status=progress && sync
   ```

   Replace `/dev/sdX` with the correct device path for your USB drive.


4. **Check format and convert if needed**:

    You can check the format to see if it needs to be changed with
    ````shell
    qemu-img info <path-to-your-image>
    ````






### Output Example:

You’ll see something like this:

```
image: ubuntu-24.04-server-cloudimg-amd64.img
file format: qcow2
virtual size: 2.0G (2147483648 bytes)
disk size: 1.3G
cluster_size: 65536
```

### Key Points to Check:
- **File format**: This will tell you the format of the image. Common formats are:
  - `qcow2`: QEMU Copy-On-Write version 2, a flexible and space-efficient image format.
  - `raw`: A simple raw disk image without any special features.
  
- **Virtual size**: The virtual size of the image.
  
- **Disk size**: The actual space taken by the image on your disk.

### Next Steps:
- **If the image is in `qcow2` format** (or any format other than `raw`), and you plan to write the image directly to an SSD, you should convert it to `raw`.
  
- **If the image is already in `raw` format**, you can directly write it to your SSD using `dd`.

### To Convert (If Needed, was needed in my case):

```bash
qemu-img convert -f qcow2 -O raw <source-image> <output-raw-image>
```

For example:

```bash
qemu-img convert -f qcow2 -O raw ubuntu-24.04-server-cloudimg-amd64.img ubuntu-24.04-server-cloudimg-amd64.raw
```

This will create a `raw` format image that you can write to the SSD.

---

