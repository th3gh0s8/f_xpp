<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_POST['mobile_no'] ?? '';
$amount = $_POST['amount'] ?? 0;

if (empty($mobile_no) || $amount <= 0) {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
    exit;
}

// 1. Check if bank details exist
$check_bank = $conn->prepare("SELECT bank_account_no, bank_name FROM partners WHERE mobile_no = ?");
$check_bank->bind_param("i", $mobile_no);
$check_bank->execute();
$result = $check_bank->get_result();
$partner = $result->fetch_assoc();

if (empty($partner['bank_account_no']) || empty($partner['bank_name']) || $partner['bank_account_no'] == 0) {
    echo json_encode(["success" => false, "message" => "Please update bank details first", "code" => "MISSING_BANK"]);
    exit;
}

// 2. Insert Payout Request
$receipt_no = "PAY-" . time();
$status = "PENDING";
$date = date("Y-m-d");

$stmt = $conn->prepare("INSERT INTO payout_request (recipt_no, mobile_no, amount, request_date, status) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("sisss", $receipt_no, $mobile_no, $amount, $date, $status);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Payout request submitted"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to submit request"]);
}

$stmt->close();
$conn->close();
?>
