<?PHP
$plugin = "nvidia-gpu-exporter";
$config_file = "/boot/config/plugins/$plugin/nvidia-gpu-exporter.cfg";
$log_file = "/var/log/nvidia-gpu-exporter.log";
$binary_path = "/usr/local/bin/nvidia-gpu-exporter";

// Helper functions
function log_message($message) {
    global $log_file;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($log_file, "[$timestamp] $message\n", FILE_APPEND | LOCK_EX);
}

function load_config() {
    global $config_file;
    $default_cfg = [
        'SERVICE' => 'disable',
        'PORT' => '9835',
        'AUTOSTART' => 'yes',
        'EXTRA_ARGS' => ''
    ];
    
    if (file_exists($config_file)) {
        $cfg = parse_ini_file($config_file) ?: $default_cfg;
    } else {
        $cfg = $default_cfg;
    }
    
    return array_merge($default_cfg, $cfg);
}

function validate_port($port) {
    return is_numeric($port) && $port >= 1024 && $port <= 65535;
}

function is_port_in_use($port) {
    $connection = @fsockopen('127.0.0.1', $port, $errno, $errstr, 1);
    if ($connection) {
        fclose($connection);
        return true;
    }
    return false;
}

function check_nvidia_prerequisites() {
    // Check if nvidia-smi is available
    exec('which nvidia-smi 2>/dev/null', $output, $return_code);
    if ($return_code !== 0) {
        return ['status' => false, 'message' => 'nvidia-smi command not found. Please install NVIDIA drivers.'];
    }
    
    // Check if GPU is detected
    exec('nvidia-smi -L 2>/dev/null', $output, $return_code);
    if ($return_code !== 0 || empty($output)) {
        return ['status' => false, 'message' => 'No NVIDIA GPU detected. Please check your hardware and drivers.'];
    }
    
    return ['status' => true, 'message' => 'NVIDIA prerequisites satisfied.'];
}

function get_service_pid() {
    $pid = exec('pgrep -f "nvidia-gpu-exporter" 2>/dev/null');
    return $pid ? intval($pid) : 0;
}

function is_service_running() {
    return get_service_pid() > 0;
}

function start_service() {
    global $binary_path, $log_file;
    
    $cfg = load_config();
    $prerequisites = check_nvidia_prerequisites();
    
    if (!$prerequisites['status']) {
        log_message("Failed to start service: " . $prerequisites['message']);
        return ['success' => false, 'message' => $prerequisites['message']];
    }
    
    if (!validate_port($cfg['PORT'])) {
        log_message("Failed to start service: Invalid port " . $cfg['PORT']);
        return ['success' => false, 'message' => "Invalid port: {$cfg['PORT']}. Port must be between 1024-65535."];
    }
    
    if (is_service_running()) {
        return ['success' => false, 'message' => 'Service is already running.'];
    }
    
    // Check if port is available (excluding our own process)
    if (is_port_in_use($cfg['PORT'])) {
        log_message("Failed to start service: Port {$cfg['PORT']} is already in use");
        return ['success' => false, 'message' => "Port {$cfg['PORT']} is already in use by another service."];
    }
    
    if (!file_exists($binary_path)) {
        log_message("Failed to start service: Binary not found at $binary_path");
        return ['success' => false, 'message' => 'nvidia-gpu-exporter binary not found. Please reinstall the plugin.'];
    }
    
    // Build command
    $cmd = escapeshellarg($binary_path) . " --web.listen-address=:" . escapeshellarg($cfg['PORT']);
    
    if (!empty($cfg['EXTRA_ARGS'])) {
        $cmd .= " " . $cfg['EXTRA_ARGS'];
    }
    
    $cmd .= " > " . escapeshellarg($log_file) . " 2>&1 &";
    
    log_message("Starting service with command: $cmd");
    exec($cmd);
    
    // Wait a moment and check if service started
    sleep(2);
    
    if (is_service_running()) {
        log_message("Service started successfully on port {$cfg['PORT']}");
        return ['success' => true, 'message' => "Service started successfully on port {$cfg['PORT']}."];
    } else {
        $error_log = file_exists($log_file) ? file_get_contents($log_file) : 'No log available';
        log_message("Failed to start service. Log: $error_log");
        return ['success' => false, 'message' => 'Failed to start service. Check logs for details.'];
    }
}

function stop_service() {
    if (!is_service_running()) {
        return ['success' => true, 'message' => 'Service is not running.'];
    }
    
    $pid = get_service_pid();
    log_message("Stopping service (PID: $pid)");
    
    // Try graceful shutdown first
    exec("kill $pid 2>/dev/null");
    sleep(2);
    
    // Force kill if still running
    if (is_service_running()) {
        exec("kill -9 $pid 2>/dev/null");
        sleep(1);
    }
    
    if (!is_service_running()) {
        log_message("Service stopped successfully");
        return ['success' => true, 'message' => 'Service stopped successfully.'];
    } else {
        log_message("Failed to stop service");
        return ['success' => false, 'message' => 'Failed to stop service.'];
    }
}

function get_service_status() {
    $cfg = load_config();
    $pid = get_service_pid();
    $running = $pid > 0;
    
    $status_html = "<div class='status-container'>";
    
    if ($running) {
        $status_html .= "<div class='status-item'><span class='status-label'>Status:</span> <span class='status-ok'>✓ Running</span></div>";
        $status_html .= "<div class='status-item'><span class='status-label'>PID:</span> <span class='status-value'>$pid</span></div>";
        $status_html .= "<div class='status-item'><span class='status-label'>Port:</span> <span class='status-value'>{$cfg['PORT']}</span></div>";
        
        $hostname = gethostname();
        $metrics_url = "http://$hostname:{$cfg['PORT']}/metrics";
        $status_html .= "<div class='status-item'><span class='status-label'>Metrics URL:</span> <span class='status-value'><a href='$metrics_url' target='_blank'>$metrics_url</a></span></div>";
        
        // Test connectivity
        $connection = @fsockopen('127.0.0.1', $cfg['PORT'], $errno, $errstr, 3);
        if ($connection) {
            fclose($connection);
            $status_html .= "<div class='status-item'><span class='status-label'>Connectivity:</span> <span class='status-ok'>✓ Responding</span></div>";
        } else {
            $status_html .= "<div class='status-item'><span class='status-label'>Connectivity:</span> <span class='status-error'>✗ Not responding</span></div>";
        }
    } else {
        $status_html .= "<div class='status-item'><span class='status-label'>Status:</span> <span class='status-error'>✗ Not running</span></div>";
    }
    
    $status_html .= "</div>";
    
    // Show recent log entries
    if (file_exists($log_file)) {
        $log_lines = array_slice(file($log_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES), -10);
        if (!empty($log_lines)) {
            $status_html .= "<div class='log-container'>";
            $status_html .= "<h4>Recent Log Entries:</h4>";
            $status_html .= "<pre class='log-content'>";
            foreach ($log_lines as $line) {
                $status_html .= htmlspecialchars($line) . "\n";
            }
            $status_html .= "</pre>";
            $status_html .= "</div>";
        }
    }
    
    return $status_html;
}

// Handle AJAX requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'start':
            $result = start_service();
            if ($result['success']) {
                echo "<div class='success'>{$result['message']}</div>";
            } else {
                echo "<div class='error'>{$result['message']}</div>";
            }
            break;
            
        case 'stop':
            $result = stop_service();
            if ($result['success']) {
                echo "<div class='success'>{$result['message']}</div>";
            } else {
                echo "<div class='error'>{$result['message']}</div>";
            }
            break;
            
        case 'restart':
            $stop_result = stop_service();
            sleep(1);
            $start_result = start_service();
            
            if ($start_result['success']) {
                echo "<div class='success'>Service restarted successfully.</div>";
            } else {
                echo "<div class='error'>Failed to restart service: {$start_result['message']}</div>";
            }
            break;
            
        case 'status':
            echo get_service_status();
            break;
            
        case 'check_port':
            $port = $_POST['port'] ?? '';
            if (validate_port($port)) {
                if (is_port_in_use($port)) {
                    echo "Port $port is in use";
                } else {
                    echo "Port $port is available";
                }
            } else {
                echo "Invalid port";
            }
            break;
            
        case 'check_prerequisites':
            $check = check_nvidia_prerequisites();
            if ($check['status']) {
                echo "<div class='success'>{$check['message']}</div>";
            } else {
                echo "<div class='error'>{$check['message']}</div>";
            }
            break;
            
        default:
            echo "<div class='error'>Invalid action: $action</div>";
    }
} else {
    // Default response for non-POST requests
    echo get_service_status();
}
?>