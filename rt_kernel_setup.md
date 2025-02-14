# Instructions for Setting Up a Real-Time Kernel on Ubuntu 22.04

This guide outlines the steps to set up a real-time kernel on Ubuntu 22.04 by building a custom kernel from source, applying the real-time patch, and installing it. Follow the instructions below carefully.

## Prerequisites

Before you begin, make sure your system is updated and that you have the necessary tools installed.

### Install Required Packages

1. **Install essential build tools and dependencies:**

   Run the following command to install build-essential packages and other dependencies needed for compiling the kernel:
   
   ```bash
   sudo apt-get install build-essential bc curl debhelper dpkg-dev devscripts fakeroot libssl-dev libelf-dev bison flex cpio kmod rsync libncurses-dev
   ```

## Step-by-Step Kernel Compilation and Real-Time Patch Application

### Step 1: Download the Kernel Source and Patch

2. **Download the Linux Kernel Source:**
   
   Use `curl` to download the Linux 6.8 kernel source:
   
   ```bash
   curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.8.tar.xz
   ```

3. **Download the Kernel Source Signature:**
   
   This file verifies the integrity of the kernel source. Download it with:
   
   ```bash
   curl -LO https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.8.tar.sign
   ```

4. **Download the Real-Time Patch for Kernel 6.8:**
   
   Download the real-time patch specifically for this kernel version:
   
   ```bash
   curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/6.8/older/patch-6.8-rt8.patch.xz
   ```

5. **Download the Real-Time Patch Signature:**
   
   Download the signature for the real-time patch:
   
   ```bash
   curl -LO https://www.kernel.org/pub/linux/kernel/projects/rt/6.8/older/patch-6.8-rt8.patch.sign
   ```

### Step 2: Extract the Files

6. **Extract the `.xz` Files:**
   
   Use the `xz` command to decompress the `.xz` files:
   
   ```bash
   xz -d *.xz
   ```

7. **Extract the Kernel Source:**
   
   Now extract the kernel source tarball:
   
   ```bash
   tar xf linux-*.tar
   ```

### Step 3: Apply the Real-Time Patch

8. **Navigate to the Kernel Source Directory:**
   
   Enter the extracted kernel source directory:
   
   ```bash
   cd linux-*/
   ```

9. **Apply the Real-Time Patch:**
   
   Apply the real-time patch to the kernel source:
   
   ```bash
   patch -p1 < ../patch-*.patch
   ```

### Step 4: Configure the Kernel

10. **Copy the Current Kernel Configuration:**
    
    Copy the configuration of your currently running kernel to the new source tree:
    
    ```bash
    cp -v /boot/config-$(uname -r) .config
    ```

11. **Disable Unnecessary Debugging Options:**

    Run the following commands to disable various debugging options in the kernel configuration:
    
    ```bash
    scripts/config --disable DEBUG_INFO
    scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
    scripts/config --disable DEBUG_KERNEL
    scripts/config --disable SYSTEM_TRUSTED_KEYS
    scripts/config --disable SYSTEM_REVOCATION_LIST
    ```

12. **Disable Preemption Options (Except Real-Time):**

    Disable certain preemption options that may interfere with real-time performance:
    
    ```bash
    scripts/config --disable PREEMPT_NONE
    scripts/config --disable PREEMPT_VOLUNTARY
    scripts/config --disable PREEMPT
    scripts/config --enable PREEMPT_RT
    scripts/config --enable RT_GROUP_SCHED
    ```

13. **Generate a New Kernel Configuration:**

    Run the following command to generate a new configuration based on your system's configuration:
    
    ```bash
    make olddefconfig
    ```

### Step 5: Build the Kernel and Packages

14. **Build the Kernel and Packages:**
    
    Use `make` to compile the kernel and its packages. The `-j$(nproc)` flag tells `make` to use all available CPU cores for faster compilation:
    
    ```bash
    make -j$(nproc) bindeb-pkg
    ```

### Step 6: Install the Kernel

15. **Update Package Lists:**
    
    Run the following command to update your local package list:
    
    ```bash
    sudo apt-get update
    ```

16. **Install the Kernel Packages:**
    
    Install the `.deb` packages using `dpkg`. The `IGNORE_PREEMPT_RT_PRESENCE=1` flag ensures that the real-time patch is applied correctly:
    
    ```bash
    sudo IGNORE_PREEMPT_RT_PRESENCE=1 dpkg -i ../linux-headers-*.deb ../linux-image-*.deb
    ```

17. **Reboot the System:**
    
    Reboot your system to apply the new kernel:
    
    ```bash
    sudo reboot now
    ```
    
    Choose the new kernel at startup in the grub menu.

### Step 7: Add User to the Real-Time Group

18. **Create the Real-Time Group:**
    
    Create a `realtime` group on your system:
    
    ```bash
    sudo addgroup realtime
    ```

19. **Add Your User to the Real-Time Group:**
    
    Add your user to the `realtime` group to grant it the necessary permissions:
    
    ```bash
    sudo usermod -a -G realtime $(whoami)
    ```

## Conclusion

Your system is now configured with a real-time kernel. You can verify that the new kernel is running using:

```bash
uname -r
```

This should show the new kernel version. You can also check the real-time patch by verifying the kernel configuration.
