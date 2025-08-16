#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"

echo "Uninstalling $PLUGIN_NAME..."

# Stop the service
/usr/local/emhttp/plugins/$PLUGIN_NAME/include/service.sh stop

# Remove autostart script
rm -f /etc/rc.d/rc.$PLUGIN_NAME

# Remove binary
rm -f /usr/local/bin/nvidia_gpu_exporter

# Remove log file
rm -f /var/log/$PLUGIN_NAME.log

# Remove PID file
rm -f /var/run/$PLUGIN_NAME.pid

echo "$PLUGIN_NAME uninstalled successfully"
echo "Configuration files in /boot/config/plugins/$PLUGIN_NAME/ are preserved"
