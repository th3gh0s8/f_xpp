<?php
// Debug script to capture the actual response
$url = "https://powersoftt.com/xPowerPartners/get_customers.php?mobile_no=702610398";
$response = file_get_contents($url);
file_put_contents('debug_output.txt', $response);
echo "Response saved to debug_output.txt. Check the file content.";
?>
