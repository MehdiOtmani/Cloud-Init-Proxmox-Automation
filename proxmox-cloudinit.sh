#!/bin/bash
# ==============================================
# Ubuntu 24.04 Cloud-Init Template Automation for Proxmox
# Author: EL Mehdi EL Otmani
# Description:
#   Automates creation of an Ubuntu Cloud-Init template (VMID=1000)
# ==============================================

set -e  # exit on error

# ----------------------------
# Variables
# ----------------------------
VMID=1000
STORAGE=local-zfs     # change if you use local-zfs
VM_NAME="ubuntu-2404-cloudinit-template"
IMAGE_URL="https://cloud-images.ubuntu.com/daily/server/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
IMAGE_PATH="/var/lib/vz/template/iso/$(basename ${IMAGE_URL})"

CI_USER="ubuntu"
CI_PASSWORD="ubuntu"  # demo only — prefer SSH auth in real use

# ----------------------------
# Prepare directories
# ----------------------------
mkdir -p /var/lib/vz/template/iso
mkdir -p /var/lib/vz/snippets

# ----------------------------
# Use your provided SSH public key (injected into template)
# ----------------------------
# <-- your key copied here:
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwd60MrzFYacqjIgMXAEtDa+0mqqFO2E6ZpyGBGc/al elmehdielotmani1@gmail.com" > /root/ssh.pub
chmod 644 /root/ssh.pub

# ----------------------------
# Download Ubuntu image if missing
# ----------------------------
if [ ! -f "${IMAGE_PATH}" ]; then
  echo "Downloading Ubuntu 24.04 Cloud Image..."
  wget -P /var/lib/vz/template/iso/ "${IMAGE_URL}"
else
  echo "✅ Image already exists at ${IMAGE_PATH}"
fi

# Debug output
set -x

# Destroy existing VM (if present) to avoid conflicts
qm destroy $VMID 2>/dev/null || true

# ----------------------------
# Create VM (hardware)
# ----------------------------
qm create ${VMID} \
  --name "${VM_NAME}" \
  --ostype l26 \
  --memory 2048 \
  --cores 2 \
  --agent 1 \
  --bios ovmf \
  --machine q35 \
  --efidisk0 ${STORAGE}:0,pre-enrolled-keys=0 \
  --cpu host \
  --socket 1 \
  --vga serial0 \
  --serial0 socket \
  --net0 virtio,bridge=vmbr0

# ----------------------------
# Import disk image to storage
# ----------------------------
qm importdisk ${VMID} "${IMAGE_PATH}" ${STORAGE}

# Attach imported disk as VirtIO on SCSI controller and enable discard
qm set ${VMID} --scsihw virtio-scsi-pci \
               --virtio0 ${STORAGE}:vm-${VMID}-disk-1,discard=on

# Resize (optional)
qm resize ${VMID} virtio0 +8G

# Boot order
qm set ${VMID} --boot order=virtio0

# Attach Cloud-Init drive
qm set ${VMID} --scsi1 ${STORAGE}:cloudinit

# ----------------------------
# Create Cloud-Init snippet
# ----------------------------
cat << 'EOF' > /var/lib/vz/snippets/ubuntu.yaml
#cloud-config
runcmd:
  - apt update
  - apt install -y qemu-guest-agent htop
  - systemctl enable ssh
  - reboot
EOF

# ----------------------------
# Apply Cloud-Init and user settings
# ----------------------------
qm set ${VMID} --cicustom "vendor=local:snippets/ubuntu.yaml"
qm set ${VMID} --tags ubuntu-template,cloudinit
qm set ${VMID} --ciuser ${CI_USER} --cipassword ${CI_PASSWORD}
qm set ${VMID} --sshkeys /root/ssh.pub
qm set ${VMID} --ipconfig0 ip=dhcp

# Convert to template
qm template ${VMID}

set +x
echo "✅ Template '${VM_NAME}' (VMID: ${VMID}) created successfully!"
echo "Tip: remove or rotate the CI_PASSWORD if you won't use it; SSH key is installed for secure access."
