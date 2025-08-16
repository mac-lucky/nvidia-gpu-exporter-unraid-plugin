#!/bin/bash

# Script to create a GitHub release for the nvidia_gpu_exporter plugin

VERSION="1.0.0"
REPO_OWNER="mac-lucky"
REPO_NAME="nvidia-gpu-exporter-plugin"
PACKAGE_FILE="packages/nvidia_gpu_exporter-${VERSION}.txz"
MD5_FILE="packages/nvidia_gpu_exporter-${VERSION}.txz.md5"

echo "Creating GitHub release for nvidia_gpu_exporter plugin v${VERSION}"

# Check if package files exist
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: Package file $PACKAGE_FILE not found!"
    echo "Please run ./build.sh first to create the package"
    exit 1
fi

if [ ! -f "$MD5_FILE" ]; then
    echo "Error: MD5 file $MD5_FILE not found!"
    exit 1
fi

echo "Package file: $PACKAGE_FILE"
echo "MD5 file: $MD5_FILE"
echo "MD5 checksum: $(cat $MD5_FILE)"

echo ""
echo "To create the GitHub release, follow these steps:"
echo ""
echo "1. Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/new"
echo "2. Set tag version: ${VERSION}"
echo "3. Set release title: nvidia_gpu_exporter Plugin v${VERSION}"
echo "4. Add release description:"
echo ""
echo "---Release Description---"
cat << 'EOF'
# Nvidia GPU Exporter Plugin v1.0.0

This is the initial release of the Nvidia GPU Exporter plugin for Unraid.

## Features
- Easy installation and management of nvidia_gpu_exporter
- Web-based start/stop/restart controls
- Configurable port, log level, and autostart options
- Comprehensive troubleshooting and diagnostics
- Auto-download of nvidia_gpu_exporter binary
- Based on utkuozdemir/nvidia_gpu_exporter v1.2.8

## Installation
1. In Unraid, go to **Plugins** tab
2. Click **Install Plugin**
3. Enter URL: `https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia_gpu_exporter.plg`
4. Click **Install**

## Requirements
- Unraid 6.9.0 or later
- Nvidia GPU with properly installed drivers
- nvidia-smi working correctly

## Usage
After installation, go to **Tools > Nvidia GPU Exporter** to manage the service.
Metrics will be available at `http://your-server:9835/metrics`

## Troubleshooting
Use the "Run Diagnostics" button in the web interface for automated troubleshooting.
EOF
echo "---End Release Description---"
echo ""
echo "5. Upload the following files as release assets:"
echo "   - $PACKAGE_FILE"
echo "   - $MD5_FILE"
echo ""
echo "6. Click 'Publish release'"
echo ""
echo "Alternative: Use GitHub CLI if installed:"
echo "gh release create ${VERSION} --title \"nvidia_gpu_exporter Plugin v${VERSION}\" --notes-file <(cat << 'EOF'"
echo "Initial release of nvidia_gpu_exporter plugin for Unraid with web-based management and troubleshooting features."
echo "EOF"
echo ") $PACKAGE_FILE $MD5_FILE"
