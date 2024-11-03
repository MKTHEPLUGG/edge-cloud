#!/bin/bash

exec ../build/compile.sh \
BOARD=rock5a \
BRANCH=current \
RELEASE=noble \
BUILD_MINIMAL=no \
BUILD_DESKTOP=yes \
KERNEL_CONFIGURE=no \
ENABLE_EXTENSIONS="cloud-init"