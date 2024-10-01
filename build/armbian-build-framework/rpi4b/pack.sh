#!/bin/bash

exec ../build/compile.sh \
BOARD=rpi-4b \
BRANCH=vendor \
RELEASE=noble \
BUILD_MINIMAL=no \
BUILD_DESKTOP=no \
KERNEL_CONFIGURE=no