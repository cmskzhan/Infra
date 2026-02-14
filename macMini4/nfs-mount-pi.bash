#!/bin/bash

# Configuration
PI_IP="192.168.1.201"
# Use readlink -f to get the absolute path in case MOUNT_BASE is a symlink
# This ensures that our 'mount' check matches the actual path shown by the system.
MOUNT_BASE=$(readlink -f "$HOME/pi" 2>/dev/null || echo "$HOME/pi")

echo "Checking NFS shares on $PI_IP..."
echo "Mount base: $MOUNT_BASE"

# Ensure the base mount directory exists
if [ ! -d "$MOUNT_BASE" ]; then
    echo "Creating base directory $MOUNT_BASE..."
    # Using sudo for mkdir because on some systems (like macOS with firmlinks) 
    # the target directory might be in a restricted location.
    sudo mkdir -p "$MOUNT_BASE"
    sudo chown "$(id -u):$(id -g)" "$MOUNT_BASE"
fi

# Get the list of exported directories from the Raspberry Pi
EXPORTS=$(showmount -e "$PI_IP" 2>/dev/null | tail -n +2 | awk '{print $1}')

if [ -z "$EXPORTS" ]; then
    echo "Error: No NFS exports found on $PI_IP or host is unreachable."
    exit 1
fi

for EXPORT in $EXPORTS; do
    FOLDER_NAME=$(basename "$EXPORT")

    # Skip gdrive as it causes the script to hang
    if [ "$FOLDER_NAME" == "gdrive" ]; then
        echo "---"
        echo "Share: $EXPORT"
        echo "Status: Skipping gdrive (known to hang)."
        continue
    fi

    TARGET_DIR="$MOUNT_BASE/$FOLDER_NAME"

    echo "---"
    echo "Share: $EXPORT"
    echo "Target: $TARGET_DIR"

    # Step 1: Check if the target folder exists
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Action: Directory does not exist. Creating with sudo..."
        sudo mkdir -p "$TARGET_DIR"
    fi

    # Step 2: Check if it's already mounted
    # We use 'df' or 'mount' check against the real path.
    # macOS 'mount' output uses real paths (resolving symlinks).
    if mount | grep -qE "on $TARGET_DIR \(|on $(echo $TARGET_DIR | sed 's/\//\\\//g') "; then
        echo "Status: Already mounted. Skipping."
        continue
    fi

    # Step 3: Mount the share
    echo "Status: Not mounted. Attempting to mount..."
    # 'resvport' is required for macOS connecting to Linux NFS
    sudo mount -t nfs -o resvport "$PI_IP:$EXPORT" "$TARGET_DIR"

    if [ $? -eq 0 ]; then
        echo "Result: Successfully mounted $FOLDER_NAME"
    else
        echo "Result: Failed to mount $EXPORT. Check network or export permissions."
    fi
done

echo "---"
echo "NFS Mount process complete."
