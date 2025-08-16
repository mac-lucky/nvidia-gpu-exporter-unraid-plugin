# Troubleshooting NVIDIA GPU Exporter Plugin Installation

## Common Installation Issues

### 1. "Invalid URL / Server error response"

**Cause**: The plugin file cannot be downloaded from the GitHub repository.

**Solutions**:

1. **Ensure repository is public and files are committed**:

   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Verify the GitHub repository URL is accessible**:

   - Check: https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia-gpu-exporter.plg
   - Should return the XML content directly

3. **Use the local test version first**:
   - Copy `nvidia-gpu-exporter-local.plg` to your Unraid server
   - Install from local file instead of URL

### 2. Binary Download Issues

**Check if the binary download URL is working**:

```bash
curl -I "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz"
```

Should return HTTP 302 (redirect) which means the file exists.

### 3. Installation Steps for Testing

1. **First, test locally**:

   ```bash
   # On your Unraid server
   ./test-install.sh
   ```

2. **Manual installation for testing**:

   ```bash
   # Download and extract
   cd /tmp
   wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz
   tar -xzf nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz

   # Test if it works
   ./nvidia_gpu_exporter --version
   ./nvidia_gpu_exporter --help

   # Quick test (Ctrl+C to stop)
   ./nvidia_gpu_exporter --web.listen-address=:9836
   ```

3. **Check NVIDIA drivers**:
   ```bash
   nvidia-smi
   ```

### 4. Repository Setup Checklist

Before installing the plugin, ensure:

- [ ] Repository is public on GitHub
- [ ] All files are committed and pushed to main branch
- [ ] `nvidia-gpu-exporter.plg` file is accessible via raw GitHub URL
- [ ] Icon file (`nvidia-gpu-exporter.png`) is accessible
- [ ] Repository URL in plugin file matches actual repository

### 5. Plugin Installation URL

Use this URL in Unraid Plugin Manager:

```
https://raw.githubusercontent.com/mac-lucky/nvidia-gpu-exporter-plugin/main/nvidia-gpu-exporter.plg
```

### 6. Alternative Installation Method

If GitHub installation fails, you can:

1. **Copy files manually to Unraid**:

   ```bash
   # Copy nvidia-gpu-exporter-local.plg to your Unraid server
   scp nvidia-gpu-exporter-local.plg root@unraid-server:/tmp/

   # Install from local file in Unraid
   # Go to Settings > Plugins
   # Upload File > Browse to /tmp/nvidia-gpu-exporter-local.plg
   ```

2. **Verify installation manually**:

   ```bash
   # Check if binary was downloaded
   ls -la /boot/config/plugins/nvidia-gpu-exporter/

   # Check if service script exists
   ls -la /etc/rc.d/rc.nvidia-gpu-exporter

   # Test service commands
   /etc/rc.d/rc.nvidia-gpu-exporter status
   /etc/rc.d/rc.nvidia-gpu-exporter start
   ```

### 7. Debug Plugin Installation

Enable debugging by checking Unraid logs:

```bash
tail -f /var/log/syslog | grep plugin
```

### 8. Required Unraid Version

Ensure you're running Unraid 6.8.0 or later:

```bash
cat /etc/unraid-version
```

### 9. Network Issues

If download fails, check:

- Internet connectivity from Unraid server
- Firewall settings
- DNS resolution

### 10. Quick Fix - Skip GitHub and Use Direct Files

If all else fails, create these files manually on your Unraid server:

1. Create plugin directory: `mkdir -p /boot/config/plugins/nvidia-gpu-exporter/`
2. Download binary directly: `wget -O /boot/config/plugins/nvidia-gpu-exporter/nvidia_gpu_exporter.txz https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.3.2/nvidia_gpu_exporter_1.3.2_linux_x86_64.tar.gz`
3. Copy the control script from `rc.nvidia-gpu-exporter` to `/etc/rc.d/rc.nvidia-gpu-exporter`
4. Copy web interface files to `/usr/local/emhttp/plugins/nvidia-gpu-exporter/`

## Success Indicators

When working correctly, you should see:

- Plugin appears in Settings menu as "NVIDIA GPU Exporter"
- Service can be started/stopped via web interface
- Metrics accessible at `http://unraid-ip:9835/metrics`
- Log file created at `/var/log/nvidia-gpu-exporter.log`
