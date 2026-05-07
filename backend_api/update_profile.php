<?php
require_once 'cors_headers.php';
require_once 'db/db_config.php';

$mobile_no = $_POST['mobile_no'] ?? '';
$c_code = $_POST['c_code'] ?? '';
$first_name = $_POST['first_name'] ?? '';
$last_name = $_POST['last_name'] ?? '';
$email = $_POST['email'] ?? '';
$bank_account_no = $_POST['bank_account_no'] ?? '';
$bank_name = $_POST['bank_name'] ?? '';
$bank_account_type = $_POST['bank_account_type'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number is required"]);
    exit;
}

try {
    $stmt = $conn->prepare("UPDATE partners SET first_name = ?, last_name = ?, c_code = ?, email = ?, bank_account_no = ?, bank_name = ?, bank_account_type = ? WHERE mobile_no = ? OR mobile_no = ?");
    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');
    $stmt->bind_param("sssssssss", $first_name, $last_name, $c_code, $email, $bank_account_no, $bank_name, $bank_account_type, $no_zero, $with_zero);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to update profile: " . $stmt->error]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
