To set up a QEMU/KVM testing environment on your Ubuntu Server without a GUI, we can leverage the GPU for hardware acceleration if needed for visual output later. Here’s a step-by-step guide to get QEMU and KVM running and create virtual machines (VMs) for testing your Cloud-init configuration:

### Step 1: Install QEMU, KVM, and Required Tools

On your Ubuntu Server, you need to install QEMU, KVM, and related tools to manage virtual machines without a graphical interface.

```bash
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager genisoimage guestfs-tools
```

Here’s what each component does:
- **qemu-kvm**: The hypervisor to run virtual machines.
- **libvirt-daemon-system**: Manages virtual machines using KVM.
- **libvirt-clients**: Provides command-line tools to manage virtual machines.
- **bridge-utils**: Allows the VM to access your network.
- **virtinst**: Command-line utilities for creating virtual machines.
- **virt-manager**: A GUI for managing virtual machines, though it won’t be needed for now.

### Step 2: Enable and Start libvirt

Make sure the `libvirtd` service is enabled and running:

```bash
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

To verify that KVM is installed and running properly:

```bash
sudo virsh list --all
```

To operate the vm some example commands

````shell
sudo virsh start <vm-name>           # start
sudo virsh shutdown <vm-name>        # graceful shutdown
sudo virsh destroy <vm-name>         # forced shutdown
sudo virsh console <vm-name>         # access the console
sudo virsh undefine <vm-name>        # fully remove VM
````

This will display an empty list if there are no VMs running, but it confirms the setup is working.

### Step 3: Create a Bridge Network for VMs

For the VMs to communicate with the outside network (and for easier SSH access), it’s best to set up a bridged network. 

1. Open the network configuration file:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

2. Add a bridge interface. Replace `eth0` with your network interface:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s31f6:      # be sure to specify your actual wan interface
      dhcp4: no     # Disable DHCP on the physical interface
  bridges:
    br0:
      interfaces: [enp0s31f6] # be sure to specify your actual wan interface
      dhcp4: yes    # Enable DHCP on the bridge
      parameters:
        stp: false  # Disable Spanning Tree Protocol for faster convergence
        forward-delay: 0  # Optimize for faster network performance
      optional: true
```

3. Set proper permissions and apply the changes:

```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

This sets up a bridge that your VMs can use to access the network.

### Step 4: Download an Ubuntu Cloud Image

To test Cloud-init, you can use an Ubuntu Cloud image, which is pre-configured for cloud environments and already optimized for Cloud-init.

1. Download the latest Ubuntu Server Cloud image:

```bash
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

# in some cases where you want direct access to the console you might want to set a root password
virt-customize -a /var/lib/libvirt/images/focal-server-cloudimg-amd64.img --root-password password:<pass>

```



2. Move the image to the `/var/lib/libvirt/images/` directory for organization:

```bash
sudo mv focal-server-cloudimg-amd64.img /var/lib/libvirt/images/
```

### Step 5: Create a Cloud-init ISO

Cloud-init requires an ISO image to pass user-data. We’ll create a `user-data` and `meta-data` file and package them into an ISO.

1. Create the user-data file (your Cloud-init config):

```bash
nano user-data
```

Paste your Cloud-init configuration in this file (the one you've prepared earlier).

2. Create the meta-data file (OPTIONAL):

```bash
nano meta-data
```

Add the following contents (you can customize the instance-id and hostname):

```yaml
instance-id: $(uuidgen)
local-hostname: default-hostname
```

3. Create an ISO image with `user-data` and `meta-data`:

```bash
genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data
```

4. Move the iso to the proper location and set permissions
```bash
sudo mv /home/sysadmin/seed.iso /var/lib/libvirt/images/
sudo chmod 644 /var/lib/libvirt/images/seed.iso

```

This will create an ISO file (`seed.iso`) that Cloud-init can read when the VM is started.

### Step 6: Create and Launch the VM

Now that you have both the cloud image and Cloud-init ISO, you can create and launch the VM using `virt-install`.

```bash
sudo virt-install \
  --name ubuntu-cloud-vm \
  --ram 4048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/focal-server-cloudimg-amd64.img,format=qcow2 \
  --disk path=/var/lib/libvirt/images/seed.iso,device=cdrom \
  --import \
  --os-variant ubuntu24.04 \
  --network bridge=br0 \
  --graphics none \
  --noautoconsole
```

Here’s a breakdown of what this command does:
- **--name**: Specifies the VM name.
- **--ram**: Allocates 2 GB of RAM for the VM.
- **--vcpus**: Allocates 2 virtual CPUs for the VM.
- **--disk**: Defines the path to the Ubuntu cloud image and the Cloud-init ISO.
- **--import**: Skips installation and directly boots the image.
- **--os-variant**: Specifies the OS variant (use `osinfo-query os` to see more variants).
- **--network**: Connects the VM to the bridged network.
- **--graphics none**: Disables graphical output (we’re running this on a server without a GUI).
- **--noautoconsole**: Prevents automatic console attachment.

### Step 7: Access the VM via SSH

Once the VM is running, find its IP address to access it via SSH:

```bash
sudo virsh domifaddr ubuntu-cloud-vm
```

This should show you the IP address assigned to the VM. You can then SSH into the VM:

```bash
ssh sysadmin@<vm-ip-address> -i <path-to-private-key>
```

Replace `<vm-ip-address>` with the IP address of the VM and `<path-to-private-key>` with the path to the private key for the `sysadmin` user.

### Optional: GPU Passthrough for Visual Output

Since you mentioned that you have a GPU, you can enable GPU passthrough for the VM if you want to provide visual output.

1. **Enable IOMMU**: Add the following line to `/etc/default/grub`:

```bash
GRUB_CMDLINE_LINUX="intel_iommu=on"  # For Intel
# or
GRUB_CMDLINE_LINUX="amd_iommu=on"    # For AMD
```

Then update Grub:

```bash
sudo update-grub
```

2. **Configure GPU Passthrough**: You would need to modify the VM XML configuration to pass through the GPU device. You can do this by editing the XML of the VM:

```bash
sudo virsh edit ubuntu-cloud-vm
```

## Troubleshooting

### 1. **Run `libguestfs-test-tool`**
First, run the `libguestfs-test-tool` to diagnose any issues with `libguestfs`. This tool checks whether your `libguestfs` environment is set up correctly.

```bash
sudo libguestfs-test-tool
```

This command performs a series of tests. If any errors occur, they should give you insight into what’s wrong with your `libguestfs` setup.

### 2. **Enable Debugging for `virt-customize`**
You can gather more detailed information by running `virt-customize` with debugging enabled:

```bash
export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1
sudo virt-customize -a /var/lib/libvirt/images/focal-server-cloudimg-amd64.img --root-password password:test
```

This will provide more detailed output and help identify where the issue lies.

### 3. **Check KVM and QEMU Setup**
`virt-customize` relies on KVM/QEMU to create a temporary VM to modify the disk. Ensure that KVM and QEMU are working correctly.

1. Check if KVM is enabled:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

You should see a non-zero result (indicating KVM support). If it’s zero, you need to enable virtualization in your BIOS.

2. Ensure that the `kvm` modules are loaded:

```bash
lsmod | grep kvm
```

You should see `kvm_intel` (for Intel) or `kvm_amd` (for AMD) listed. If not, load the appropriate module:

```bash
sudo modprobe kvm_intel  # For Intel
sudo modprobe kvm_amd    # For AMD
```

### 4. **Check the Hypervisor’s Access Permissions**
Make sure the `libvirt-qemu` user or your system’s QEMU process has the necessary permissions to access the image:

```bash
sudo chown qemu:qemu /var/lib/libvirt/images/focal-server-cloudimg-amd64.img
sudo chmod 644 /var/lib/libvirt/images/focal-server-cloudimg-amd64.img
```

### 5. **Try Running in a Direct Virtualization Mode**
You can force `virt-customize` to use a specific backend, such as `direct` mode, which uses the system hypervisor (KVM):

```bash
export LIBGUESTFS_BACKEND=direct
```

This can help avoid the use of the `libguestfs` appliance, which sometimes causes issues in more restricted environments.

### 6. **Increase the Memory Allocated to `libguestfs` Appliance**
If the appliance is running out of memory, you can try increasing the memory allocated to it. You can do this by setting the `LIBGUESTFS_MEMSIZE` environment variable (e.g., 1024 MB):

```bash
export LIBGUESTFS_MEMSIZE=1024
```



