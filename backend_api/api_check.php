<?php
header('Content-Type: text/plain');
require_once 'db_config.php';

echo "=== XPOWER API PRODUCTION CHECK ===\n";
echo "1. Server Time: " . date('Y-m-d H:i:s') . "\n";
echo "2. PHP Version: " . phpversion() . "\n";
echo "3. Connection: " . ($conn->connect_error ? "FAILED" : "SUCCESS") . "\n";

// 4. Test a specific user
$test_no = '772610398';
$stmt = $conn->prepare("SELECT first_name FROM partners WHERE mobile_no = ?");
$stmt->bind_param("s", $test_no);
$stmt->execute();
$res = $stmt->get_result();

echo "4. Database Lookup for $test_no: " . ($res->num_rows > 0 ? "FOUND" : "NOT FOUND") . "\n";

echo "5. HTACCESS Check: " . (file_exists('.htaccess') ? "EXISTS" : "NONE") . "\n";
echo "6. Folder Permissions: " . substr(sprintf('%o', fileperms('.')), -4) . "\n";
?>
