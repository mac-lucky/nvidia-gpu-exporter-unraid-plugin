RC_SCRIPT="/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.sh"

mkdir -p /usr/local/etc/rc.d
ln -sf "$RC_SCRIPT" /usr/local/etc/rc.d/rc.nvidia-gpu-exporter

# Sourced, the control script only reads and checks the cfg, so this sees the
# same AUTOSTART, LISTEN_PORT and TELEMETRY_PATH the service starts with.
# shellcheck source=/dev/null
. "$RC_SCRIPT"

# Restart when auto-start is on or the service is already up, so an upgrade
# swaps in the new binary; otherwise leave it stopped.
if [ "$AUTOSTART" = "true" ] || pgrep -f /usr/local/bin/nvidia-gpu-exporter >/dev/null 2>&1; then
    "$RC_SCRIPT" restart || echo "WARNING: service failed to start; check /var/log/nvidia-gpu-exporter.log"
fi

cat <<EOF

================================================================
  NVIDIA GPU Exporter plugin installed.

  Find it under:  Settings -> User Utilities -> NVIDIA GPU Exporter
  Metrics:        http://<server>:${LISTEN_PORT}${TELEMETRY_PATH}

  GPU data requires nvidia-smi from the Nvidia Driver plugin.
================================================================

EOF
