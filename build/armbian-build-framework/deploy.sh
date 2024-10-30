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


# Function to handle the copy process and directory creation
copy_cloud_init_files() {
  echo "Creating and copying files to $ENV/build/userpatches/extensions/cloud-init"
  mkdir -p "$ENV/build/userpatches/extensions"
  echo "EXTENSIONS=\"\$EXTENSIONS cloud-init\"" > "$ENV/build/userpatches/config.lib"
  cp -r "$ENV/cloud-init" "$ENV/build/userpatches/extensions/"
  ls -al "$ENV/build/userpatches/extensions/cloud-init"

  # TODO: Improve output to terminal by either modifying the scripts or fetching vars from it
  echo "Configuration that will be applied:"
  cat "$ENV/cloud-init/defaults/meta-data"
  cat "$ENV/cloud-init/defaults/user-data"
}

# Check if a previous config is already applied, if not create the parent dirs and copy
if [ ! -d "$ENV/build/userpatches/extensions/cloud-init" ]; then
  echo "Directory $ENV/build/userpatches/extensions/cloud-init does not exist."
  copy_cloud_init_files
else
  echo "Directory $ENV/build/userpatches/extensions/cloud-init already exists."
  # Ask user if they want to remove the directory and re-copy the files
  read -p "Do you want to remove the existing directory and copy new files? (y/n): " choice
  if [ "$choice" = "y" ]; then
    echo "Removing directory..."
    rm -rf "$ENV/build/userpatches/extensions/cloud-init"
    copy_cloud_init_files
  else
    echo "Skipping the copy."
  fi
fi



# next run the compile command with the required env vars, I'll provide the ones for noble rock5a

#."$ENV/build/compile.sh" \
#BOARD=rock-5a \
#BRANCH=vendor \
#RELEASE=noble \
#BUILD_MINIMAL=no \
#BUILD_DESKTOP=no \
#KERNEL_CONFIGURE=no