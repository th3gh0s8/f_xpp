<?php
// SIMPLE CONNECTION TESTER
header('Content-Type: text/plain');
require_once 'db_config.php';

if ($conn->connect_error) {
    echo "CONNECTION FAILED: " . $conn->connect_error;
} else {
    echo "SUCCESS: Database Connected Successfully!\n";

    // Check if web_codes exists
    $res = $conn->query("SHOW TABLES LIKE 'web_codes'");
    if ($res->num_rows > 0) {
        echo "TABLE FOUND: 'web_codes' exists.\n";
    } else {
        echo "TABLE MISSING: 'web_codes' NOT found!\n";
    }
}
?>
