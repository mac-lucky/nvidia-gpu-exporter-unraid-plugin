#!/bin/bash

echo "=== Nvidia GPU Exporter Plugin Troubleshooting ==="
echo
echo "1. Checking if nvidia_gpu_exporter binary exists..."
if [ -f "/usr/local/bin/nvidia_gpu_exporter" ]; then
    echo "✅ Binary exists at /usr/local/bin/nvidia_gpu_exporter"
    echo "   Version: $(/usr/local/bin/nvidia_gpu_exporter --version 2>/dev/null || echo 'Unable to get version')"
    echo "   Permissions: $(ls -la /usr/local/bin/nvidia_gpu_exporter | awk '{print $1}')"
else
    echo "❌ Binary NOT found at /usr/local/bin/nvidia_gpu_exporter"
    echo "   You can download it by running:"
    echo "   /usr/local/emhttp/plugins/nvidia_gpu_exporter/include/download.sh download"
fi

echo
echo "2. Checking nvidia-smi availability..."
if command -v nvidia-smi &> /dev/null; then
    echo "✅ nvidia-smi is available"
    
    echo
    echo "3. Testing nvidia-smi functionality..."
    if nvidia-smi &> /dev/null; then
        echo "✅ nvidia-smi works correctly"
        echo "   GPU Information:"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | head -5
    else
        echo "❌ nvidia-smi fails to run"
        echo "   This usually means Nvidia drivers are not properly loaded"
        echo "   Please check your Nvidia driver installation"
    fi
else
    echo "❌ nvidia-smi is NOT available"
    echo "   Please install Nvidia drivers first"
fi

echo
echo "4. Checking plugin configuration..."
CONFIG_FILE="/boot/config/plugins/nvidia_gpu_exporter/settings.cfg"
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Configuration file exists"
    echo "   Settings:"
    cat "$CONFIG_FILE" | sed 's/^/   /'
else
    echo "⚠️  Configuration file does not exist"
    echo "   Default settings will be used"
fi

echo
echo "5. Checking service status..."
PID_FILE="/var/run/nvidia_gpu_exporter.pid"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "✅ Service is running (PID: $PID)"
        
        # Check if port is listening
        source "$CONFIG_FILE" 2>/dev/null || true
        PORT=${port:-9835}
        if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
            echo "✅ Service is listening on port $PORT"
        else
            echo "⚠️  Service running but not listening on port $PORT"
        fi
    else
        echo "❌ Service not running (stale PID file)"
        rm -f "$PID_FILE"
    fi
else
    echo "⚠️  Service is not running"
fi

echo
echo "6. Checking recent log entries..."
LOG_FILE="/var/log/nvidia_gpu_exporter.log"
if [ -f "$LOG_FILE" ]; then
    echo "✅ Log file exists"
    echo "   Last 5 lines:"
    tail -5 "$LOG_FILE" | sed 's/^/   /'
else
    echo "⚠️  Log file does not exist"
fi

echo
echo "7. Testing manual startup..."
if [ -f "/usr/local/bin/nvidia_gpu_exporter" ] && command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
    echo "Running quick test..."
    timeout 5 /usr/local/bin/nvidia_gpu_exporter --web.listen-address="127.0.0.1:19835" --log.level=info &
    TEST_PID=$!
    sleep 2
    
    if kill -0 $TEST_PID 2>/dev/null; then
        echo "✅ Manual startup test successful"
        kill $TEST_PID 2>/dev/null
    else
        echo "❌ Manual startup test failed"
    fi
else
    echo "⚠️  Cannot run manual test - prerequisites not met"
fi

echo
echo "=== Troubleshooting Complete ==="
echo
echo "Common solutions:"
echo "- If binary is missing: Run download from the web interface"
echo "- If nvidia-smi fails: Check Nvidia driver installation"
echo "- If service won't start: Check the log file for specific errors"
echo "- If port is in use: Change port in configuration"
