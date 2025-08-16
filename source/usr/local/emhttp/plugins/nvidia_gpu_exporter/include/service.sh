#!/bin/bash

PLUGIN_NAME="nvidia_gpu_exporter"
BINARY_PATH="/usr/local/bin/nvidia_gpu_exporter"
CONFIG_FILE="/boot/config/plugins/$PLUGIN_NAME/settings.cfg"
PID_FILE="/var/run/$PLUGIN_NAME.pid"
LOG_FILE="/var/log/$PLUGIN_NAME.log"

# Create directories if they don't exist
mkdir -p /boot/config/plugins/$PLUGIN_NAME
mkdir -p /var/log

# Create default config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "port=9835" > "$CONFIG_FILE"
    echo "log_level=info" >> "$CONFIG_FILE"
    echo "autostart=yes" >> "$CONFIG_FILE"
fi

# Read configuration
source "$CONFIG_FILE"

start_service() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Service is already running"
        return 1
    fi
    
    echo "Starting $PLUGIN_NAME..."
    
    # Start the service in background
    nohup "$BINARY_PATH" \
        --web.listen-address="0.0.0.0:${port:-9835}" \
        --log.level="${log_level:-info}" \
        > "$LOG_FILE" 2>&1 & 
    
    echo $! > "$PID_FILE"
    
    # Wait a moment and check if it's still running
    sleep 2
    if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "$PLUGIN_NAME started successfully"
        return 0
    else
        echo "Failed to start $PLUGIN_NAME"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_service() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Service is not running"
        return 1
    fi
    
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping $PLUGIN_NAME..."
        kill "$PID"
        
        # Wait for graceful shutdown
        for i in {1..10}; do
            if ! kill -0 "$PID" 2>/dev/null; then
                break
            fi
            sleep 1
        done
        
        # Force kill if still running
        if kill -0 "$PID" 2>/dev/null; then
            echo "Force killing $PLUGIN_NAME..."
            kill -9 "$PID"
        fi
        
        rm -f "$PID_FILE"
        echo "$PLUGIN_NAME stopped"
    else
        echo "Service is not running (stale PID file)"
        rm -f "$PID_FILE"
    fi
    
    return 0
}

restart_service() {
    stop_service
    sleep 2
    start_service
}

status_service() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "running"
        return 0
    else
        echo "stopped"
        return 1
    fi
}

case "$1" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        status_service
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit $?
