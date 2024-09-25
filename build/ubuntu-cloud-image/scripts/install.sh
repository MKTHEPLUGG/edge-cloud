#!/bin/bash -eux

# --  Environment Variables  --

# set var to log path
LOG="/var/log/cloud-init.log"

# Detect architecture (arm, x86, etc) used in hostname generation
ARCH=$(uname -m)

# Create vars for hostname generation
source /etc/profile.d/hostname_vars.sh
NEW_HOSTNAME="${ROLE}-${ARCH}-${ENV}-${COUNTER}"

# vars for custom motd message
MOTD_DIR="/etc/update-motd.d"
BACKUP_DIR="/etc/update-motd.d/backup"
CUSTOM_SCRIPT="${MOTD_DIR}/00-mikeshop"

# old check
#echo "==> waiting for cloud-init to finish"
#while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
#    echo 'Waiting for Cloud-Init...'
#    sleep 5
#done

echo -n "==> Waiting for Cloud-Init to finish "
# Spinner for visual feedback
spinner="/-\|"
while cloud-init status --wait &>/dev/null; do
    for i in {0..3}; do
        echo -ne "${spinner:$i:1}" "\r"
        sleep 0.2
    done
done
echo "Cloud-Init finished."


# Configure hostname via variables supplied in the user-data file during the cloud init process.
if [ -n "$NEW_HOSTNAME" ]; then
  echo "new hostname detected: $NEW_HOSTNAME" >> $LOG
  # Set the hostname
  hostnamectl set-hostname "$NEW_HOSTNAME"
  # Update /etc/hosts
  sed -i "s/default-hostname/$NEW_HOSTNAME/g" /etc/hosts
  echo "Hostname set to: $NEW_HOSTNAME" >> $LOG
else
  echo "The variable for hostname generation was empty. Cannot set hostname" >> $LOG
fi



# Create a backup folder
sudo mkdir -p "$BACKUP_DIR"

# Check if there are files in the MOTD directory, excluding the backup directory, and move them
if [ "$(ls -A $MOTD_DIR | grep -v 'backup')" ]; then
    echo "Backing up existing MOTD scripts to $BACKUP_DIR..."
    sudo mv ${MOTD_DIR}/!(backup) "$BACKUP_DIR"/
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
# ---

# Rework from here, add below section





# Propely configure ssh, only accessable with private public keypair
# Ensure SSH key authentication is enabled, and password authentication is disabled
#sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
#sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
#sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
#sudo systemctl reload ssh
#
## Set correct permissions for the .ssh directory and authorized_keys file
#sudo chmod 700 /home/sysadmin/.ssh
#sudo chmod 600 /home/sysadmin/.ssh/authorized_keys

# install ohmyzsh => handeled in initial package setup
# sudo apt install zsh build-essential curl file git -y

# **Figure Out how to properly configure ohmyzsh**
## set as default shell
#sudo chsh -s "$(which zsh)"
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
## install theme
#git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
#
#cat <<EOF | sudo tee ~/.zshrc
## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
## Initialization code that may require console input (password prompts, [y/n]
## confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi
#
## Set theme to Powerlevel10k
#ZSH_THEME="powerlevel10k/powerlevel10k"
#
## Enable Powerlevel10k instant prompt to reduce load time
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#
## Enable plugins (git is commonly used, you can add more as needed)
#plugins=(git history)
#
##source the theme
#source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
#EOF

# get the font = https://github.com/romkatv/powerlevel10k#manual-font-installation

# #apply
#source ~/.zshrc


# post cloud deployment script by MKTHEPLUGG