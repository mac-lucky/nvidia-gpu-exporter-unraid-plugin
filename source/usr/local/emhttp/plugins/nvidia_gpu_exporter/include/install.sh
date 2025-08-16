#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"

echo "Installing $PLUGIN_NAME plugin..."

# Download the binary if it doesn't exist
if [ ! -f "/usr/local/bin/nvidia_gpu_exporter" ]; then
    echo "nvidia_gpu_exporter binary not found, downloading..."
    /usr/local/emhttp/plugins/$PLUGIN_NAME/include/download.sh download
    
    # Check if download was successful
    if [ ! -f "/usr/local/bin/nvidia_gpu_exporter" ]; then
        echo "Warning: Failed to download nvidia_gpu_exporter binary"
        echo "You can manually download it from the plugin web interface"
    else
        echo "nvidia_gpu_exporter binary downloaded successfully"
    fi
else
    echo "nvidia_gpu_exporter binary already exists"
fi

# Create autostart script
cat > /etc/rc.d/rc.$PLUGIN_NAME << 'EOF'
#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"
CONFIG_FILE="/boot/config/plugins/$PLUGIN_NAME/settings.cfg"

# Read configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

case "$1" in
    start)
        if [ "${autostart:-yes}" == "yes" ]; then
            echo "Auto-starting $PLUGIN_NAME..."
            /usr/local/emhttp/plugins/$PLUGIN_NAME/include/service.sh start
        fi
        ;;
    stop)
        echo "Stopping $PLUGIN_NAME..."
        /usr/local/emhttp/plugins/$PLUGIN_NAME/include/service.sh stop
        ;;
    restart)
        /usr/local/emhttp/plugins/$PLUGIN_NAME/include/service.sh restart
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit $?
EOF

chmod +x /etc/rc.d/rc.$PLUGIN_NAME

# Start the service if autostart is enabled and binary exists
CONFIG_FILE="/boot/config/plugins/$PLUGIN_NAME/settings.cfg"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    if [ "${autostart:-yes}" == "yes" ] && [ -f "/usr/local/bin/nvidia_gpu_exporter" ]; then
        echo "Starting $PLUGIN_NAME service..."
        /usr/local/emhttp/plugins/$PLUGIN_NAME/include/service.sh start
    fi
fi

echo "nvidia_gpu_exporter plugin installed successfully"
