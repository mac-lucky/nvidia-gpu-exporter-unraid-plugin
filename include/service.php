<?php
// Service control script
if ($_POST['action']) {
    $action = $_POST['action'];
    
    // Validate action
    $allowed_actions = ['start', 'stop', 'restart', 'status'];
    if (!in_array($action, $allowed_actions)) {
        echo "Invalid action";
        exit;
    }
    
    // Execute the control script
    $output = shell_exec("/etc/rc.d/rc.nvidia-gpu-exporter $action 2>&1");
    echo $output;
}
?>
