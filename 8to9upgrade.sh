#!/bin/bash
#
# Proxmox VE 8 to 9 - Upgrade Preparation Script (Intel-Only Version)
#
# This script automates the preliminary steps for upgrading a PVE 8 node.
# It handles common issues found by 'pve8to9' and updates repository sources.
#
# USAGE:
# 1. Save this script as 'pre-upgrade-intel.sh' on your Proxmox node.
# 2. Make it executable: chmod +x pre-upgrade-intel.sh
# 3. Run it as root: ./pre-upgrade-intel.sh
#
# WARNING: Run this on one node at a time after migrating all VMs off of it.
# This script is provided as-is. Always have backups!

set -e
set -o pipefail

# --- Color Codes for Output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# --- STEP 1: Fully update Proxmox VE 8 ---
info "Updating to the latest Proxmox VE 8 version..."
apt update > /dev/null
apt dist-upgrade -y > /dev/null
info "System is up-to-date on Bookworm."

# --- STEP 2: Fix common 'pve8to9' issues ---
info "Checking for common pre-upgrade issues..."

# Fix: Remove conflicting systemd-boot meta-package
if dpkg -s systemd-boot &>/dev/null; then
    warn "'systemd-boot' package found. Removing to prevent upgrade issues..."
    apt-get remove -y systemd-boot > /dev/null
    info "'systemd-boot' removed successfully."
else
    info "'systemd-boot' is not installed. No action needed."
fi

# --- MODIFIED SECTION: Force Intel Microcode Install ---
info "Ensuring 'non-free-firmware' repository is enabled..."
SOURCES_FILE="/etc/apt/sources.list"
if ! grep -q "non-free-firmware" "$SOURCES_FILE"; then
    warn "'non-free-firmware' not found in sources. Adding it now..."
    sed -i '/bookworm main/ s/$/ non-free-firmware/' "$SOURCES_FILE"
    apt update > /dev/null
fi

info "Installing 'intel-microcode' as requested..."
apt install -y intel-microcode > /dev/null
info "Completed 'intel-microcode' installation."
# --- END MODIFIED SECTION ---

# --- STEP 3: Update repositories to Trixie ---
info "Updating all repository files from 'bookworm' to 'trixie'..."
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/pve-enterprise.list
fi
if [ -f /etc/apt/sources.list.d/pve-no-subscription.list ]; then
    sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/pve-no-subscription.list
fi
info "Repository files updated to 'trixie'."

# --- STEP 4: Refresh package lists from new repositories ---
info "Running 'apt update' with new 'trixie' repositories..."
apt update > /dev/null
info "Package lists for Proxmox VE 9 have been fetched."

# --- Final Instructions ---
echo
echo -e "${GREEN}--------------------------------------------------------"
echo -e "✅ PREPARATION COMPLETE"
echo -e "--------------------------------------------------------${NC}"
echo
echo "This node is now ready for the final upgrade step."
echo "To complete the upgrade to Proxmox VE 9, run the following command:"
echo
echo -e "  ${YELLOW}apt dist-upgrade -y${NC}"
echo
