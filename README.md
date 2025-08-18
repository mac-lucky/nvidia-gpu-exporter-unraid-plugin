# NVIDIA GPU Exporter Plugin for Unraid

This plugin provides NVIDIA GPU monitoring capabilities for Unraid systems through the nvidia_gpu_exporter tool. It exports detailed GPU metrics in Prometheus format, making it easy to monitor GPU performance, utilization, memory usage, temperature, and power consumption.

## Features

- **Real-time GPU Metrics**: Monitor GPU utilization, memory usage, temperature, and power consumption
- **Prometheus Compatible**: Exports metrics in Prometheus format for easy integration with monitoring systems
- **Process Monitoring**: Track which processes are using GPU resources
- **Fan Speed Monitoring**: Monitor GPU fan speeds and cooling status
- **Multiple GPU Support**: Supports systems with multiple NVIDIA GPUs
- **Web Interface**: Access metrics via HTTP endpoint

## Requirements

- Unraid 6.9.0 or later
- NVIDIA GPU with proper drivers installed
- nvidia-smi utility available on the system

## Installation

1. Navigate to **Plugins** > **Install Plugin** in your Unraid web interface
2. Enter the plugin URL: `https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/raw/main/nvidia_gpu_exporter.plg`
3. Click **Install**

## Usage

Once installed, the plugin will automatically start the NVIDIA GPU Exporter service. The metrics will be available at:

```text
http://YOUR_UNRAID_IP:9835/metrics
```

### Configuration

The plugin uses port 9835 by default. You can modify the configuration by editing the settings file:

```bash
/boot/config/plugins/nvidia_gpu_exporter/settings.cfg
```

### Prometheus Configuration

To scrape metrics with Prometheus, add the following to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "unraid-gpu"
    static_configs:
      - targets: ["YOUR_UNRAID_IP:9835"]
```

## Available Metrics

The exporter provides various GPU metrics including:

- `nvidia_gpu_utilization_percentage` - GPU utilization percentage
- `nvidia_gpu_memory_used_bytes` - GPU memory usage in bytes
- `nvidia_gpu_memory_total_bytes` - Total GPU memory in bytes
- `nvidia_gpu_temperature_celsius` - GPU temperature
- `nvidia_gpu_power_usage_watts` - GPU power consumption
- `nvidia_gpu_fan_speed_percentage` - Fan speed percentage
- And many more...

## Building from Source

To build the plugin package from source:

1. Clone this repository
2. Run the build script:

   ```bash
   cd source
   ./compile.sh
   ```

The script will download the nvidia_gpu_exporter binary and create an Unraid-compatible package.

## Based On

This plugin is based on the excellent [nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter) by utkuozdemir, which provides comprehensive NVIDIA GPU monitoring capabilities.

## Support

For support and issues, please visit the [GitHub repository](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin) or create an issue.

## License

This plugin follows the same licensing as the underlying nvidia_gpu_exporter project.
