# Proxmox VE 8 to 9 Upgrade Preparation Script  -  Generated with Gemini, tested by a human.
This was specific to my use case but it should be appropriate for Intel based systems.  

![Proxmox VE](https://img.shields.io/badge/Proxmox%20VE-8%20%E2%9E%9A%209-orange)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

This shell script automates the preliminary steps required to upgrade a **Proxmox VE 8** node to **Proxmox VE 9**. It is designed to run on a single node at a time after all virtual machines and containers have been migrated off of it.

The script specifically targets **Intel-based hardware**, as it unconditionally installs the `intel-microcode` package.

---

## 📜 Description

Upgrading a major Proxmox VE version involves several repetitive but crucial preparation steps. This script automates that process to ensure consistency and reduce the chance of manual error. It prepares the node for the final distribution upgrade, which must still be run manually.

## ✨ Features

The script performs the following actions:

-   ✅ **Updates System:** Ensures the node is running the latest version of Proxmox VE 8.
-   ✅ **Fixes Common Issues:**
    -   Removes the conflicting `systemd-boot` meta-package.
    -   Enables the `non-free-firmware` repository.
    -   Installs the `intel-microcode` package for CPU security and bug fixes.
-   ✅ **Updates Repositories:** Changes all APT repository sources from Debian 12 (`bookworm`) to Debian 13 (`trixie`).
-   ✅ **Refreshes Package Lists:** Runs `apt update` to fetch the new package lists for Proxmox VE 9.

---

## 📋 Prerequisites

Before running this script, please ensure you have:

1.  A running Proxmox VE 8 node with Intel CPUs.
2.  **Complete and tested backups** of all VMs, containers, and the Proxmox host itself.
3.  Migrated all guests (VMs and containers) off the target node.
4.  Root access to the Proxmox node's shell.

---

## 🚀 Usage

Follow these steps on the Proxmox node you intend to upgrade.

### 1. Download the Script

Download the `pre-upgrade-intel.sh` script to your Proxmox node. You can clone the repository or copy the script's contents into a new file.

```bash
# Example using wget
wget https://your-repo-url/pre-upgrade-intel.sh
```

### 2. Make it Executable

Give the script execute permissions.

```bash
chmod +x pre-upgrade-intel.sh
```

### 3. Run the Script

Execute the script as the `root` user.

```bash
./pre-upgrade-intel.sh
```

The script will print informational messages as it completes each step.

---

## ➡️ What Happens Next?

After the script successfully completes, your node is fully prepared for the upgrade. To finalize the process, you must manually run the distribution upgrade command as prompted by the script's output:

```bash
apt dist-upgrade -y
```

This final step will download and install all the packages for Proxmox VE 9. Once it's finished, reboot the node to complete the upgrade.

---

## ⚠️ Disclaimer

This script is provided as-is, without any warranty. The author is not responsible for any data loss or system damage that may occur.

**Always back up your data before performing a major system upgrade.**

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
