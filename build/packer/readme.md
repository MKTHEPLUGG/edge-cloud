## Script Architecture

## Required software to install / preconfigure

1. **Software**
   - net-tools
   - nfs-common
   - fail2ban
   - zsh / ohmyzsh

2. **Config**
   - hostname
   - keyboard / locales / time
   - sshd config
   - zsh config + theme

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

   You’ll create a Packer template that defines how to build your image. Here’s an example template in the hcl format for building an Armbian image:

   ````hcl
   packer {
      required_plugins {
        qemu = {
          version = ">= 1.0.0"
          source  = "github.com/hashicorp/qemu"
        }
      }
    }
    
    source "qemu" "armbian" {
      iso_url           = var.iso_url
      output_directory  = "output-armbian-image"
      disk_size         = 20000
      format            = "raw"
      headless          = true
      qemuargs          = [
        ["-m", "2048"],
        ["-net", "user,hostfwd=tcp::2222-:22"],
        ["-net", "nic"]
      ]
      iso_checksum      = "sha256:15dd545fb0c829b1e8fd3ddd431cf4e42614baed99910a60f33d50e4caf9cde9"
      ssh_port          = 2222
      ssh_username      = var.ssh_username
      ssh_password      = var.ssh_password
    }
    
    build {
      sources = ["source.qemu.armbian"]
    
      provisioner "shell" {
        environment_vars = [
          "IMAGE_NAME=$(basename ${var.iso_url})"
        ]
        inline = [
          "sudo apt-get update",
          "sudo apt-get install -y unxz",
          "unxz -v $IMAGE_NAME",
          "echo 'Decompression complete!'",
          "sudo cloud-init clean",
          "sudo chmod +x /home/sysadmin/deploy-script.sh"
        ]
      }
    
      provisioner "file" {
        source      = "config/cloud-config.yaml"
        destination = "/etc/cloud/cloud.cfg.d/99_custom.cfg"
      }
    
      provisioner "file" {
        source      = "config/deploy-script.sh"
        destination = "/home/sysadmin/deploy-script.sh"
      }
    
      post-processor "shell-local" {
        inline = [
          "qemu-img convert -O raw output-armbian-image/packer-qemu output-armbian-image/armbian-custom-image.raw"
        ]
      }
    }

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

---

### Next Steps
- Automate the image creation by integrating Packer into a CI/CD pipeline or scheduling builds as needed.

---

look into adding below stuff to above filtered docs.

7. **When packer is building use VNC to connect to the Host**


Yes, you can use a VNC client from your shell to connect to the VNC server at `vnc://127.0.0.1:5956`. Here are the common ways you can do this depending on your environment:

### 1. **Using `vncviewer` (from the `tigervnc` package)**

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


### 3. **SSH Tunnel for Remote Shell Use**

If you are using a remote machine and want to use VNC from your local machine, you can forward the VNC port over SSH.

1. **Create an SSH tunnel** from your local machine (replace `remote_user` and `remote_host` with your credentials):
   ```bash
   ssh -L 5956:127.0.0.1:5956 remote_user@remote_host
   ```

2. **Connect via VNC**:
   Run the `vncviewer` command locally to connect:
   ```bash
   vncviewer 127.0.0.1:5956
   ```

This method forwards port `5956` from the remote host to your local machine, so you can use a VNC viewer from your local machine as if the VM were running locally.

### 4. **Using `xfreerdp` with VNC**

Alternatively, if you prefer using FreeRDP, you can install it and use it to connect to the VNC server.

1. **Install FreeRDP**:
   ```bash
   sudo apt-get install freerdp2-x11
   ```

2. **Connect to the VNC server**:
   ```bash
   xfreerdp /v:127.0.0.1:5956
   ```

### Summary:
- Use `vncviewer` or `xvnc4viewer` to connect to the VNC server running on `127.0.0.1:5956`.
- If you're working remotely, you may need to set up SSH port forwarding to view VNC locally.
  
Let me know how it goes or if you encounter any issues!


The error message "Can't open display" typically means that the `vncviewer` is unable to open a graphical window to display the VNC session. This is likely because you're running the command in a terminal without graphical environment support, such as when you're using SSH without X11 forwarding, or your system doesn't have an active graphical session.

Here are a few solutions to address this issue:

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

### 2. **Using `Xvfb` for Headless VNC Connection**
   If you're working in a completely headless environment without access to a graphical session (like a remote server), you can use `Xvfb` (X Virtual Framebuffer) to emulate a display.

   1. **Install `Xvfb`:**
      - On Ubuntu/Debian:
        ```bash
        sudo apt-get install xvfb
        ```

   2. **Run `Xvfb` to Create a Virtual Display:**
      You can start a virtual framebuffer display on display number `:1`:
      ```bash
      Xvfb :1 -screen 0 1024x768x16 &
      export DISPLAY=:1
      ```

   3. **Run `vncviewer`:**
      Now, you should be able to launch `vncviewer` using the virtual display:
      ```bash
      vncviewer 127.0.0.1:5956
      ```

### 3. **Using VNC from Another Local Machine**
   If your current environment is fully headless, and graphical applications won't work, you can run the VNC session from another machine that supports graphical applications (like your personal computer or laptop).

   1. **Set Up SSH Tunnel**:
      If your VM is remote, create an SSH tunnel for VNC forwarding:
      ```bash
      ssh -L 5956:127.0.0.1:5956 remote_user@remote_host
      ```

   2. **Run `vncviewer` Locally**:
      Run the `vncviewer` on your local machine, and connect to `127.0.0.1:5956`.

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

sudo apt install xvfb



---

Reference :

- [Official Qemu Docs](https://developer.hashicorp.com/packer/integrations/hashicorp/qemu/latest/components/builder/qemu)