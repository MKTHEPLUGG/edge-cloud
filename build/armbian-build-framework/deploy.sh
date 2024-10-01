#!/bin/bash

# This script will bootstrap a build host to create an image
ENV=$(pwd)
# setup required dependencies
sudo apt install git curl zip unzip rsync bc -y

# clone framework
git clone https://github.com/armbian/build

# pack our cloud-init config into it

mkdir -p "$ENV"/build/userpatches/extensions
cp -r "$ENV"/rock5a/cloud-init "$ENV"/build/userpatches/extensions/

# next run the compile command with the required env vars, I'll provide the ones for noble rock5a

#./compile.sh \
#BOARD=rock-5a \
#BRANCH=vendor \
#RELEASE=noble \
#BUILD_MINIMAL=no \
#BUILD_DESKTOP=no \
#KERNEL_CONFIGURE=no