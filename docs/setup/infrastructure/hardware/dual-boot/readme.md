## Dual boot to test out OS

In my continued search to find the best high performance / low power compute I'm looking it using old nuc's or desktops for low powered high performance compute.

for the SBC's I'm going to be mainly using ARMBIAN as it has the best support. For x86 however I have a lot of options. I could use Proxmox to virtualise the host or I could look for a more native linux install on each of the nodes.
Depending on how much compute the node has one of the options might be perfered. Since i'm Using the Ubuntu based armbian I'm going to try out ``Ubuntu Server`` bare metal and via ``Proxmox``

### Setup dual boot

rEFInd is an excellent choice for managing dual-boot setups, especially when you want to boot multiple operating systems on a UEFI-based system. It offers a sleek interface and broad compatibility, including Linux distributions, and can easily handle both Proxmox and Ubuntu Server. Here's how you could approach it:

### Steps to Prepare for Dual Booting Proxmox and Ubuntu Server with rEFInd:

1. **Prepare Disk Partitions**:
   - Use a tool like `GParted` or `fdisk` to partition your server's drive. You will need at least:
     - One partition for Proxmox.
     - One partition for Ubuntu Server.
     - Swap partitions (optional, but useful if your RAM is limited).
     - A shared `/boot/efi` partition if using UEFI.
   - Proxmox might use ZFS, so you may want to create a dedicated ZFS pool or a separate partition for that.

2. **Install Proxmox**:
   - Proxmox installation typically takes over the entire disk if you’re not careful, so during installation, choose "Manual" partitioning to install it on the partition you set aside for it.
   - If using ZFS, select ZFS during installation and ensure it's on the correct partition.

3. **Install Ubuntu Server**:
   - Similarly, during Ubuntu installation, choose manual partitioning and install it in the partition reserved for it.
   - Ensure Ubuntu creates or uses the shared `/boot/efi` partition if you're using UEFI.

4. **Install rEFInd**:
   - Once both OSes are installed, you can install rEFInd to manage the boot process. You can install it from Ubuntu using a package manager like `apt`:
     ```
     sudo apt install refind
     ```
   - Alternatively, you can manually install it from a live USB and configure it to automatically detect all operating systems.

5. **Configure rEFInd**:
   - After installation, rEFInd will automatically detect all installed OSes. If needed, you can customize the `refind.conf` file to organize the boot options better, hide unwanted entries, or add custom boot parameters.
   - rEFInd should detect Proxmox automatically if it's installed correctly, but you can manually add an entry if necessary.

6. **Test the Setup**:
   - Reboot and ensure that rEFInd shows both Proxmox and Ubuntu Server as bootable options. Select each to confirm they boot successfully.

### Considerations:
- **ZFS Booting**: Proxmox might prefer ZFS, so ensure that the rEFInd configuration supports ZFS if you use it.
- **UEFI vs BIOS**: Make sure both OSes are installed with the same boot mode (either UEFI or Legacy/BIOS). Mixing modes can cause boot issues.
- **Backup**: Always back up your data before making changes to partitions or installing new OSes.

Would you like more specific instructions for any of these steps?