#!/bin/bash

# Build script for NVIDIA GPU Exporter Plugin
# This script creates the .txz package for Unraid

PLUGIN_NAME="nvidia_gpu_exporter"
SOURCE_DIR="source"
PACKAGES_DIR="packages"
BUILD_DIR="/tmp/build_${PLUGIN_NAME}"

echo "Building ${PLUGIN_NAME} plugin package..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$PACKAGES_DIR"

# Copy source files to build directory
cp -r "$SOURCE_DIR"/* "$BUILD_DIR/"

# Create the package
cd "$BUILD_DIR"
tar -czf "${PLUGIN_NAME}.txz" ./*

# Move package to packages directory  
ORIGINAL_DIR="$(pwd)"
cd - > /dev/null
mv "$BUILD_DIR/${PLUGIN_NAME}.txz" "${PACKAGES_DIR}/"

# Clean up build directory
rm -rf "$BUILD_DIR"

echo "Package created: ${PACKAGES_DIR}/${PLUGIN_NAME}.txz"
echo "Build complete!"
