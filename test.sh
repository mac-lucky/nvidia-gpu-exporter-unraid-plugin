#!/bin/bash

# Test script to verify plugin package structure

PACKAGE_FILE="packages/nvidia_gpu_exporter.txz"
TEST_DIR="/tmp/plugin_test"

echo "Testing NVIDIA GPU Exporter Plugin Package..."

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "ERROR: Package file not found: $PACKAGE_FILE"
    echo "Run ./build.sh first"
    exit 1
fi

# Clean and create test directory
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "Extracting package to test directory..."
ORIGINAL_DIR="$(pwd)"
cd "$TEST_DIR"
tar -xzf "$ORIGINAL_DIR/$PACKAGE_FILE"

echo "Package contents:"
find . -type f | sort

echo ""
echo "Checking required files..."

REQUIRED_FILES=(
    "./usr/local/emhttp/plugins/nvidia_gpu_exporter/nvidia_gpu_exporter.page"
    "./usr/local/emhttp/plugins/nvidia_gpu_exporter/include/exec.php"
    "./usr/local/emhttp/plugins/nvidia_gpu_exporter/include/save_config.php"
    "./usr/local/emhttp/plugins/nvidia_gpu_exporter/include/start.sh"
    "./usr/local/emhttp/plugins/nvidia_gpu_exporter/images/nvidia_gpu_exporter.png"
)

ALL_GOOD=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (MISSING)"
        ALL_GOOD=false
    fi
done

echo ""
echo "Checking file permissions..."
if [ -x "./usr/local/emhttp/plugins/nvidia_gpu_exporter/include/start.sh" ]; then
    echo "✓ start.sh is executable"
else
    echo "✗ start.sh is not executable"
    ALL_GOOD=false
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ "$ALL_GOOD" = true ]; then
    echo ""
    echo "✅ Package test PASSED - All required files present"
    exit 0
else
    echo ""
    echo "❌ Package test FAILED - Missing files or incorrect permissions"
    exit 1
fi
