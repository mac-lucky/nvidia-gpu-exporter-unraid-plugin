# NVIDIA GPU Exporter Plugin - File Overview

This document explains the purpose of each file in the plugin.

## Core Plugin Files

### `nvidia-gpu-exporter.plg`

- **Main plugin file** that Unraid uses for installation
- Contains XML structure with entity definitions for versioning
- Includes download URL, installation scripts, and cleanup procedures
- Embeds all web interface files inline using CDATA sections
- Handles binary download, extraction, and service setup

### `NvidiaGpuExporter.page`

- **Web interface page** that appears in Unraid's Settings menu
- Provides start/stop/restart buttons for the service
- Shows real-time status with auto-refresh every 5 seconds
- Contains CSS styling for status indicators and buttons
- Uses AJAX for seamless service control without page reload

### `rc.nvidia-gpu-exporter`

- **System service control script** installed to `/etc/rc.d/`
- Handles start, stop, restart, and status operations
- Manages PID file for process tracking
- Provides proper process cleanup and error handling
- Standard Unix init script format

## Web Interface Support Files

### `include/status.php`

- **Status check script** called via AJAX
- Checks if service is running by examining PID file
- Returns formatted HTML with colored status indicators
- Cleans up stale PID files automatically

### `include/service.php`

- **Service control handler** for web interface actions
- Processes start/stop/restart commands from buttons
- Validates input and executes appropriate system commands
- Returns command output for user feedback

## Assets and Documentation

### `nvidia-gpu-exporter.svg`

- **Plugin icon** displayed in Unraid interface
- SVG format for scalability and small file size
- NVIDIA-themed green color scheme with GPU chip design
- Referenced directly from GitHub in the plugin file

### `README.md`

- **Complete documentation** for users and developers
- Installation instructions and usage guide
- Troubleshooting section and technical details
- Prometheus integration examples

### `test-install.sh`

- **Testing script** for verifying plugin functionality
- Downloads and tests the binary independently
- Checks for NVIDIA drivers and dependencies
- Useful for debugging before full plugin installation

## File Relationships

```
nvidia-gpu-exporter.plg (main)
├── Downloads binary from GitHub releases
├── Installs rc.nvidia-gpu-exporter to /etc/rc.d/
├── Creates web interface files in /usr/local/emhttp/plugins/
│   ├── NvidiaGpuExporter.page
│   └── include/
│       ├── status.php
│       └── service.php
└── References nvidia-gpu-exporter.svg for icon

User interactions:
1. Install plugin via Unraid plugin manager
2. Access Settings > NVIDIA GPU Exporter
3. Use start/stop/restart buttons
4. View real-time status updates
5. Access metrics at http://server:9835/metrics
```

## Installation Flow

1. User installs plugin via URL in Unraid
2. Plugin downloads nvidia_gpu_exporter binary
3. System creates service control script
4. Web interface files are installed
5. User can control service via web interface
6. Service exposes metrics on port 9835

## Key Features

- **Simple**: Single binary, minimal dependencies
- **Integrated**: Native Unraid web interface
- **Reliable**: Proper process management and cleanup
- **Monitored**: Real-time status updates
- **Standard**: Follows Unraid plugin conventions
