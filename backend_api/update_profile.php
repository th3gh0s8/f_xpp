<?php
header('Content-Type: application/json');
require_once 'db_config.php';

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

$stmt = $conn->prepare("UPDATE partners SET first_name = ?, last_name = ?, c_code = ?, email = ?, bank_account_no = ?, bank_name = ?, bank_account_type = ? WHERE mobile_no = ?");
$stmt->bind_param("ssssssss", $first_name, $last_name, $c_code, $email, $bank_account_no, $bank_name, $bank_account_type, $mobile_no);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update profile: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
