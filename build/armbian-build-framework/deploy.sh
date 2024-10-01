#!/bin/bash

# This script will bootstrap a build host to create an image
ENV=$(pwd)
# setup required dependencies
sudo apt install git curl zip unzip rsync bc -y

# clone framework
# Check if the directory exists
if [ ! -d "$ENV/build" ]; then
  echo "Directory $ENV/build does not exist. Cloning repository..."
  git clone https://github.com/armbian/build
else
  echo "Directory $ENV/build already exists. Skipping clone."
fi


# pack our cloud-init config into it

# Check if the target directory exists, if not create the parent dirs and copy
if [ ! -d "$ENV/build/userpatches/extensions/cloud-init" ]; then
  echo "Directory $ENV/build/userpatches/extensions/cloud-init does not exist. Creating and copying..."
  mkdir -p "$ENV/build/userpatches/extensions"
  cp -r "$ENV/rock5a/cloud-init" "$ENV/build/userpatches/extensions/"
else
  echo "Directory $ENV/build/userpatches/extensions/cloud-init already exists. Skipping copy."
fi


# next run the compile command with the required env vars, I'll provide the ones for noble rock5a

#./compile.sh \
#BOARD=rock-5a \
#BRANCH=vendor \
#RELEASE=noble \
#BUILD_MINIMAL=no \
#BUILD_DESKTOP=no \
#KERNEL_CONFIGURE=no