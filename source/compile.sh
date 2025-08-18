#!/bin/bash

# NVIDIA GPU Exporter Plugin Build Script
# This script downloads the nvidia_gpu_exporter binary and creates an Unraid package

APP_NAME="nvidia_gpu_exporter"
VERSION="1.3.2"
PLUGIN_VERSION="2025.08.17"
DATA_DIR="/tmp/nvidia_gpu_exporter_build"
DOWNLOAD_URL="https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/nvidia_gpu_exporter_${VERSION}_linux_x86_64.tar.gz"

echo "Building NVIDIA GPU Exporter Plugin v${PLUGIN_VERSION} (based on v${VERSION})"

# Create working directories
mkdir -p ${DATA_DIR}
mkdir -p ${DATA_DIR}/${PLUGIN_VERSION}/usr/bin
mkdir -p ${DATA_DIR}/${PLUGIN_VERSION}/usr/local/emhttp/plugins/${APP_NAME}/images

# Download the binary
cd ${DATA_DIR}
echo "Downloading nvidia_gpu_exporter v${VERSION}..."
wget -q -O nvidia_gpu_exporter.tar.gz ${DOWNLOAD_URL}

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to download nvidia_gpu_exporter"
    exit 1
fi

# Extract the binary
echo "Extracting binary..."
tar -xzf nvidia_gpu_exporter.tar.gz
cp nvidia_gpu_exporter ${DATA_DIR}/${PLUGIN_VERSION}/usr/bin/

# Make binary executable
chmod +x ${DATA_DIR}/${PLUGIN_VERSION}/usr/bin/nvidia_gpu_exporter

# Download icon (using NVIDIA icon)
echo "Downloading icon..."
wget -q -O ${DATA_DIR}/${PLUGIN_VERSION}/usr/local/emhttp/plugins/${APP_NAME}/images/${APP_NAME}.png \
    https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia_exporter.png

if [ $? -ne 0 ]; then
    echo "Warning: Failed to download icon, creating placeholder"
    # Create a simple placeholder if icon download fails
    touch ${DATA_DIR}/${PLUGIN_VERSION}/usr/local/emhttp/plugins/${APP_NAME}/images/${APP_NAME}.png
fi

# Set permissions
cd ${DATA_DIR}/${PLUGIN_VERSION}
chmod -R 755 .

# Create Slackware package
echo "Creating Slackware package..."
makepkg -l y -c y ${DATA_DIR}/${APP_NAME}-${PLUGIN_VERSION}.tgz

# Generate MD5 checksum
cd ${DATA_DIR}
md5sum ${APP_NAME}-${PLUGIN_VERSION}.tgz | awk '{print $1}' > ${APP_NAME}-${PLUGIN_VERSION}.tgz.md5

echo "Package created successfully:"
echo "  File: ${DATA_DIR}/${APP_NAME}-${PLUGIN_VERSION}.tgz"
echo "  MD5:  $(cat ${DATA_DIR}/${APP_NAME}-${PLUGIN_VERSION}.tgz.md5)"

# Copy to packages directory if script is run from plugin repo
if [ -d "$(dirname $0)/../packages" ]; then
    cp ${DATA_DIR}/${APP_NAME}-${PLUGIN_VERSION}.tgz $(dirname $0)/../packages/
    cp ${DATA_DIR}/${APP_NAME}-${PLUGIN_VERSION}.tgz.md5 $(dirname $0)/../packages/
    echo "Package copied to packages directory"
fi

echo "Build complete!"
