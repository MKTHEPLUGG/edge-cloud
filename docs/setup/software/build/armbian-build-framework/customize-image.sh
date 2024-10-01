#!/bin/bash

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

# wait until cloud-init config has been completed
echo "==> Waiting for Cloud-Init to finish..."
cloud-init status --wait
echo "Cloud-Init finished."


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


