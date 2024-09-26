#!/bin/bash -eux

# -- Shell Config --

# Redirect stderr to stdout for the entire script, this will get rid of most of the red in my terminal because in Packer,
# the output from the script section (provisioners) is shown in red because it's directed to stderr, which Packer highlights in red.
exec 2>&1
# Enable extended globbing
shopt -s extglob


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
#vars for user config
USER_NAME="sysadmin"  # Replace with the username you want to create
SSH_PUBLIC_KEY="AAAAB3NzaC1yc2EAAAADAQABAAACAQDlP/4lJptihdac/RmC+ZWH/XAh7vCehd6yC6/Zist2D+VlWl6v3p0zRE54Gn3wk5DOymhh4sUTT3zuMIokZMPvwinCo+zR6gD7wU0ATYeRZgX8nn6TLEaMXXYjyCIYZPjUXTs4vYJyHVVaZn6cfATk1DG7VtQBgbveyawp9PpLb0G989gt7wxlAaQx1qVpBywwUB7867DNCmYWJH/1gbsz5jNlKgbbn/og/2RMGL3rrgxJ3BQ9O9GjAYb99AqLdeOSx7TKW1vOL+8JDkPpps2RgTINTexwVZWivyEM/3WeFGyOaZVqSpXSTvhEm8E4AmvuvZNJRxQ0JNZd1io/aMpb5Zo1xV/aunX7voLQZ0V1pWNlBvXBjIVUrT7R7Mwmeub5CT1jr+70qhlKP8z4GA/yZXJNlS88mnTqhwngbXU5jdJdFOlFkCbsR/ofOs2n6q5G+H9HtWs8I0S4iJhXSgqDPknaWUZrGH/HT0ux4KJAjdji7TwA5iJvPeV6SJs4F4hz1enW6UQDRhkIRZi1s4CKWGEAPQwULWq+Lxde6TmPnlLoEJzydNohM8AP7e+EQcGYdjEr7rBmV+ihwpvl1QwF6ToPksShX88kWBAL/AaD1hRE7McAeworojhKOoRQ5/O4P9zuY5BJFxmbNXSwHyMBTmJEGmIRQjI4CKxf1XomjQ=="  # Replace with your actual public key


# -- Main Script Section --
#sudo apt update -y && apt upgrade -y
#sudo apt install git zsh

# wait until cloud-init config has been completed
echo "==> Waiting for Cloud-Init to finish..."
cloud-init status --wait
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


# z-shell setup
# install zi ( package manager for zsh )
export ZI_HOME=/home/ubuntu/.zi
sh -c "$(curl -fsSL https://git.io/get-zi)"
sleep 25
source /home/ubuntu/.zshrc

cat <<EOF | sudo tee -a /home/ubuntu/.zshrc
# Initialize zi
# zi init

# Load plugins
zi load romkatv/powerlevel10k
zi load zsh-users/zsh-syntax-highlighting
zi load zsh-users/zsh-autosuggestions

# update
# zi update
EOF

cat /root/.zshrc

sleep 20

source /home/ubuntu/.zshrc

# -- Security Hardening --

# Disable password auth and root login
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# Don't restart service, should only be applied after provisioning process
# Create the user and set the public key for SSH authentication
echo "==> Creating user and setting up SSH public key..."
sudo useradd -m -s /bin/bash "$USER_NAME"
sudo mkdir -p /home/"$USER_NAME"/.ssh
echo "$SSH_PUBLIC_KEY" | sudo tee /home/"$USER_NAME"/.ssh/authorized_keys
sudo chown -R "$USER_NAME":"$USER_NAME" /home/"$USER_NAME"/.ssh
sudo chmod 700 /home/"$USER_NAME"/.ssh
sudo chmod 600 /home/"$USER_NAME"/.ssh/authorized_keys
# Add the user to the sudo group
echo "==> Adding $USER_NAME to the sudo group..."
sudo usermod -aG sudo "$USER_NAME"

echo "User $USER_NAME created, SSH key added, and user added to sudo group." >> $LOG




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

# first create file with ascii art generator then use this command to convert to login script
# echo '#!/bin/bash'; while IFS= read -r line; do echo "echo '$line'"; done < filename > mymotd.sh
# afterwards copy the content to motd section of script

# post cloud deployment script by MKTHEPLUGG