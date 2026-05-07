<?php
header('Content-Type: application/json');
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

$stmt = $conn->prepare(\"UPDATE partners SET first_name = ?, last_name = ?, c_code = ?, email = ?, bank_account_no = ?, bank_name = ?, bank_account_type = ? WHERE mobile_no = ? OR mobile_no = ?\");
$with_zero = '0' . ltrim($mobile_no, '0');
$no_zero = ltrim($mobile_no, '0');
$stmt->bind_param(\"sssssssss\", $first_name, $last_name, $c_code, $email, $bank_account_no, $bank_name, $bank_account_type, $no_zero, $with_zero);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode([\"success\" => true, \"message\" => \"Profile updated successfully\"]);
    } else {
        // Still return success true if the query executed, but maybe nothing changed
        // Or maybe we should check if the partner even exists
        echo json_encode([\"success\" => true, \"message\" => \"Profile update completed (no changes or record not found)\"]);
    }
} else {
    echo json_encode([\"success\" => false, \"message\" => \"Failed to update profile: \" . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
