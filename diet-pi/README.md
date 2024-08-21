# **RKE2 Config for DietPi OS**

## **Prereqs before deploying RKE2**

### **Setting Network settings & Hostname**

add section with either script or commands, get from old guide

### **Enabling cgroup Memory and Hierarchy on Systems Booting from SD and Running from SSD**

#### **Step 1: Identify the SD Card’s Boot Partition**
The first step is to identify the SD card’s boot partition so you can mount it and edit the boot parameters.

1. **List Block Devices:**
   Use the `lsblk` command to identify the SD card and its partitions:
   ```bash
   lsblk
   ```

   You should see an output similar to this:
   ```
   NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   sda           8:0    0 232.9G  0 disk 
   ├─sda1        8:1    0   200M  0 part /boot
   └─sda2        8:2    0 232.7G  0 part /
   mmcblk0     179:0    0 119.1G  0 disk 
   ├─mmcblk0p1 179:1    0   128M  0 part 
   └─mmcblk0p2 179:2    0   119G  0 part 
   ```

   In this example:
   - `/dev/mmcblk0p1` is the boot partition on the SD card.
   - `/dev/mmcblk0p2` is the root partition on the SD card.

#### **Step 2: Mount the SD Card’s Boot Partition**

2. **Create a Mount Point:**
   If you don’t already have a mount point, create one:
   ```bash
   sudo mkdir -p /mnt/sdboot
   ```

3. **Mount the Boot Partition:**
   Mount the SD card’s boot partition to this directory:
   ```bash
   sudo mount /dev/mmcblk0p1 /mnt/sdboot
   ```

#### **Step 3: Edit the `cmdline.txt` File**

4. **Open `cmdline.txt`:**
   Use a text editor to open the `cmdline.txt` file located in the boot partition:
   ```bash
   sudo nano /mnt/sdboot/cmdline.txt
   ```

5. **Add Kernel Parameters:**
   Add the following parameters to the end of the existing line:
   ```bash
   systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory
   ```

   Your `cmdline.txt` file should now look something like this:
   ```
   coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_headphones=0 bcm2708_fb.fbwidth=0 bcm2708_fb.fbheight=0 bcm2708_fb.fbdepth=16 bcm2708_fb.fbswap=1 smsc95xx.macaddr=D8:3A:DD:0E:8D:67 vc_mem.mem_base=0x3f000000 vc_mem.mem_size=0x3f600000 root=PARTUUID=e72d462f-02 rootfstype=ext4 rootwait net.ifnames=0 logo.nologo console=tty1 systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory
   ```

   **Note:** Ensure all parameters are on a single line with spaces between them.

6. **Save and Exit:**
   - Press `Ctrl + X`, then `Y`, and then `Enter` to save the changes and exit.

#### **Step 4: Unmount the Boot Partition**

7. **Unmount the Boot Partition:**
   Unmount the SD card’s boot partition:
   ```bash
   sudo umount /mnt/sdboot
   ```

#### **Step 5: Reboot the System**

8. **Reboot:**
   Reboot the system to apply the changes:
   ```bash
   sudo reboot
   ```

#### **Step 6: Verify the Changes**

9. **Verify cgroup v2 and Memory Controller:**
   After the system reboots, verify that the memory cgroup and unified cgroup hierarchy are enabled:

   - Check if cgroup v2 is active:
     ```bash
     mount | grep cgroup2
     ```

   - Check if the `memory` controller is enabled:
     ```bash
     cat /sys/fs/cgroup/cgroup.controllers
     ```

     You should see something like this:
     ```
     cpuset cpu io memory pids
     ```

### **Repeat Process on Other DietPi Systems**

Whenever you set up a new DietPi system that boots from an SD card and runs from an SSD, follow these steps to ensure the necessary cgroup configurations are applied.

This guide ensures that your DietPi system is correctly configured to run RKE2 by enabling the required cgroup features.


## **Deploying RKE2**


### Basic Steps to Install RKE2 on DietPi

1. **Update DietPi**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```


3. **Download and Install RKE2**:
   ```bash
   curl -sfL https://get.rke2.io | sh -
   ```

4. **Enable and Start RKE2**:
   ```bash
   sudo systemctl enable rke2-server.service
   sudo systemctl start rke2-server.service
   ```

5. **Check the Status**:
   ```bash
   sudo systemctl status rke2-server.service
   ```

6. **Configure `kubectl`**:
   ```bash
   export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

7. **Verify the Cluster**:
   ```bash
   kubectl get nodes
   ```


## **Post Installation Steps**

after install RKE2 will add some binaries to the system that we should add to the path to be able to troubleshoot.

### Step 1: Determine the Installation Path

RKE2 typically installs binaries in `/var/lib/rancher/rke2/bin`. You can verify this by listing the contents of this directory:

```bash
ls /var/lib/rancher/rke2/bin
```

You should see binaries like `kubectl`, `crictl`, `ctr`, and others in this directory.

### Step 2: Add the RKE2 Binaries to Your PATH

You can add the RKE2 binaries directory to your `PATH` by editing your shell profile. This can be done by adding the path to the `.bashrc` or `.bash_profile` file (or `.zshrc` if you are using Zsh) in your home directory.

1. **Edit the `.bashrc` file**:
   
   Open the `.bashrc` file in a text editor:
   ```bash
   nano ~/.bashrc
   ```
   
2. **Add the RKE2 Binaries Path**:

   Scroll to the bottom of the file and add the following line:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

3. **Save and Exit**:
   
   Save the file and exit the text editor (in `nano`, you can do this by pressing `CTRL+X`, then `Y`, and `Enter`).

4. **Reload the Profile**:
   
   Apply the changes by reloading your `.bashrc` file:
   ```bash
   source ~/.bashrc
   ```

### Step 3: Verify the Path

After reloading the profile, you can verify that the `kubectl` and other RKE2 binaries are accessible by running:

```bash
kubectl version --client
crictl --version
```

If these commands return version information, then the binaries are correctly added to your `PATH`.

### Step 4: (Optional) Apply to All Users

If you want to make these binaries available system-wide (for all users), you can add the `PATH` export to `/etc/profile` or create a new file in `/etc/profile.d/`:

1. **Edit `/etc/profile`**:
   
   ```bash
   sudo nano /etc/profile
   ```
   
   Add the following line at the end:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

   Or,

2. **Create a New Profile Script**:
   
   Create a new file in `/etc/profile.d/`:
   ```bash
   sudo nano /etc/profile.d/rke2.sh
   ```
   
   Add the following line:
   ```bash
   export PATH=$PATH:/var/lib/rancher/rke2/bin
   # export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
   ```

   Save the file and exit.



### Step 5: (optional) Add `kubectl` Aliases

In the same `.bashrc` file, add the following aliases for `kubectl`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl edit'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
```

### Step 3: Enable Bash Completion for `kubectl`

Still in the `.bashrc` file, add the following lines to enable bash completion for `kubectl`:

```bash
# Enable kubectl bash completion
source <(kubectl completion bash)
alias k='kubectl'
complete -F __start_kubectl k
```

### Step 4: Save and Reload `.bashrc`

1. Save and exit the file (in `nano`, press `CTRL+X`, then `Y`, and `Enter`).

2. Reload your `.bashrc` to apply the changes:
   ```bash
   source ~/.bashrc
   ```


## **(Optional) Install `calicoctl` for troubleshooting**

Certainly! `calicoctl` is a command-line tool that helps you manage and troubleshoot Calico networks and resources. Here’s how you can install `calicoctl` on your system.

### Step 1: Download the `calicoctl` Binary

1. **Download the Latest Version**:
   - Determine the version of Calico you are using in your cluster. You can check the version by looking at the Calico pods:
     ```bash
     kubectl get pods -n calico-system
     ```
   - Go to the [Calico releases page](https://github.com/projectcalico/calico/releases) to find the matching version.

   Alternatively, download the latest version directly using the following command:
   ```bash
   curl -O -L https://github.com/projectcalico/calico/releases/download/v3.28.1/calicoctl-linux-arm64
   ```

   Replace `v3.26.1` with the version you identified earlier.

2. **Make the Binary Executable**:
   After downloading, you need to make the `calicoctl` binary executable:
   ```bash
   chmod +x calicoctl-linux-arm64
   ```

3. **Move the Binary to Your PATH**:
   Move the `calicoctl` binary to a directory in your `PATH`, such as `/usr/local/bin`:
   ```bash
   sudo mv calicoctl-linux-arm64 /usr/local/bin/calicoctl
   ```

### Step 2: Verify the Installation

To verify that `calicoctl` is installed correctly, you can run:

```bash
calicoctl version
```

This should display the version of `calicoctl` you just installed.

### Step 3: Configure Access to Your Kubernetes Cluster

`calicoctl` needs to be configured to access your Kubernetes cluster. There are two main ways to use `calicoctl`:

1. **In Kubernetes Datastore Mode** (recommended for Kubernetes clusters):
   - `calicoctl` automatically uses the Kubernetes API to manage resources. You need to provide it access to your cluster by pointing it to your kubeconfig file:
     ```bash
     export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
     ```

   - You can verify the connection by running:
     ```bash
     calicoctl get nodes
     ```
     This should list the nodes in your cluster.

### Step 4: Start Using `calicoctl`

With `calicoctl` installed and configured, you can now use it to manage and troubleshoot your Calico network. Some useful commands include:

- **Check IP Pools**:
  ```bash
  calicoctl get ippools
  ```

- **Show IP Allocation**:
  ```bash
  calicoctl ipam show --show-blocks
  ```

- **Release an IP Address**:
  ```bash
  calicoctl ipam release --ip=<IP_ADDRESS>
  ```

Replace `<IP_ADDRESS>` with the actual IP address you want to release.

### Optional: Alias `calicoctl`

If you prefer a shorter command, you can create an alias for `calicoctl`:

1. Open your `.bashrc` file:
   ```bash
   nano ~/.bashrc
   ```

2. Add the alias:
   ```bash
   alias calico='calicoctl'
   ```

3. Reload your `.bashrc` file:
   ```bash
   source ~/.bashrc
   ```
