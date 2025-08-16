#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"
VERSION="1.2.8"
BINARY_URL="https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/nvidia_gpu_exporter_${VERSION}_linux_x86_64.tar.gz"
DOWNLOAD_DIR="/boot/config/plugins/$PLUGIN_NAME/downloads"
INSTALL_DIR="/usr/local/bin"

# Create download directory
mkdir -p "$DOWNLOAD_DIR"

download_binary() {
    echo "Downloading nvidia_gpu_exporter v${VERSION}..."
    
    cd "$DOWNLOAD_DIR"
    
    # Download the tarball
    if wget -q --show-progress --progress=bar:force:noscroll -O "nvidia_gpu_exporter_${VERSION}.tar.gz" "$BINARY_URL"; then
        echo "Download successful"
        
        # Extract the binary
        tar -xzf "nvidia_gpu_exporter_${VERSION}.tar.gz"
        
        if [ -f "nvidia_gpu_exporter" ]; then
            # Copy to system location
            cp "nvidia_gpu_exporter" "$INSTALL_DIR/"
            chmod +x "$INSTALL_DIR/nvidia_gpu_exporter"
            
            echo "nvidia_gpu_exporter installed successfully to $INSTALL_DIR/"
            
            # Clean up
            rm -f "nvidia_gpu_exporter_${VERSION}.tar.gz"
            rm -f "nvidia_gpu_exporter"
            rm -f "README.md"
            rm -f "LICENSE"
            
            return 0
        else
            echo "Error: Binary not found in archive"
            return 1
        fi
    else
        echo "Error: Failed to download nvidia_gpu_exporter"
        return 1
    fi
}

check_binary() {
    if [ -f "$INSTALL_DIR/nvidia_gpu_exporter" ]; then
        echo "nvidia_gpu_exporter is already installed"
        return 0
    else
        echo "nvidia_gpu_exporter is not installed"
        return 1
    fi
}

case "$1" in
    download)
        download_binary
        ;;
    check)
        check_binary
        ;;
    *)
        echo "Usage: $0 {download|check}"
        exit 1
        ;;
esac

exit $?
