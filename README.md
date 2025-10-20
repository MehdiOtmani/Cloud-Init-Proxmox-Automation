# 🚀 Proxmox Ubuntu Cloud‑Init Automation

![Proxmox](https://img.shields.io/badge/Proxmox-Automation-orange?logo=proxmox)  
![Cloud‑Init](https://img.shields.io/badge/Cloud--Init-Ubuntu%2024.04-blue?logo=ubuntu)  
![License](https://img.shields.io/badge/License-MIT-green)

---

This repository is a **personal reference** for creating Ubuntu Cloud‑Init VM templates in Proxmox, designed for both **infrastructure automation workflows** (Terraform, Ansible) and quick reproducible setups for labs or production environments.

---

## ✨ Features

- Cloud‑Init integration for automatic user creation & SSH key injection  
- Automatic package installation on first boot (`qemu-guest-agent`, `htop`, etc.)  
- Preconfigured networking (DHCP or static)  
- Reusable VM templates built from official Ubuntu 24.04 cloud images  
- Scripted automation for consistent, reproducible environments

---

## 🧱 Prerequisites
- Proxmox VE server with sufficient storage  
- SSH access to your Proxmox host  
---

## 🧩 Setup Instructions

### 1️⃣ Download Ubuntu Cloud Image


```bash
cd /var/lib/vz/template/iso/
wget https://cloud-images.ubuntu.com/daily/server/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img
mv ubuntu-24.04-server-cloudimg-amd64.img ubuntu-24.04-cloud.img
```bash

### 2️⃣ Create Cloud‑Init Template (VMID 1000)
Clone this repository, make the script executable, and run it:
```bash
chmod +x script.sh
./script.sh
```bash

### What the script does:
- Creates a UEFI + Q35 Cloud‑Init VM (VMID=1000)  
- Injects your SSH key  
- Installs guest tools (`qemu‑guest‑agent`, `htop`)  
- Configures Cloud‑Init with DHCP  
- Converts the VM into a reusable template  


