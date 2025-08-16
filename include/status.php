<?php
// Status check script
$pidfile = '/var/run/nvidia-gpu-exporter.pid';

if (file_exists($pidfile)) {
    $pid = trim(file_get_contents($pidfile));
    if ($pid && posix_kill($pid, 0)) {
        echo '<div class="nvidia-status status-running">';
        echo '<strong>Status:</strong> Running (PID: ' . $pid . ')';
        echo '</div>';
    } else {
        echo '<div class="nvidia-status status-stopped">';
        echo '<strong>Status:</strong> Stopped';
        echo '</div>';
        if (file_exists($pidfile)) {
            unlink($pidfile);
        }
    }
} else {
    echo '<div class="nvidia-status status-stopped">';
    echo '<strong>Status:</strong> Stopped';
    echo '</div>';
}
?>
