set -e
CFG_DIR="/boot/config/plugins/nvidia-gpu-exporter"
CFG_FILE="$CFG_DIR/nvidia-gpu-exporter.cfg"
mkdir -p "$CFG_DIR"
mkdir -p /usr/local/emhttp/plugins/nvidia-gpu-exporter
touch "$CFG_FILE"

# Idempotently ensure every config key exists; existing values are preserved so
# upgrades pick up new keys without clobbering user settings.
ensure() { grep -q "^$1=" "$CFG_FILE" || printf '%s=%s\n' "$1" "$2" >> "$CFG_FILE"; }
ensure LISTEN_PORT '"9835"'
ensure AUTOSTART '"true"'
ensure LOG_LEVEL '"info"'
ensure NVIDIA_SMI_CMD '"nvidia-smi"'
ensure QUERY_FIELDS '"AUTO"'
ensure TELEMETRY_PATH '"/metrics"'
chmod 644 "$CFG_FILE"
echo "Config ready at $CFG_FILE"
