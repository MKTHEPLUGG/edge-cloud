#!/bin/bash

# This script will bootstrap a host and deploy the correct armbian image that we want, this needs to go into a pipeline in the future

# setup required dependencies
sudo apt-get install git curl zip unzip rsync bc

# clone framework
git clone https://github.com/armbian/build
cd build

# pack our stuff into it
cp ./cloud-init userpatches/extensions/