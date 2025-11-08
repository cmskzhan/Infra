
# Rclone Setup on Raspberry Pi OS

This guide walks you through installing, configuring, and running `rclone` on Raspberry Pi OS, including mounting a Google Drive remote and setting up a systemd service for persistent mounting.

---


## 📦 Installation

To install `rclone` on Raspberry Pi OS:

```bash
sudo apt update
sudo apt install rclone
sudo apt install fuse
```

Verify Installation
```bash
rclone version
```


## 📦 Configuration
```bash
rclone config
rclone config file
cat ~/.config/rclone/rclone.conf
cat /etc/fuse.conf

rclone mount gdrive-gu214bj: ~/Documents/gdrive --vfs-cache-mode writes
```
-- rclone.conf contains token, can be find in gu214bj gdrive


## 📦 Systemd Configuration
create systemd service file
```bash
cat /etc/systemd/system/rclone-gdrive.service
sudo systemctl enable rclone-gdrive.service
sudo systemctl start rclone-gdrive.service
```

## 🛠️ Troubleshoot
```bash
systemctl status rclone-gdrive.service
journalctl -u rclone-gdrive.service
fusermount -u ~/Documents/gdrive
rclone rc vfs/refresh recursive=true dir=/home/kaizhang/Documents/gdrive
```