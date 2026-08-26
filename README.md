# Oracle ARM Automation — Always Free Instance Provisioner & DevOps Toolkit

[![Bash](https://img.shields.io/badge/Language-Bash%20%2F%20Shell-blue.svg)](https://www.gnu.org/software/bash/)
[![OCI CLI](https://img.shields.io/badge/API-Oracle%20Cloud%20CLI-red.svg)](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: Production Ready](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

**Oracle ARM Automation** is a sanitized, production-ready DevOps automation toolkit designed to reliably provision Oracle Cloud Infrastructure (OCI) Always Free Ampere ARM (4 OCPU / 24GB RAM) instances and monitor cloud infrastructure availability with systemd timer integration.

---

## 🌟 Key Features

- **Automated Capacity Polling**: Robust OCI CLI wrapper that handles `Out of host capacity` (500) and API rate limits with exponential backoff.
- **Systemd Timer Daemon**: Native Linux service and timer units for persistent background execution without memory leaks or heavy dependencies.
- **Zero-Secret Architecture**: Decoupled environment configuration keeping tenancy OCIDs, compartment IDs, and SSH keys isolated in protected credential stores.
- **Multi-Region & Custom Shape Support**: Configurable OCPUs (1-4), Memory (6GB-24GB), and boot volume sizing up to 200GB Always Free tier.

---

## 📁 Repository Structure

```text
├── LICENSE                             # MIT Open Source License
├── CONTRIBUTING.md                     # Contribution Guidelines
├── README.md                           # Documentation and Setup Guide
├── scripts/
│   └── oracle_arm_provisioner.sh       # Core instance launching and retry engine
└── templates/
    ├── arm-free.service                # Systemd service unit template
    ├── arm-free.timer                  # Systemd timer schedule template
    └── create-arm-free-once.example.sh # CLI manual execution sample
```

---

## 🚀 Quick Start

### 1. Prerequisites
- Linux / macOS host with `oci-cli` installed and configured (`oci setup config`).
- Systemd-compatible Linux distribution for background automation (Ubuntu / Debian / Oracle Linux).

### 2. Configuration
Copy the sample script and configure your compartment, shape, and SSH public key:
```bash
cp templates/create-arm-free-once.example.sh create-instance.sh
chmod +x create-instance.sh
```

### 3. Enable Systemd Background Timer
```bash
sudo cp templates/arm-free.service /etc/systemd/system/
sudo cp templates/arm-free.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now arm-free.timer
```

Check status anytime:
```bash
systemctl list-timers --all | grep arm-free
journalctl -u arm-free.service -n 50 --no-pager
```

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
