<?php
header('Content-Type: application/json');
require_once 'db/db_config.php';
require_once 'cors_headers.php';

$response = ["success" => false, "data" => []];

$sql = "SELECT * FROM resell_packages WHERE status = 'Active' ORDER BY ID ASC";
$result = $conn->query($sql);

if ($result) {
    $packages = [];
    while ($row = $result->fetch_assoc()) {
        $package_id = $row['ID'];
        
        // Fetch modules for this package
        $module_sql = "SELECT * FROM resell_package_modules WHERE packageID = $package_id AND status = 'Active'";
        $module_result = $conn->query($module_sql);
        $modules = [];
        if ($module_result) {
            while ($m_row = $module_result->fetch_assoc()) {
                $modules[] = $m_row;
            }
        }
        
        $row['modules'] = $modules;
        $packages[] = $row;
    }
    
    $response["success"] = true;
    $response["data"] = $packages;
} else {
    $response["message"] = "Error fetching packages: " . $conn->error;
}

echo json_encode($response);
$conn->close();
?>
