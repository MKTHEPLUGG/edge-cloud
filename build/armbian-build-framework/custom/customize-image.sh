#!/bin/bash

# this is a native solution and will run when we are building the image, so in theory we don't need to keep the ssh keys and password predictable, because packer won't need to try to reach the machine after it's booted.
# I'm more a fan of having this config be done by something like packer and only use the framework to pack the cloud-init but let's try the native solution.

# -- Shell Config --
# Enable extended globbing
shopt -s extglob


# --  Environment Variables  --

# set var to log path
LOG="/var/log/cloud-init.log"
# vars for custom motd message
MOTD_DIR="/etc/update-motd.d"
BACKUP_DIR="/etc/update-motd.d/backup"
CUSTOM_SCRIPT="${MOTD_DIR}/00-mikeshop"

# -- Main Script Section --

apt install neofetch -y


# Configure Custom MOTD
# Create a backup folder
sudo mkdir -p "$BACKUP_DIR"
# Check if there are files in the MOTD directory, excluding the backup directory, and move them
if ls -A "$MOTD_DIR" | grep -q -v 'backup'; then
    echo "Backing up existing MOTD scripts to $BACKUP_DIR..."
    sudo mv "$MOTD_DIR"/!(backup) "$BACKUP_DIR"/
else
    echo "No existing MOTD scripts to back up."
fi
# Create a custom neofetch MOTD script
echo "Setting up neofetch as the new MOTD..."
cat <<EOF | sudo tee $CUSTOM_SCRIPT
#!/bin/bash
neofetch
EOF
# Make the new MOTD script executable
sudo chmod +x $CUSTOM_SCRIPT
echo "Neofetch has been set as the MOTD. Backup of old scripts is in $BACKUP_DIR." >> $LOG


