echo "Uninstalling NVIDIA GPU Exporter plugin..."

# Stop the service: TERM with a grace period, then KILL.
pkill -TERM -f /usr/local/bin/nvidia-gpu-exporter 2>/dev/null || true
for _ in $(seq 1 30); do
    pgrep -f /usr/local/bin/nvidia-gpu-exporter >/dev/null 2>&1 || break
    sleep 0.1
done
pkill -KILL -f /usr/local/bin/nvidia-gpu-exporter 2>/dev/null || true

rm -f /usr/local/bin/nvidia-gpu-exporter
rm -f /usr/local/etc/rc.d/rc.nvidia-gpu-exporter
rm -rf /usr/local/emhttp/plugins/nvidia-gpu-exporter
rm -f /var/log/nvidia-gpu-exporter.log
rm -f /boot/config/plugins/nvidia-gpu-exporter/nvidia_gpu_exporter_*_linux_x86_64.tar.gz

echo "Removed the service, control script, settings page and cached tarballs."
echo "Config at /boot/config/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.cfg left intact."
