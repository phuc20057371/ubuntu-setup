#!/bin/bash
set -ex

# 1. Backup Firefox profile
echo "Backup Firefox profile..."
mkdir -p "$HOME/Backup/firefox-profile"
if [ -d "$HOME/snap/firefox/common/.mozilla/firefox" ]; then
    cp -r "$HOME/snap/firefox/common/.mozilla/firefox"/* "$HOME/Backup/firefox-profile/" || true
fi

# 2. Remove all snap packages
echo "Removing snap packages..."
sudo snap remove --purge firefox || true
sudo snap remove --purge snap-store || true
sudo snap remove --purge desktop-security-center || true
sudo snap remove --purge firmware-updater || true
sudo snap remove --purge prompting-client || true
sudo snap remove --purge snapd-desktop-integration || true
sudo snap remove --purge gnome-46-2404 || true
sudo snap remove --purge mesa-2404 || true
sudo snap remove --purge gtk-common-themes || true
sudo snap remove --purge bare || true
sudo snap remove --purge core24 || true
sudo snap remove --purge snapd || true

# 3. Stop and disable snapd services
echo "Stopping and disabling snapd services..."
sudo systemctl stop snapd.service snapd.socket snapd.seeded.service || true
sudo systemctl disable snapd.service snapd.socket snapd.seeded.service || true

# 4. Purge snapd
echo "Purging snapd..."
sudo apt-get purge -y snapd

# 5. Clean directories
echo "Cleaning directories..."
sudo rm -rf /var/cache/snapd/
sudo rm -rf /var/snap/
sudo rm -rf /var/lib/snapd/
rm -rf "$HOME/snap"

# 6. Block snap from being installed again
echo "Creating apt pin to block snapd..."
sudo tee /etc/apt/preferences.d/nosnap.pref <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# 7. Add Mozilla PPA and install Firefox (.deb)
echo "Adding Mozilla PPA..."
sudo install -d /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

sudo tee /etc/apt/preferences.d/mozilla <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

echo "Updating apt and installing Firefox..."
sudo apt-get update
sudo apt-get install -y firefox

# 8. Install Flatpak
echo "Installing Flatpak..."
sudo apt-get install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Installing GNOME tools..."
sudo apt-get install -y gnome-tweaks gnome-shell-extension-manager gnome-software gnome-software-plugin-flatpak

echo "Snap removal and setup complete!"
