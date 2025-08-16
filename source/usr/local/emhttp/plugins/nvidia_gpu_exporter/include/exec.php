<?php
header('Content-Type: application/json');

$binary_path = "/usr/local/bin/nvidia_gpu_exporter";
$pid_file = "/var/run/nvidia_gpu_exporter/nvidia_gpu_exporter.pid";
$log_file = "/var/log/nvidia_gpu_exporter/nvidia_gpu_exporter.log";
$config_file = "/boot/config/plugins/nvidia_gpu_exporter/nvidia_gpu_exporter.cfg";

// Ensure directories exist
@mkdir("/var/run/nvidia_gpu_exporter", 0755, true);
@mkdir("/var/log/nvidia_gpu_exporter", 0755, true);
@mkdir("/boot/config/plugins/nvidia_gpu_exporter", 0755, true);

function is_service_running() {
    global $pid_file;
    if (!file_exists($pid_file)) {
        return false;
    }
    $pid = trim(file_get_contents($pid_file));
    return !empty($pid) && file_exists("/proc/$pid");
}

function stop_service() {
    global $pid_file;
    
    if (is_service_running()) {
        $pid = trim(file_get_contents($pid_file));
        exec("kill $pid");
        
        // Wait up to 10 seconds for process to stop
        for ($i = 0; $i < 10; $i++) {
            if (!file_exists("/proc/$pid")) {
                break;
            }
            sleep(1);
        }
        
        // Force kill if still running
        if (file_exists("/proc/$pid")) {
            exec("kill -9 $pid");
            sleep(1);
        }
    }
    
    // Clean up PID file
    if (file_exists($pid_file)) {
        unlink($pid_file);
    }
    
    return true;
}

function start_service() {
    global $binary_path, $pid_file, $log_file, $config_file;
    
    if (is_service_running()) {
        return ["success" => false, "message" => "Service is already running"];
    }
    
    if (!file_exists($binary_path)) {
        return ["success" => false, "message" => "Binary not found. Please download it first."];
    }
    
    // Load configuration
    $config = [];
    if (file_exists($config_file)) {
        $config = parse_ini_file($config_file);
    }
    
    $listen_address = $config['listen_address'] ?? '0.0.0.0:9835';
    $metrics_path = $config['metrics_path'] ?? '/metrics';
    $log_level = $config['log_level'] ?? 'info';
    
    // Build command
    $cmd = "$binary_path --web.listen-address=\"$listen_address\" --web.telemetry-path=\"$metrics_path\" --log.level=\"$log_level\" > \"$log_file\" 2>&1 & echo \$! > \"$pid_file\"";
    
    exec($cmd);
    
    // Wait a moment and check if it started
    sleep(2);
    
    if (is_service_running()) {
        return ["success" => true, "message" => "Service started successfully"];
    } else {
        return ["success" => false, "message" => "Failed to start service. Check logs."];
    }
}

function download_binary() {
    global $binary_path;
    
    $version = "1.3.2"; // Latest version
    $url = "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v$version/nvidia_gpu_exporter_{$version}_linux_x86_64.tar.gz";
    $temp_dir = "/tmp/nvidia_gpu_exporter_download";
    $temp_file = "$temp_dir/nvidia_gpu_exporter.tar.gz";
    
    // Create temp directory
    @mkdir($temp_dir, 0755, true);
    
    // Download the file
    exec("wget -O \"$temp_file\" \"$url\"", $output, $return_code);
    
    if ($return_code !== 0) {
        return ["success" => false, "message" => "Failed to download binary"];
    }
    
    // Extract the binary
    exec("cd \"$temp_dir\" && tar -xzf nvidia_gpu_exporter.tar.gz", $output, $return_code);
    
    if ($return_code !== 0) {
        return ["success" => false, "message" => "Failed to extract binary"];
    }
    
    // Find the binary in extracted files
    $extracted_binary = "";
    $files = glob("$temp_dir/nvidia_gpu_exporter*");
    foreach ($files as $file) {
        if (is_file($file) && is_executable($file) && basename($file) === 'nvidia_gpu_exporter') {
            $extracted_binary = $file;
            break;
        }
    }
    
    if (empty($extracted_binary)) {
        return ["success" => false, "message" => "Binary not found in downloaded archive"];
    }
    
    // Copy binary to final location
    if (!copy($extracted_binary, $binary_path)) {
        return ["success" => false, "message" => "Failed to install binary"];
    }
    
    // Set permissions
    chmod($binary_path, 0755);
    
    // Clean up temp files
    exec("rm -rf \"$temp_dir\"");
    
    return ["success" => true, "message" => "Binary downloaded and installed successfully"];
}

// Handle the action
if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $response = ["success" => false, "message" => "Unknown action"];
    
    switch ($action) {
        case 'start':
            $response = start_service();
            break;
            
        case 'stop':
            stop_service();
            $response = ["success" => true, "message" => "Service stopped"];
            break;
            
        case 'restart':
            stop_service();
            sleep(1);
            $response = start_service();
            break;
            
        case 'download':
        case 'update':
            // Stop service if running
            if (is_service_running()) {
                stop_service();
                $restart_after = true;
            } else {
                $restart_after = false;
            }
            
            $response = download_binary();
            
            // Restart if it was running before
            if ($restart_after && $response['success']) {
                sleep(1);
                $start_response = start_service();
                if (!$start_response['success']) {
                    $response['message'] .= " Warning: Failed to restart service.";
                }
            }
            break;
            
        default:
            $response = ["success" => false, "message" => "Invalid action"];
    }
    
    echo json_encode($response);
} else {
    echo json_encode(["success" => false, "message" => "No action specified"]);
}
?>
