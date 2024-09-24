#!/bin/bash -eux

# --- Environment Variables ---
LOG="/var/log/cloud-init.log"

# Official Mikeshop deploy script for ubuntu-cloud-image-x86
echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 5
done


# --- Package Section --- => move to cloud init

## Set the path to the packages file, this file should be in the script directory
#PACKAGE_LIST="packages.txt"
#
## update the system
#echo "==> updating apt cache" >> $LOG
#sudo apt-get update -qq
#
## upgrade the system
#echo "==> upgrade apt packages" >> $LOG
#sudo apt-get upgrade -y -qq
#
## Check if the package list file exists & execute install commands
#if [ -f "$PACKAGE_LIST" ]; then
#    echo "==> installing apt packages from $PACKAGE_LIST" >> $LOG
#    xargs -a "$PACKAGE_LIST" sudo apt-get install -y -qq
#else
#    echo "Package list file not found: $PACKAGE_LIST" >> $LOG
#    exit 1
#fi


# ---

# Rework from here, add below section

# Set the prefix to 'node'
PREFIX="node"

# Detect architecture (arm, x86, etc.)
ARCH=$(uname -m)

# Generate a random number between 1 and 100
#RANDOM_NUMBER=$((RANDOM % 100 + 1))
# Form the new hostname: "node" + "arch" + random number
#NEW_HOSTNAME="${PREFIX}-${ARCH}-${RANDOM_NUMBER}"

# Ditching above way in favor of setting via user-data
source /etc/profile.d/hostname_vars.sh
NEW_HOSTNAME="${ROLE}-${ARCH}-${ENV}-${COUNTER}"

# Set the hostname
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hosts
sed -i "s/default-hostname/$NEW_HOSTNAME/g" /etc/hosts
echo "Hostname set to: $NEW_HOSTNAME"

## Configure correct keyboard layout
#sudo sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard
#sudo setupcon

## set date and time
#sudo timedatectl set-timezone Europe/Brussels
#date

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


echo "Cloud-init configuration complete." > /var/log/cloud-init-done.log