<?php
function isExporterRunning() {
    return shell_exec('pidof nvidia_gpu_exporter') ? true : false;
}

function getStatus() {
    if (isExporterRunning()) {
        return '<span class="label label-success">Running</span>';
    } else {
        return '<span class="label label-danger">Stopped</span>';
    }
}

function isAutostartEnabled() {
    return file_exists('/boot/config/plugins/nvidia-gpu-exporter/autostart');
}

if ($_POST['start']) {
    shell_exec('/usr/local/emhttp/plugins/nvidia-gpu-exporter/nvidia_gpu_exporter &');
    header("Location: " . $_SERVER['REQUEST_URI']);
    exit;
}

if ($_POST['stop']) {
    shell_exec('killall nvidia_gpu_exporter');
    header("Location: " . $_SERVER['REQUEST_URI']);
    exit;
}

if (isset($_POST['autostart'])) {
    if ($_POST['autostart'] == '1') {
        mkdir('/boot/config/plugins/nvidia-gpu-exporter', 0755, true);
        touch('/boot/config/plugins/nvidia-gpu-exporter/autostart');
    } else {
        unlink('/boot/config/plugins/nvidia-gpu-exporter/autostart');
    }
    header("Location: " . $_SERVER['REQUEST_URI']);
    exit;
}
?>
