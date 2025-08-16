#!/bin/bash
# Test installation script for NVIDIA GPU Exporter Plugin

echo "Testing NVIDIA GPU Exporter Plugin installation..."

# Check if nvidia-smi is available
if ! command -v nvidia-smi &> /dev/null; then
    echo "WARNING: nvidia-smi not found. NVIDIA drivers may not be installed."
else
    echo "NVIDIA drivers detected:"
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
fi

# Download and test the binary
TEMP_DIR="/tmp/nvidia-gpu-exporter-test"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Downloading nvidia_gpu_exporter binary..."
wget -q "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz"

if [ $? -eq 0 ]; then
    echo "Download successful. Extracting..."
    tar -xzf nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz
    chmod +x nvidia_gpu_exporter
    
    echo "Testing binary..."
    ./nvidia_gpu_exporter --version
    
    echo "Starting test server for 10 seconds..."
    ./nvidia_gpu_exporter --web.listen-address=:9836 &
    TEST_PID=$!
    
    sleep 2
    echo "Testing metrics endpoint..."
    curl -s http://localhost:9836/metrics | head -10
    
    echo "Stopping test server..."
    kill $TEST_PID
    
    echo "Cleaning up..."
    cd /
    rm -rf "$TEMP_DIR"
    
    echo "Test completed successfully!"
else
    echo "Failed to download binary. Check your internet connection."
    exit 1
fi
