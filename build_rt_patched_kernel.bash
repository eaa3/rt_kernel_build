#!/bin/bash

set -e  # Exit on error

# Define kernel and patch version
BASE_KERNEL_VERSION="6.1"
KERNEL_VERSION="${BASE_KERNEL_VERSION}.99"
RT_PATCH_VERSION="${BASE_KERNEL_VERSION}.99-rt36"


# Install required packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y build-essential bc curl debhelper dpkg-dev devscripts fakeroot libssl-dev \
                        libelf-dev bison flex cpio kmod rsync libncurses-dev

# Download kernel source and RT patch
echo "Downloading Linux kernel source and RT patch..."
curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz
curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.sign
curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/${BASE_KERNEL_VERSION}/older/patch-${RT_PATCH_VERSION}.patch.xz
curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/${BASE_KERNEL_VERSION}/older/patch-${RT_PATCH_VERSION}.patch.sign

# Extract files
echo "Extracting kernel source and RT patch..."
xz -d *.xz
tar xf linux-${KERNEL_VERSION}.tar

# Enter kernel source directory
cd linux-${KERNEL_VERSION}

# Apply RT patch
echo "Applying RT patch..."
patch -p1 < ../patch-${RT_PATCH_VERSION}.patch

# Copy current kernel config
# cp -v /boot/config-$(uname -r) .config

# Copy pre-defined kernel config
cp ../.config .

# Disable unnecessary debugging options
scripts/config --disable DEBUG_INFO
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --disable DEBUG_KERNEL
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_LIST

# Configure preemption options
scripts/config --disable PREEMPT_NONE
scripts/config --disable PREEMPT_VOLUNTARY
scripts/config --disable PREEMPT
scripts/config --enable PREEMPT_RT
scripts/config --disable CONFIG_NO_HZ_IDLE
scripts/config --enable CONFIG_NO_HZ_FULL
scripts/config --disable CONFIG_HZ_250
scripts/config --enable CONFIG_HZ_1000

scripts/config --disable RT_GROUP_SCHED 

# Generate kernel config
echo "Generating kernel configuration..."
make olddefconfig

# Build the kernel
echo "Building the kernel... This may take some time."
make -j$(nproc) bindeb-pkg