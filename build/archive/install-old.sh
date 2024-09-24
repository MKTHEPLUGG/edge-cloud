#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> updating apt cache"
sudo apt-get update -qq

echo "==> upgrade apt packages"
sudo apt-get upgrade -y -qq

echo "==> installing qemu-guest-agent"
sudo apt-get install -y -qq qemu-guest-agent

echo "==> installing docker-ce"

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -qq

sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# --- Package Section --- => moved to cloud init

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

# way to generate name
# Set the prefix to 'node'
#PREFIX="node"

# Generate a random number between 1 and 100
#RANDOM_NUMBER=$((RANDOM % 100 + 1))
# Form the new hostname: "node" + "arch" + random number
#NEW_HOSTNAME="${PREFIX}-${ARCH}-${RANDOM_NUMBER}"

# Ditching above way in favor of setting via user-data