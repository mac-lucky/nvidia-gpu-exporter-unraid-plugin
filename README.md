# NVIDIA GPU Exporter Plugin for Unraid

This plugin provides a Prometheus exporter for NVIDIA GPU metrics on Unraid systems. It's based on the excellent [nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter) by utkuozdemir.

## Features

- **Simple Web Interface**: Easy-to-use plugin page with start/stop/restart controls
- **Automatic Binary Management**: Downloads and installs the latest nvidia_gpu_exporter binary
- **Configurable Settings**: Customize listen address, metrics path, and log level
- **Real-time Status**: View service status and recent log output
- **Prometheus Integration**: Exposes GPU metrics in Prometheus format

## Installation

1. Add the plugin repository URL to your Unraid Community Applications:

   ```text
   https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main
   ```

2. Install the "NVIDIA GPU Exporter" plugin from Community Applications

3. Navigate to **Settings > NVIDIA GPU Exporter** to configure and start the service

## Configuration

The plugin provides the following configuration options:

- **Listen Address**: IP address and port for the exporter (default: `0.0.0.0:9835`)
- **Metrics Path**: URL path for the metrics endpoint (default: `/metrics`)
- **Log Level**: Logging verbosity (debug, info, warn, error)

## Usage

1. **Download Binary**: Click "Download & Install Binary" to get the latest nvidia_gpu_exporter
2. **Configure Settings**: Set your preferred listen address and other options
3. **Start Service**: Click "Start" to begin exporting GPU metrics
4. **Access Metrics**: Navigate to `http://YOUR_UNRAID_IP:9835/metrics` to view metrics

## Metrics

The exporter provides comprehensive NVIDIA GPU metrics including:

- GPU utilization and memory usage
- Temperature and power consumption
- Fan speeds and throttling information
- Driver and CUDA versions
- Process information

For a complete list of metrics, see the [nvidia_gpu_exporter documentation](https://github.com/utkuozdemir/nvidia_gpu_exporter/blob/main/METRICS.md).

## Prometheus Configuration

Add the following to your Prometheus configuration to scrape metrics:

```yaml
scrape_configs:
  - job_name: "nvidia-gpu"
    static_configs:
      - targets: ["YOUR_UNRAID_IP:9835"]
```

## Requirements

- Unraid 6.9.0 or later
- NVIDIA GPU with properly installed drivers
- NVIDIA Container Toolkit (if using Docker containers)

## Troubleshooting

### Service Won't Start

- Ensure NVIDIA drivers are properly installed
- Check that no other process is using the configured port
- Review the log output in the plugin interface

### No Metrics Available

- Verify that `nvidia-smi` command works on your system
- Check that the NVIDIA driver is properly loaded
- Ensure the service is running and accessible

### Permission Issues

- The plugin runs with appropriate permissions
- Log files are stored in `/var/log/nvidia_gpu_exporter/`
- Configuration is stored in `/boot/config/plugins/nvidia_gpu_exporter/`

## Support

- **Plugin Issues**: [GitHub Issues](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/issues)
- **Exporter Issues**: [nvidia_gpu_exporter Issues](https://github.com/utkuozdemir/nvidia_gpu_exporter/issues)
- **Unraid Forums**: [Plugin Support Thread](https://forums.unraid.net/topic/xxx-nvidia-gpu-exporter-plugin/)

## License

This plugin is released under the MIT License. The nvidia_gpu_exporter binary is subject to its own licensing terms.

## Credits

- [utkuozdemir](https://github.com/utkuozdemir) for the excellent nvidia_gpu_exporter
- [ich777](https://github.com/ich777) for reference plugin structure
- Unraid community for testing and feedback
