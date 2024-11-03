#!/bin/bash

exec ../build/compile.sh \
BOARD=rock-5a \
BRANCH=current \
RELEASE=noble \
BUILD_MINIMAL=no \
BUILD_DESKTOP=no \
KERNEL_CONFIGURE=no \
ENABLE_EXTENSIONS="cloud-init"