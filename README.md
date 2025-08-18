# NVIDIA GPU Exporter Plugin for Unraid

A comprehensive Unraid plugin that installs and manages the NVIDIA GPU Exporter service, providing Prometheus-compatible metrics for NVIDIA GPUs.

## Overview

This plugin provides:
- **Automated installation** of the nvidia-gpu-exporter binary
- **Web-based configuration** through Unraid's plugin interface
- **Service management** with start/stop/restart functionality
- **Real-time monitoring** of service status and logs
- **Auto-start capability** on system boot
- **Prometheus metrics** export on configurable port

## Features

### GPU Metrics Exported
- GPU utilization percentage
- Memory usage (used/total)
- GPU temperature
- Power consumption
- Clock speeds (graphics and memory)
- Fan speed
- Performance state
- And many more NVIDIA-SMI metrics

### Web Interface
- Enable/disable service
- Configure port (default: 9835)
- View service status and logs
- Direct link to metrics endpoint
- Real-time status updates

## Requirements

- **Unraid 6.11.0 or later**
- **NVIDIA GPU** with drivers installed
- **nvidia-smi** command available
- **Internet connection** for initial download

## Installation

### Method 1: Community Applications (Recommended)
1. Open Unraid web interface
2. Go to **Apps** tab
3. Search for "NVIDIA GPU Exporter"
4. Click **Install**

### Method 2: Manual Installation
1. Open Unraid web interface
2. Go to **Plugins** tab
3. Enter plugin URL: `https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia_gpu_exporter.plg`
4. Click **Install**

## Configuration

1. After installation, navigate to **Settings** → **NVIDIA GPU Exporter**
2. Configure the following options:
   - **Service**: Enable or disable the exporter
   - **Port**: Set the port for metrics endpoint (default: 9835)
   - **Run As**: User to run the service as (root required for nvidia-smi access)
3. Click **Apply** to save changes

## Usage

### Accessing Metrics
Once the service is running, metrics are available at:
```
http://YOUR_SERVER_IP:9835/metrics
```

### Prometheus Configuration
Add the following to your Prometheus configuration:
```yaml
scrape_configs:
  - job_name: 'nvidia-gpu-exporter'
    static_configs:
      - targets: ['your-unraid-server:9835']
    scrape_interval: 15s
```

### Grafana Integration
1. Import a NVIDIA GPU dashboard (ID: 14574 recommended)
2. Configure Prometheus as data source
3. Enjoy real-time GPU monitoring

## Troubleshooting

### Service Won't Start
1. Check if NVIDIA drivers are installed: `nvidia-smi`
2. Verify port is not in use: `netstat -tlnp | grep 9835`
3. Check service logs in the web interface
4. Ensure GPU is accessible: `ls /dev/nvidia*`

### No Metrics Available
1. Verify service is running: Check status in web interface
2. Test nvidia-smi directly: `nvidia-smi -q`
3. Check firewall settings
4. Verify port accessibility: `curl http://localhost:9835/metrics`

### Permission Issues
1. Service runs as root by default (required for nvidia-smi)
2. Check log file permissions: `/var/log/nvidia-gpu-exporter.log`
3. Verify binary permissions: `/usr/local/bin/nvidia-gpu-exporter`

### Common Error Messages

**"nvidia-smi not found"**
- NVIDIA drivers are not installed or not in PATH
- Install NVIDIA drivers: Unraid NVIDIA plugin

**"Permission denied accessing GPU"**
- Service not running as root
- GPU device permissions issue: `ls -la /dev/nvidia*`

**"Port already in use"**
- Another service is using the configured port
- Change port in configuration or stop conflicting service

## File Locations

### Plugin Files
- Configuration: `/boot/config/plugins/nvidia-gpu-exporter/`
- Web interface: `/usr/local/emhttp/plugins/nvidia-gpu-exporter/`
- Binary: `/usr/local/bin/nvidia-gpu-exporter`

### Log Files
- Service logs: `/var/log/nvidia-gpu-exporter.log`
- Unraid system logs: `/var/log/syslog`

### Configuration File
```bash
/boot/config/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.cfg
```

## Advanced Configuration

### Command Line Options
The exporter supports various command-line options. To customize:
1. Edit the start script: `/usr/local/emhttp/plugins/nvidia-gpu-exporter/scripts/start`
2. Add additional flags to the nvidia-gpu-exporter command

### Available Options
- `--web.listen-address`: Address and port (default: ":9835")
- `--web.telemetry-path`: Metrics endpoint path (default: "/metrics")
- `--nvidia-smi-command`: Custom nvidia-smi command path
- `--query-field-names`: Comma-separated field names to query

### Example Custom Configuration
```bash
/usr/local/bin/nvidia-gpu-exporter \
  --web.listen-address=":9835" \
  --web.telemetry-path="/gpu-metrics" \
  --nvidia-smi-command="/usr/bin/nvidia-smi"
```

## Updating

### Automatic Updates
The plugin will check for updates through Unraid's plugin system.

### Manual Update
1. Go to **Plugins** tab
2. Find "NVIDIA GPU Exporter"
3. Click **Update** if available

### Version Information
- Plugin version: Check in **Plugins** tab
- Exporter version: Currently using v1.3.2
- Supported NVIDIA driver versions: All recent versions

## Uninstallation

1. Go to **Plugins** tab
2. Find "NVIDIA GPU Exporter"
3. Click **Remove**
4. The service will be stopped and all files removed

### Manual Cleanup (if needed)
```bash
# Stop service
pkill -f nvidia-gpu-exporter

# Remove files
rm -rf /boot/config/plugins/nvidia-gpu-exporter
rm -rf /usr/local/emhttp/plugins/nvidia-gpu-exporter
rm -f /usr/local/bin/nvidia-gpu-exporter
rm -f /var/log/nvidia-gpu-exporter.log

# Remove from go script
sed -i '/nvidia-gpu-exporter/d' /boot/config/go
```

## Support

### Getting Help
1. Check Unraid Community Forums
2. Review plugin logs for error messages
3. Test nvidia-smi command manually
4. Verify network connectivity to metrics endpoint

### Reporting Issues
When reporting issues, please include:
1. Unraid version
2. NVIDIA driver version (`nvidia-smi --version`)
3. Plugin version
4. Service logs (`/var/log/nvidia-gpu-exporter.log`)
5. System logs relevant to the issue

### Contributing
Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly on Unraid
4. Submit a pull request

## License

This plugin is released under the MIT License. The nvidia-gpu-exporter binary is developed by [utkuozdemir](https://github.com/utkuozdemir/nvidia_gpu_exporter) and distributed under its own license.

## Acknowledgments

- [utkuozdemir](https://github.com/utkuozdemir) for the excellent nvidia-gpu-exporter
- [ich777](https://github.com/ich777) for the reference plugin structure
- Unraid community for testing and feedback

## Version History

### 2025.01.18
- Initial release
- NVIDIA GPU metrics exporter for Prometheus
- Based on nvidia_gpu_exporter v1.3.2
- Web interface for configuration and control
- Service management with auto-start option
- Configurable port (default 9835)