# Nvidia GPU Exporter Plugin for Unraid

This plugin provides Prometheus metrics for Nvidia GPUs on Unraid systems using the [nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter) by utkuozdemir.

## Features

- **Easy Installation**: One-click installation through Unraid's plugin system
- **Web Interface**: Start, stop, and restart the exporter through the Unraid web UI
- **Configurable**: Adjust port, log level, and autostart settings
- **Prometheus Ready**: Exposes metrics in Prometheus format
- **Auto-start**: Optionally start the exporter automatically when the system boots

## Metrics Provided

The exporter provides comprehensive GPU metrics including:

- GPU utilization percentage
- Memory usage (used, free, total)
- Temperature readings
- Power consumption
- Fan speed
- Clock speeds (graphics, memory, SM, video)
- Process information (running processes on GPU)
- Driver version information

## Installation

1. Go to **Plugins** in your Unraid web interface
2. Click on **Install Plugin**
3. Enter the plugin URL: `https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia_gpu_exporter.plg`
4. Click **Install**

## Configuration

After installation, navigate to **Settings** > **Nvidia GPU Exporter** to configure:

- **Port**: The port on which the exporter will listen (default: 9835)
- **Log Level**: Logging verbosity (debug, info, warn, error)
- **Auto Start**: Whether to start the exporter automatically on boot

## Usage

### Web Interface

1. Go to **Tools** > **Nvidia GPU Exporter**
2. Use the **Start**, **Stop**, or **Restart** buttons to control the service
3. When running, metrics are available at: `http://your-server-ip:9835/metrics`

### Prometheus Configuration

Add the following to your Prometheus configuration:

```yaml
scrape_configs:
  - job_name: "nvidia-gpu"
    static_configs:
      - targets: ["your-unraid-server:9835"]
    scrape_interval: 15s
```

### Grafana Dashboard

You can use existing Grafana dashboards for nvidia_gpu_exporter, such as:

- Dashboard ID: 14574 (Nvidia GPU Exporter)
- Or create your own custom dashboard using the available metrics

## Metrics Endpoint

Once running, metrics are available at:

```
http://your-server-ip:9835/metrics
```

Example metrics include:

```
nvidia_gpu_utilization_gpu{gpu="0"} 45
nvidia_gpu_memory_used_bytes{gpu="0"} 2147483648
nvidia_gpu_temperature_celsius{gpu="0"} 67
nvidia_gpu_power_draw_watts{gpu="0"} 150
```

## Requirements

- Unraid 6.9.0 or later
- Nvidia GPU with drivers installed
- Nvidia drivers must be loaded and functioning

## Troubleshooting

### Service Won't Start

1. Check that Nvidia drivers are properly installed and loaded
2. Verify the GPU is detected: `nvidia-smi`
3. Check the log file: `/var/log/nvidia_gpu_exporter.log`

### No Metrics Available

1. Ensure the service is running
2. Check that the configured port is not blocked by firewall
3. Verify Nvidia drivers are working: `nvidia-smi`

### Permission Issues

1. Ensure the nvidia_gpu_exporter binary has execute permissions
2. Check that the service can access GPU information

## Files and Directories

- Plugin files: `/usr/local/emhttp/plugins/nvidia_gpu_exporter/`
- Binary: `/usr/local/bin/nvidia_gpu_exporter`
- Configuration: `/boot/config/plugins/nvidia_gpu_exporter/settings.cfg`
- Logs: `/var/log/nvidia_gpu_exporter.log`
- PID file: `/var/run/nvidia_gpu_exporter.pid`

## Support

For issues with this plugin:

- [GitHub Issues](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/issues)

For issues with the underlying exporter:

- [nvidia_gpu_exporter GitHub](https://github.com/utkuozdemir/nvidia_gpu_exporter)

## License

This plugin is released under the MIT License. The nvidia_gpu_exporter binary is subject to its own license terms.

This plugin repository includes automated dependency management via GitHub Actions:

### Weekly Automated Checks

- **Schedule**: Every Monday at 9:00 AM UTC
- **Purpose**: Check for new releases of [nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter)
- **Action**: Automatically creates a Pull Request when a new version is detected

### What Gets Updated Automatically

1. **Plugin Version**: Updated in `<!ENTITY version>` declaration
2. **MD5 Checksum**: Calculated and updated for the new binary
3. **CHANGES Section**: Updated with new version information
4. **Validation**: XML syntax checking and build testing

### Manual Trigger

You can manually trigger the update workflow:

1. Go to **Actions** → **Auto Update NVIDIA GPU Exporter Release**
2. Click **Run workflow**
3. Optionally enable "Force update even if already latest"

## 📋 Workflow Features

### Comprehensive Validation

- ✅ Downloads and verifies new release binaries
- ✅ Calculates MD5 checksums automatically
- ✅ Validates XML plugin syntax
- ✅ Tests build process (if Makefile exists)
- ✅ Creates detailed Pull Request with release information

### Error Handling

- 🚨 Creates GitHub issues if automation fails
- 📊 Provides detailed workflow summaries
- 🔄 Includes rollback protection via PR review process

### Security

- 🔒 Uses GitHub's built-in `GITHUB_TOKEN`
- 🎯 Only updates specific version/checksum fields
- 👀 All changes are reviewed via Pull Request

## Features

- **Auto-discovery** of nvidia-smi metric fields
- **Web interface** for configuration
- **Prometheus metrics** exposed on configurable port (default: 9835)
- **Remote execution** support for nvidia-smi command
- **Systemd-style service** management
- **Real-time monitoring** of GPU metrics

## Prerequisites

- Unraid 6.9.0 or later
- **NVIDIA Driver Plugin**: Install the Nvidia Driver plugin by navigating to the "Apps" tab in your Unraid web UI and search for "Nvidia Driver"
- `nvidia-smi` command available (provided by the NVIDIA Driver plugin)

## Installation

### Step 1: Install NVIDIA Driver Plugin (Required)

**Before installing this plugin**, you must first install the NVIDIA Driver plugin:

1. Navigate to the **"Apps"** tab in your Unraid web UI
2. Search for **"Nvidia Driver"**
3. Click **Install** on the NVIDIA Driver plugin
4. Follow the setup instructions to install your GPU drivers
5. Verify `nvidia-smi` command works by checking **Tools** → **System Log**

### Step 2: Install NVIDIA GPU Exporter

#### Method 1: Community Applications (Recommended)

1. Install the **Community Applications** plugin if not already installed
2. Go to **Apps** tab in Unraid web interface
3. Search for "NVIDIA GPU Exporter"
4. Click **Install**

#### Method 2: Manual Installation

1. Download the plugin file: `nvidia_gpu_exporter.plg`
2. Go to **Plugins** tab in Unraid web interface
3. Click **Install Plugin**
4. Upload or paste the URL to the plugin file
5. Click **Install**

## Configuration

After installation:

1. Go to **Settings** → **NVIDIA GPU Exporter**
2. Configure the following options:

   - **Service**: Enable/Disable the exporter
   - **Port**: Web interface port (default: 9835)
   - **nvidia-smi Path**: Path to nvidia-smi binary
   - **Query Fields**: Auto-detect or manually specify metrics
   - **Log File**: Location for log output

3. Click **Apply** to save settings

## Usage

### Viewing Metrics

Once enabled, you can view the metrics by visiting:

```
http://YOUR_UNRAID_IP:9835/metrics
```

### Prometheus Configuration

Add this to your Prometheus configuration:

```yaml
scrape_configs:
  - job_name: "nvidia-gpu-exporter"
    static_configs:
      - targets: ["YOUR_UNRAID_IP:9835"]
    scrape_interval: 15s
```

### Grafana Dashboard

Import the official **NVIDIA GPU Metrics** dashboard from Grafana.com:

- **Dashboard ID**: 14574
- **Name**: NVIDIA GPU Metrics
- **Direct Link**: [https://grafana.com/grafana/dashboards/14574-nvidia-gpu-metrics/](https://grafana.com/grafana/dashboards/14574-nvidia-gpu-metrics/)

This dashboard provides comprehensive visualization of all GPU metrics including temperature, memory usage, power consumption, and utilization rates.

## Available Metrics

The exporter provides comprehensive GPU metrics including:

- **Temperature**: GPU temperature readings
- **Utilization**: GPU and memory utilization percentages
- **Memory**: Used and total memory
- **Power**: Power consumption
- **Clock Speeds**: Graphics and memory clock frequencies
- **Fan Speed**: Fan RPM (if supported)
- **Process Information**: Running processes and their memory usage

## Query Fields

### Auto-detect (Recommended)

Automatically discovers all available metrics from your GPU.

### Basic Fields

```
name,temperature.gpu,utilization.gpu,memory.used,memory.total
```

### Extended Fields

```
name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,power.draw,clocks.current.graphics,clocks.current.memory
```

### Custom Fields

You can specify any fields supported by `nvidia-smi --help-query-gpu`

## Troubleshooting

### Service Won't Start

1. Check if NVIDIA drivers are installed: `nvidia-smi`
2. Verify nvidia-smi path in settings
3. Check log file for errors

### No Metrics Displayed

1. Ensure service is running (green status in settings)
2. Check firewall settings
3. Verify the port is accessible
4. Review log file for errors

### Permission Issues

The plugin runs with appropriate permissions, but if you encounter issues:

1. Check that nvidia-smi is executable
2. Verify NVIDIA device permissions

## Log Files

View logs in the plugin settings page or directly:

```bash
tail -f /var/log/nvidia_gpu_exporter.log
```

## Uninstallation

1. Go to **Plugins** tab
2. Find "NVIDIA GPU Exporter"
3. Click **Remove**

This will:

- Stop the service
- Remove all plugin files
- Clean up configuration

## Support

For support and issues:

- GitHub Repository: https://github.com/utkuozdemir/nvidia_gpu_exporter
- Unraid Forums: Search for "NVIDIA GPU Exporter"
- Create issues on GitHub for bugs and feature requests

## Version History

### 1.3.2

- Initial Unraid plugin release
- Web-based configuration interface
- Service management integration
- Log file monitoring
- Auto-discovery of nvidia-smi fields

## Credits

- **Original Project**: [utkuozdemir/nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter)
- **Unraid Plugin**: Community contribution
- **Based on**: [a0s/nvidia-smi-exporter](https://github.com/a0s/nvidia-smi-exporter)
