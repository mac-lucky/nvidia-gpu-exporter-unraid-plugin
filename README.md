# NVIDIA GPU Exporter Plugin for Unraid

This plugin provides easy installation and management of the NVIDIA GPU Exporter for monitoring NVIDIA GPUs on Unraid systems.

## Features

- **One-click installation** of nvidia_gpu_exporter binary
- **Web interface** with start/stop/restart controls
- **Real-time status monitoring**
- **Automatic service management**
- **Prometheus-compatible metrics** exposed on port 9835

## Installation

1. Go to **Settings > Plugin**
2. Enter the plugin URL: `https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia-gpu-exporter.plg`
3. Click **Install**

## Usage

After installation:

1. Go to **Settings > NVIDIA GPU Exporter**
2. Click **Start** to begin monitoring
3. Access metrics at `http://[YOUR_UNRAID_IP]:9835/metrics`

## Service Control

The plugin provides three main controls:

- **Start**: Starts the nvidia_gpu_exporter service
- **Stop**: Stops the service (kills the process)
- **Restart**: Stops and then starts the service

## Monitoring Integration

### Prometheus Configuration

Add this to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "nvidia-gpu"
    static_configs:
      - targets: ["unraid-server:9835"]
```

### Grafana Dashboard

The exporter provides metrics that can be visualized in Grafana:

- GPU utilization percentage
- Memory usage and availability
- GPU temperature
- Power consumption
- Fan speeds

## Technical Details

- **Binary Source**: [utkuozdemir/nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter)
- **Default Port**: 9835
- **Log File**: `/var/log/nvidia-gpu-exporter.log`
- **PID File**: `/var/run/nvidia-gpu-exporter.pid`
- **Binary Location**: `/usr/local/bin/nvidia_gpu_exporter`

## Requirements

- Unraid 6.8.0 or later
- NVIDIA GPU with proper drivers installed
- NVIDIA GPU must support nvidia-ml library

## Files Included

- `nvidia-gpu-exporter.plg` - Main plugin file
- `NvidiaGpuExporter.page` - Web interface
- `rc.nvidia-gpu-exporter` - Service control script
- `include/status.php` - Status check script
- `include/service.php` - Service control handler

## Troubleshooting

### Service Won't Start

1. Check if NVIDIA drivers are properly installed
2. Verify GPU is detected: `nvidia-smi`
3. Check logs: `tail -f /var/log/nvidia-gpu-exporter.log`

### Metrics Not Available

1. Ensure service is running
2. Check port 9835 is not blocked by firewall
3. Verify GPU supports nvidia-ml library

### Permission Issues

The plugin runs as root and should have all necessary permissions.

## License

This plugin is released under the GNU General Public License v2.

## Support

For issues with the plugin, please create an issue on the GitHub repository.
For issues with the nvidia_gpu_exporter binary itself, please refer to the [upstream project](https://github.com/utkuozdemir/nvidia_gpu_exporter).
