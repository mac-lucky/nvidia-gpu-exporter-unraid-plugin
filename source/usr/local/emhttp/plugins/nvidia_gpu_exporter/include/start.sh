#!/bin/bash

# NVIDIA GPU Exporter startup script
# This script is called when the system starts or the plugin is installed

PLUGIN_NAME="nvidia_gpu_exporter"
BINARY_PATH="/usr/local/bin/nvidia_gpu_exporter"
PID_FILE="/var/run/nvidia_gpu_exporter/nvidia_gpu_exporter.pid"
CONFIG_FILE="/boot/config/plugins/nvidia_gpu_exporter/nvidia_gpu_exporter.cfg"
LOG_FILE="/var/log/nvidia_gpu_exporter/nvidia_gpu_exporter.log"

# Create necessary directories
mkdir -p /var/run/nvidia_gpu_exporter
mkdir -p /var/log/nvidia_gpu_exporter
mkdir -p /boot/config/plugins/nvidia_gpu_exporter

# Set proper permissions
chmod 755 /var/run/nvidia_gpu_exporter
chmod 755 /var/log/nvidia_gpu_exporter
chmod 755 /boot/config/plugins/nvidia_gpu_exporter

# Check if we should auto-start (only if binary exists and was previously running)
if [ -f "$BINARY_PATH" ] && [ -f "$CONFIG_FILE" ]; then
    # Load configuration
    source "$CONFIG_FILE" 2>/dev/null || true
    
    # Set defaults if not configured
    listen_address=${listen_address:-"0.0.0.0:9835"}
    metrics_path=${metrics_path:-"/metrics"}
    log_level=${log_level:-"info"}
    
    # Start the service
    echo "Starting NVIDIA GPU Exporter..."
    "$BINARY_PATH" --web.listen-address="$listen_address" --web.telemetry-path="$metrics_path" --log.level="$log_level" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    
    echo "NVIDIA GPU Exporter started with PID $(cat $PID_FILE)"
fi
