# Install the built kernel
echo "Installing the new kernel..."
sudo apt-get update
sudo IGNORE_PREEMPT_RT_PRESENCE=1 dpkg -i ../linux-headers-*.deb ../linux-image-*.deb

echo "Real-time kernel installation complete. Reboot your system to use the new kernel."