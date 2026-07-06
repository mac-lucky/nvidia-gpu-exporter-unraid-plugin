#!/bin/bash
# Control script for the NVIDIA GPU Exporter service. Called by the settings
# page buttons, usable manually, and symlinked to
# /usr/local/etc/rc.d/rc.nvidia-gpu-exporter. The no-argument (boot) path
# honors the AUTOSTART setting; an explicit "start" always starts.

BINARY_PATH="/usr/local/bin/nvidia-gpu-exporter"
CFG_FILE="/boot/config/plugins/nvidia-gpu-exporter/nvidia-gpu-exporter.cfg"
LOG_FILE="/var/log/nvidia-gpu-exporter.log"

LISTEN_PORT="9835"
AUTOSTART="true"
LOG_LEVEL="info"
NVIDIA_SMI_CMD="nvidia-smi"
QUERY_FIELDS="AUTO"
TELEMETRY_PATH="/metrics"
# shellcheck source=/dev/null
[ -f "$CFG_FILE" ] && . "$CFG_FILE"

running_pids() { pgrep -f "$BINARY_PATH" 2>/dev/null; }

build_args() {
    ARGS=(
        "--web.listen-address=:${LISTEN_PORT}"
        "--web.telemetry-path=${TELEMETRY_PATH}"
        "--nvidia-smi-command=${NVIDIA_SMI_CMD}"
        "--log.level=${LOG_LEVEL}"
    )
    # AUTO is the exporter's own default; only pass an explicit field list.
    if [ -n "$QUERY_FIELDS" ] && [ "$QUERY_FIELDS" != "AUTO" ]; then
        ARGS+=("--query-field-names=${QUERY_FIELDS}")
    fi
}

start_service() {
    if [ ! -x "$BINARY_PATH" ]; then
        echo "ERROR: $BINARY_PATH not found; reinstall the plugin"
        return 1
    fi
    PIDS=$(running_pids)
    if [ -n "$PIDS" ]; then
        echo "NVIDIA GPU Exporter already running (PID ${PIDS//$'\n'/ })"
        return 0
    fi
    build_args
    echo "$(date): starting nvidia-gpu-exporter on port ${LISTEN_PORT}" >> "$LOG_FILE"
    nohup "$BINARY_PATH" "${ARGS[@]}" >> "$LOG_FILE" 2>&1 &
    sleep 2
    PIDS=$(running_pids)
    if [ -n "$PIDS" ]; then
        echo "NVIDIA GPU Exporter started (PID ${PIDS//$'\n'/ }, port ${LISTEN_PORT})"
    else
        echo "ERROR: NVIDIA GPU Exporter failed to start; last log lines:"
        tail -5 "$LOG_FILE" 2>/dev/null
        return 1
    fi
}

stop_service() {
    if [ -z "$(running_pids)" ]; then
        echo "NVIDIA GPU Exporter is not running"
        return 0
    fi
    echo "Stopping NVIDIA GPU Exporter..."
    pkill -TERM -f "$BINARY_PATH" 2>/dev/null
    for _ in $(seq 1 30); do
        [ -z "$(running_pids)" ] && break
        sleep 0.1
    done
    pkill -KILL -f "$BINARY_PATH" 2>/dev/null
    if [ -z "$(running_pids)" ]; then
        echo "$(date): stopped nvidia-gpu-exporter" >> "$LOG_FILE"
        echo "NVIDIA GPU Exporter stopped"
    else
        echo "ERROR: failed to stop NVIDIA GPU Exporter"
        return 1
    fi
}

status_service() {
    PIDS=$(running_pids)
    if [ -n "$PIDS" ]; then
        echo "NVIDIA GPU Exporter is running (PID ${PIDS//$'\n'/ })"
        if ss -tln 2>/dev/null | grep -q ":${LISTEN_PORT} " || netstat -tln 2>/dev/null | grep -q ":${LISTEN_PORT} "; then
            echo "Listening on port ${LISTEN_PORT} (metrics at ${TELEMETRY_PATH})"
        else
            echo "WARNING: port ${LISTEN_PORT} is not listening"
        fi
        return 0
    fi
    echo "NVIDIA GPU Exporter is not running"
    return 1
}

case "$1" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        sleep 1
        start_service
        ;;
    # "apply" backs the settings page Apply button: pick up the new config, but
    # do not start a service the user has deliberately left stopped.
    apply)
        if [ -n "$(running_pids)" ] || [ "$AUTOSTART" = "true" ]; then
            stop_service
            sleep 1
            start_service
        else
            echo "Settings saved; service is stopped and auto-start is disabled"
        fi
        ;;
    status)
        status_service
        ;;
    *)
        if [ "$AUTOSTART" = "true" ]; then
            start_service
        else
            echo "Auto-start disabled in $CFG_FILE"
        fi
        ;;
esac
