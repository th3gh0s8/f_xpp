<?php
header('Content-Type: application/json');
require_once 'db/db_config.php';

$mobile_no = $_POST['mobile_no'] ?? '';
$bank_account_no = $_POST['bank_account_no'] ?? '';
$bank_name = $_POST['bank_name'] ?? '';
$bank_account_type = $_POST['bank_account_type'] ?? '';

if (empty($mobile_no) || empty($bank_account_no) || empty($bank_name)) {
    echo json_encode(["success" => false, "message" => "Required fields are missing"]);
    exit;
}

$stmt = $conn->prepare("UPDATE partners SET bank_account_no = ?, bank_name = ?, bank_account_type = ? WHERE mobile_no = ?");
$stmt->bind_param("isss", $bank_account_no, $bank_name, $bank_account_type, $mobile_no);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Bank details updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to update bank details: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
