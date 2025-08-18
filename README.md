# NVIDIA GPU Exporter Plugin for Unraid

![Auto Update](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/workflows/Auto%20Update%20NVIDIA%20GPU%20Exporter%20Version/badge.svg)

A simple Unraid plugin that installs and manages the NVIDIA GPU Exporter service for monitoring GPU metrics with Prometheus and other monitoring systems.

## 🤖 Automated Updates

This plugin features **automatic version updates** powered by GitHub Actions:

- **Weekly Checks**: Automatically checks for new nvidia-gpu-exporter releases every Monday
- **Manual Trigger**: Can be triggered manually via GitHub Actions
- **Auto-Updates**: Creates pull requests with version updates
- **Auto-Merge**: Automatically merges PRs after validation
- **Validation**: Tests download URLs and XML structure before deployment

## Features

- **Automatic Installation**: Downloads and installs nvidia-gpu-exporter v1.3.2 from GitHub releases
- **Auto-Start**: Automatically starts the service on boot
- **Simple Management**: Easy start/stop/status commands
- **Clean Uninstall**: Removes all files and stops services on plugin removal
- **Logging**: Service output logged to `/var/log/nvidia-gpu-exporter.log`
- **Standard Port**: Exports metrics on port 9835 (default)

## Installation

1. Go to **Plugins** tab in Unraid
2. Click **Install Plugin**
3. Enter the plugin URL:
   ```
   https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia_gpu_exporter.plg
   ```
4. Click **Install**

The plugin will automatically:
- Download the nvidia-gpu-exporter binary
- Install it to `/usr/local/bin/nvidia-gpu-exporter`
- Start the service
- Configure auto-start on boot

## Usage

### Service Management

The plugin creates a control script at `/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh`

**Available commands:**
```bash
# Start the service
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh start

# Stop the service
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh stop

# Check service status
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh status

# Restart the service
/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh restart
```

### Manual Process Management

You can also manage the process directly using standard Unix commands:

```bash
# Check if the service is running
pgrep -f /usr/local/bin/nvidia-gpu-exporter

# Kill the service
pkill -f /usr/local/bin/nvidia-gpu-exporter

# Force kill if needed
pkill -9 -f /usr/local/bin/nvidia-gpu-exporter
```

### Accessing Metrics

Once running, GPU metrics are available at:
```
http://your-unraid-ip:9835/metrics
```

Example metrics include:
- GPU utilization
- Memory usage
- Temperature
- Power consumption
- Fan speed

## File Locations

| File | Purpose |
|------|---------|
| `/usr/local/bin/nvidia-gpu-exporter` | Main binary |
| `/var/log/nvidia-gpu-exporter.log` | Service logs |
| `/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh` | Control script |
| `/usr/local/etc/rc.d/rc.nvidia-gpu-exporter` | Auto-start symlink |

## Monitoring Integration

### Prometheus Configuration

Add this job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'nvidia-gpu-exporter'
    static_configs:
      - targets: ['your-unraid-ip:9835']
    scrape_interval: 5s
```

### Grafana Dashboard

Search for "NVIDIA GPU" dashboards on grafana.com or create custom visualizations using the exported metrics.

## Troubleshooting

### Service Won't Start

1. Check if NVIDIA drivers are installed:
   ```bash
   nvidia-smi
   ```

2. Check the log file:
   ```bash
   tail -f /var/log/nvidia-gpu-exporter.log
   ```

3. Verify binary permissions:
   ```bash
   ls -la /usr/local/bin/nvidia-gpu-exporter
   ```

### Multiple Processes Running

If you see multiple PIDs when checking status:

1. Stop all processes:
   ```bash
   /usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh stop
   ```

2. Force kill if needed:
   ```bash
   pkill -9 -f nvidia-gpu-exporter
   ```

3. Verify no processes remain:
   ```bash
   pgrep -f /usr/local/bin/nvidia-gpu-exporter
   ps aux | grep nvidia-gpu-exporter
   ```

4. Start fresh:
   ```bash
   /usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh start
   ```

### Port Issues

If port 9835 is already in use:
```bash
# Check what's using the port
netstat -tulpn | grep 9835

# Or with ss
ss -tulpn | grep 9835
```

### Manual Installation Verification

```bash
# Check if binary exists and is executable
ls -la /usr/local/bin/nvidia-gpu-exporter

# Test the binary directly
/usr/local/bin/nvidia-gpu-exporter --help

# Check if service is responding
curl http://localhost:9835/metrics
```

## Uninstallation

1. Go to **Plugins** tab in Unraid
2. Find "NVIDIA GPU Exporter" in the installed plugins list
3. Click **Remove**

The plugin will automatically:
- Stop the running service
- Remove the binary file
- Clean up all plugin files
- Remove auto-start configuration
- Delete log files

## Version Information

- **Plugin Version**: 2025.01.18
- **nvidia-gpu-exporter Version**: 1.3.2
- **Source**: [utkuozdemir/nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter)

## Automation

### Automatic Updates

The plugin includes GitHub Actions automation to keep it up to date:

**Weekly Schedule**: Every Monday at 6 AM UTC, the workflow:
1. Checks for new nvidia-gpu-exporter releases
2. Compares with the current plugin version
3. Creates a pull request if a new version is found
4. Validates the new download URL and XML structure
5. Auto-merges the PR if all checks pass

**Manual Trigger**: You can also trigger the update workflow manually:
1. Go to the [Actions tab](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/actions)
2. Select "Auto Update NVIDIA GPU Exporter Version"
3. Click "Run workflow"
4. Optionally check "Force update" to update even if no new version is detected

**What Gets Updated**:
- Download URL to the latest release
- Plugin version (date-based: YYYY.MM.DD)
- Changelog with new version information

### Workflow Status

Check the current status of automated updates:
- [![Auto Update](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/workflows/Auto%20Update%20NVIDIA%20GPU%20Exporter%20Version/badge.svg)](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/actions)

## Support

- **Plugin Issues**: [GitHub Issues](https://github.com/mac-lucky/nvidia-gpu-exporter-plugin/issues)
- **nvidia-gpu-exporter Issues**: [Upstream Repository](https://github.com/utkuozdemir/nvidia_gpu_exporter/issues)

## License

This plugin is provided as-is. The nvidia-gpu-exporter binary is subject to its own license terms.