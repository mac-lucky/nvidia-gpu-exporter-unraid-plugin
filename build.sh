#!/bin/bash

# Simple build script for nvidia_gpu_exporter plugin
# This creates the plugin package without needing Slackware tools

PLUGIN_NAME="nvidia_gpu_exporter"
VERSION="1.0.0"
SOURCE_DIR="/Users/maclucky/Documents/GitHub/nvidia-gpu-exporter-plugin/source"
BUILD_DIR="/tmp/nvidia_gpu_exporter_build_$$"
PACKAGES_DIR="/Users/maclucky/Documents/GitHub/nvidia-gpu-exporter-plugin/packages"

echo "Building $PLUGIN_NAME plugin package..."

# Create build directory
mkdir -p "$BUILD_DIR"
mkdir -p "$PACKAGES_DIR"

# Copy source files
cp -R "$SOURCE_DIR"/* "$BUILD_DIR/"

# Create the package structure for Unraid
cd "$BUILD_DIR"

# Create a tar.xz package (Unraid plugin format)
tar -czf "$PACKAGES_DIR/${PLUGIN_NAME}-${VERSION}.txz" usr/

# Generate MD5 checksum
cd "$PACKAGES_DIR"
md5sum "${PLUGIN_NAME}-${VERSION}.txz" | awk '{print $1}' > "${PLUGIN_NAME}-${VERSION}.txz.md5"

echo "Package created: $PACKAGES_DIR/${PLUGIN_NAME}-${VERSION}.txz"
echo "MD5: $(cat ${PLUGIN_NAME}-${VERSION}.txz.md5)"

# Clean up
rm -rf "$BUILD_DIR"

echo "Build complete!"
