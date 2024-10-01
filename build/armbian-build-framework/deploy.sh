#!/bin/bash

# This script will bootstrap a build host to create an image

# setup required dependencies
sudo apt-get install git curl zip unzip rsync bc

# clone framework
git clone https://github.com/armbian/build
cd build

# pack our cloud-init config into it
cp -r ./cloud-init userpatches/extensions/

# next run the compile command with the required env vars, I'll provide the ones for noble rock5a
#./compile.sh \
#BOARD=rock-5a \
#BRANCH=vendor \
#RELEASE=noble \
#BUILD_MINIMAL=no \
#BUILD_DESKTOP=no \
#KERNEL_CONFIGURE=no