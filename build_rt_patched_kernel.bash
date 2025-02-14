#!/bin/bash

set -e  # Exit on error

# Define kernel and patch version
KERNEL_VERSION="6.8"
RT_PATCH_VERSION="6.8-rt8"

# Install required packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y build-essential bc curl debhelper dpkg-dev devscripts fakeroot libssl-dev \
                        libelf-dev bison flex cpio kmod rsync libncurses-dev

# Download kernel source and RT patch
echo "Downloading Linux kernel source and RT patch..."
curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz
curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.sign
curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_VERSION}/older/patch-${RT_PATCH_VERSION}.patch.xz
curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_VERSION}/older/patch-${RT_PATCH_VERSION}.patch.sign

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
cp ../.config linux-${KERNEL_VERSION}

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
scripts/config --enable RT_GROUP_SCHED # docker needs this flag to be true so it can use ande recognise the RT-Kernel

# Generate kernel config
echo "Generating kernel configuration..."
make olddefconfig

# Build the kernel
echo "Building the kernel... This may take some time."
make -j$(nproc) bindeb-pkg

# Install the built kernel
echo "Installing the new kernel..."
sudo apt-get update
# sudo IGNORE_PREEMPT_RT_PRESENCE=1 dpkg -i ../linux-headers-*.deb ../linux-image-*.deb

echo "Real-time kernel installation complete. Reboot your system to use the new kernel."