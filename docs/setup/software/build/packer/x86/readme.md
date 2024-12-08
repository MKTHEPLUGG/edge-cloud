# Automate Image Creation with Packer

## Packer Basics

Packer simplifies the creation of custom images through three core components:

- **Builders**: Define the base image (e.g., Ubuntu Cloud Image) and configure hardware settings like memory, disk size, and virtualization options.
- **Provisioners**: Customize the image by running shell scripts, installing software, copying files, and setting up configurations.
- **Post-processors**: Handle the final image output, such as converting it to a specific format (e.g., raw for USB deployment) or compressing it for distribution.

With Packer, you can automate the entire process in a single JSON or HCL configuration file, making it easy to replicate and customize image builds.

## Ubuntu Cloud Images

We’ll use the **Ubuntu Cloud Image**, as it supports Cloud-Init by default. However, any image that supports Cloud-Init can be used. Alternatively, you can skip Cloud-Init entirely and handle all configuration through the extra bash script we already use to perform some extra configuration.

- [**Ubuntu Cloud Images**](https://cloud-images.ubuntu.com/releases/): Official Ubuntu images optimized for cloud environments. They come pre-installed with cloud-init for configuration.

## Automate Image Creation with Packer

### Install Packer

You'll need a build host with packer installed. Here's how to install Packer on Ubuntu:

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# if you don't have apt-add-repository => sudo apt install software-properties-common
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y && sudo apt install packer -y
packer plugins install github.com/hashicorp/qemu

# optional package list: qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager genisoimage guestfs-tools
```

### Packer Template

We've created a [**Packer template**](../../../../../../build/packer/ubuntu-cloud-image/ubuntu.pkr.hcl) that defines how to build our ubuntu image. Feel free to modify it to suit your specific needs. Since ubuntu supports cloud init by default via the cloud image we'll be leveraging it to do some modifications during initial boot.

In this example:
- The **builder** uses QEMU to create the image, starting from the `focal-server-cloudimg-amd64.img`.
- The **provisioners** run shell commands and copy the Cloud-init `user-data` file into the appropriate directory.
- The **post-processor** converts the final image to `raw` format.

### Cloud-init Configuration - ``user-data`` file

The configuration packs user data into the image for **Cloud-Init** because **Cloud-Init User Data is Mounted as a CD-ROM (ISO):**
- The `cd_files` directive specifies the path to the directory containing the Cloud-Init `user-data` and `meta-data` files (`./cloud-init/*`).
- The `cd_label` is set to `cidata`, which is the default label Cloud-Init expects for NoCloud configuration.

When the VM boots, the Cloud-Init process in the Ubuntu cloud image automatically checks for a CD-ROM with the `cidata` label and reads the `user-data` and `meta-data` files from it to configure the instance.

[//]: # (Make sure you have a `user-data` file ready. In our template this is handled by copying the contents of the ``build/packer/ubuntu-cloud-image/cloud-init`` directory to the standard dir `/etc/cloud/cloud.cfg.d/99_custom.cfg` inside the image during packer build.)

### Extra scripts

We've added extra configuration to the [**install.sh**](./../../../../../../build/packer/ubuntu-cloud-image/scripts/install.sh) script. This will perform extra modifications that aren't defined in cloud-init config.

### Run Packer

Simply go to the directory holding the template and run it with:

```bash
sudo packer build .
```

This will automatically:
- Download the cloud image.
- Customize it with our Cloud-init configuration and other provisions.
- Convert the final output to `raw` format.
- make sure to run ``packer`` as root if you are using any plugins (like qemu) that require root access.

After running the Packer build, you’ll find the final raw image in the `output-ubuntu-image` directory. You can directly copy this image to a USB drive or deploy it on any other system.

### Automating Future Builds

Once you have the Packer template, you can automate your builds. You can integrate it with CI/CD pipelines (e.g., GitHub Actions, Jenkins) to rebuild the image whenever changes are made to the configuration.

**TODO: Add a section on how to automate Packer builds with CI/CD pipelines.**

## Troubleshoot image after creation

### Connect to image via VNC during build

If you're on a Linux system, you can use the `tigervnc` package, which includes the `vncviewer` command-line tool.

1. **Install TigerVNC Viewer** if you don’t already have it installed:
   - On Ubuntu/Debian:
     ```bash
     sudo apt-get install tigervnc-viewer
     ```
   - On Fedora:
     ```bash
     sudo dnf install tigervnc
     ```

2. **Connect to the VNC server:**
   Run the following command to connect to the VNC server at `127.0.0.1:5956`:
   ```bash
   vncviewer 127.0.0.1:5956
   ```

This will open a graphical VNC session in a new window where you can view the virtual machine's display. 
However, this is only supported on a host with graphical capabilities.

### SSH Tunnel for Remote Shell Use

If your current environment is fully headless, and graphical applications won't work, you can run the VNC session from another machine that supports graphical applications (like your personal computer or laptop).

1. **Create an SSH tunnel** from your local machine (replace `remote_user` and `remote_host` with your credentials):
   ```bash
   ssh -L 5956:127.0.0.1:5956 remote_user@remote_host
   ```

2. **Connect via VNC**:
   Run the `vncviewer` command locally to connect:
   ```bash
   vncviewer 127.0.0.1:5956
   ```

3. **for windows users**: use ``MobaXterm`` as vncviewer.

This method forwards port `5956` from the remote host to your local machine, so you can use a VNC viewer from your local machine if your remote host doesn't support graphical applications.

### Use QEMU to Boot Image and Access the Shell

if you prefer to boot the image directly and access the shell from a running system, you can use QEMU:

```bash
sudo qemu-system-x86_64 -m 2048 -drive file=./output-noble/ubuntu-noble.raw,format=raw -nographic -serial mon:stdio
```

###  Shell Access via ``chroot``

Alternatively, to get a shell inside the image, you can mount the image and use `chroot` to access the filesystem as if you're inside that environment. Here's how to do it:

#### Create a directory to mount the image:

we'll need a directory to hold our mounted image:

```bash
sudo mkdir /mnt/image
```
#### Mount the image file

assuming the image is in raw format, you can mount it using

```bash
sudo mount -o loop /path/to/your/image.raw /mnt/image
```

If it's still in `.img` format, you can still mount it similarly:

```bash
sudo mount -o loop /path/to/your/image.img /mnt/image
```

#### Enter a chroot environment:
Now you can change your root directory to the mounted image's filesystem using `chroot`:

```bash
sudo chroot /mnt/image /bin/bash
```

This gives you a shell inside the mounted image. You can verify and test configurations as if you're running inside the image's root filesystem. You can inspect files, verify installations, and troubleshoot any issues.

#### Exiting and Unmounting
After you're done, exit the chroot environment:

```bash
exit
```
Then, unmount the image:

```bash
sudo umount /mnt/image
```

#### If the Image Uses Partitions
If your image has multiple partitions, you can first check the partitions using `fdisk` or `parted`:

```bash
sudo fdisk -l /path/to/your/image.img
```

You'll see the partition offsets, and you can mount the specific partition like this:

```bash
sudo mount -o loop,offset=<partition-offset> /path/to/your/image.img /mnt/image
```

Replace `<partition-offset>` with the appropriate offset, which can be calculated from the `fdisk` output (usually in bytes).

---

**below needs to be refined and added if needed**

### 1. **Ensure X11 Forwarding is Enabled (For Remote SSH Sessions)**
   If you're running this on a remote machine via SSH, you'll need X11 forwarding to open graphical applications.

   1. **Enable X11 Forwarding in SSH**:
      When you connect via SSH, add the `-X` (or `-Y` for trusted forwarding) flag to enable X11 forwarding:
      ```bash
      ssh -X remote_user@remote_host
      ```

   2. **Install `xauth` on the Remote System**:
      If `xauth` is missing on the remote system, install it:
      - On Ubuntu/Debian:
        ```bash
        sudo apt-get install xauth
        ```
      - On Fedora/CentOS:
        ```bash
        sudo dnf install xorg-x11-xauth
        ```

   3. **Ensure Your Local Machine Supports X11**:
      Ensure your local machine has an X server running (e.g., `XQuartz` on macOS, `VcXsrv` or `Xming` on Windows).


### 3. **Using VNC from Another Local Machine**

### 4. **Running VNC in a Desktop Session**
   If you are working in a local environment with a desktop environment but still face this issue, make sure your system has a running graphical environment (e.g., GNOME, KDE, etc.).

   - If you are on a headless environment but want to run GUI applications, you can install a minimal desktop environment and use `vncviewer` in it.

   - For Ubuntu, for example, you can install a minimal desktop environment:
     ```bash
     sudo apt-get install ubuntu-desktop
     ```

### Summary of Options:
- **X11 Forwarding**: Use `ssh -X` if you're connecting to a remote machine and need graphical applications forwarded.
- **Xvfb**: Use `Xvfb` to create a virtual display if your environment is entirely headless.
- **Local VNC Viewer**: Forward VNC traffic through an SSH tunnel and use a local VNC viewer if possible.

---



# Zi a package manager for zsh

https://github.com/z-shell/zi
[zi install](https://wiki.zshell.dev/docs/getting_started/installation)
---

# Troubleshooting

### 1. **Why VNC is Not Showing Anything**
The VNC server that Packer starts is attempting to connect to a display, but since your server doesn’t have a graphical environment (like GNOME, KDE, or even a basic X server), there is no graphical output to show. The VNC is essentially connected to a "blank" screen, because the VM doesn't know what to display.

### 2. **Steps to Resolve the VNC Blank Screen**

#### Option 1: Use VNC for Console Output
If you don’t need a GUI but want to see the **console output** (text-based terminal) in VNC, you can configure QEMU to output the console over VNC. By default, VNC may not be configured to display the console or text output.

1. **Modify your Packer configuration to use a QEMU serial console with VNC**. Add the following to your `qemuargs` section:

   ```json
   ["-display", "vnc=:1"],  # binds VNC to display 1
   ["-serial", "mon:stdio"] # enables serial output
   ```

   This tells QEMU to show the serial console (a basic terminal) in the VNC session. Now, when you connect via VNC, you should see the console output of your VM.

2. **Restart your Packer build**, and try connecting again with VNC:

   ```bash
   vncviewer 127.0.0.1:5918
   ```

   You should now see the terminal output instead of a blank screen.

---

## Reference :

- [Customize MOTD](https://www.putorius.net/custom-motd-login-screen-linux.html)
- [Original Repo Reference For Packer Config](https://github.com/nbarnum/packer-ubuntu-cloud-image/tree/main)
- [Packer Builder ARM](https://github.com/mkaczanowski/packer-builder-arm/tree/fec4cd5c642a736e0a81c11827d085c7f1a84b0a)

[//]: # (- [Guide]&#40;https://akashrajvanshi.medium.com/step-by-step-guide-creating-a-ready-to-use-ubuntu-cloud-image-on-proxmox-03d057f04fb2&#41;)

[//]: # (- [Official Qemu Docs]&#40;https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu&#41;)

[//]: # ()
[//]: # (- **[Example]&#40;https://shantanoo-desai.github.io/posts/technology/packer-ubuntu-qemu/&#41;**)

[//]: # ()
[//]: # (- **[Example 2]&#40;https://github.com/rlaun/packer-ubuntu-22.04/blob/master/ubuntu-22.04.json&#41;**)

[//]: # (- https://github.com/shantanoo-desai/packer-ubuntu-server-uefi/blob/main/templates/ubuntu.pkr.hcl)

[//]: # (- https://github.com/shantanoo-desai/packer-ubuntu-server-uefi)

---


### 1. **Autoinstall vs Cloud-Init**

- **Autoinstall**: The `autoinstall` directive is part of Ubuntu's Subiquity installer (used for server installs). It handles the initial installation process, including partitioning, user setup, and other system-wide configurations during installation.
- **Cloud-Init**: The `user-data` part of Cloud-Init configures the instance after the system has been installed, including user setup, package installation, and other runtime configurations.

If you're using the autoinstall method (via Subiquity), the `autoinstall` block is necessary to automate the server installation process. If your system is already installed and you're focusing on Cloud-Init, you only need the `#cloud-config` file (no `autoinstall` block).

### 2. **Combining the Working Cloud-Init with Locale Setup**

Since your second configuration works, you can simply add the locale settings to it. Here's how you can modify the working `user-data` file to include locale setup:

### Example of Working Cloud-Init with Locale and Keyboard Setup:

```yaml
#cloud-config
password: ubuntu
ssh_pwauth: true
chpasswd:
  expire: false

# Set the locale and keyboard layout
locale: nl_BE.UTF-8
keyboard:
  layout: be

# Timezone setup
timezone: Europe/Brussels

# Preserve hostname
preserve_hostname: false

# Update and upgrade packages on first boot
package_update: true
package_upgrade: true
```

### Explanation:

- **locale**: Sets the system locale to `nl_BE.UTF-8`.
- **keyboard**: Configures the keyboard layout to Belgian (`be`).
- **timezone**: Sets the system timezone to `Europe/Brussels`.
- **package_update** and **package_upgrade**: Ensures the system is updated on first boot.

### 3. **Do You Need the Autoinstall Section?**

You **don't need** the `autoinstall` section in a standard Cloud-Init file. The `autoinstall` block is only needed if you’re using the Subiquity installer to automate the entire OS installation process (not just configuration after install).

[//]: # (### Next Steps:)

[//]: # (- If you're focusing on post-installation configuration &#40;e.g., user setup, locale, SSH settings&#41;, the second working configuration with added locale setup is sufficient.)

[//]: # (- If you want to automate the full OS installation process &#40;pre-partitioning, user creation during install&#41;, then the `autoinstall` block would be used in a separate pre-install configuration file.)
