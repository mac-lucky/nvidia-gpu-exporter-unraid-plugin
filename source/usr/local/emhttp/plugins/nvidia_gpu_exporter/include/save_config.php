<?php
header('Content-Type: application/json');

$config_file = "/boot/config/plugins/nvidia_gpu_exporter/nvidia_gpu_exporter.cfg";

// Ensure directory exists
@mkdir("/boot/config/plugins/nvidia_gpu_exporter", 0755, true);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $listen_address = $_POST['listen_address'] ?? '0.0.0.0:9835';
    $metrics_path = $_POST['metrics_path'] ?? '/metrics';
    $log_level = $_POST['log_level'] ?? 'info';
    
    // Validate inputs
    if (!preg_match('/^[0-9a-f.:]+:[0-9]+$/i', $listen_address)) {
        echo json_encode(["success" => false, "message" => "Invalid listen address format"]);
        exit;
    }
    
    if (!preg_match('/^\/[a-zA-Z0-9\/_-]*$/', $metrics_path)) {
        echo json_encode(["success" => false, "message" => "Invalid metrics path format"]);
        exit;
    }
    
    if (!in_array($log_level, ['debug', 'info', 'warn', 'error'])) {
        echo json_encode(["success" => false, "message" => "Invalid log level"]);
        exit;
    }
    
    // Create configuration content
    $config_content = "; NVIDIA GPU Exporter Configuration\n";
    $config_content .= "; Generated on " . date('Y-m-d H:i:s') . "\n\n";
    $config_content .= "listen_address=\"$listen_address\"\n";
    $config_content .= "metrics_path=\"$metrics_path\"\n";
    $config_content .= "log_level=\"$log_level\"\n";
    
    // Write configuration file
    if (file_put_contents($config_file, $config_content) !== false) {
        echo json_encode(["success" => true, "message" => "Configuration saved successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to save configuration"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>
