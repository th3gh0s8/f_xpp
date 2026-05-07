<?php
require_once 'cors_headers.php';

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$mobile_no = $_POST['mobile_no'] ?? '';
$amount = (float)($_POST['amount'] ?? 0);

if (empty($mobile_no) || $amount <= 0) {
    echo json_encode(["success" => false, "message" => "Invalid mobile number or amount"]);
    exit;
}

try {
    // 1. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID, bank_account_no FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $no_zero = ltrim($mobile_no, '0');
    $with_zero = '0' . $no_zero;
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $partner = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($partner['ID'] ?? 0);

    if ($partner_id == 0) {
        die(json_encode(["success" => false, "message" => "Partner record not found"]));
    }

    // 2. Validate Balance
    $stmtI = $conn->prepare("SELECT SUM(balance) as available_balance FROM invoices WHERE partner_tb = ?");
    $stmtI->bind_param("i", $partner_id);
    $stmtI->execute();
    $current_balance = (float)($stmtI->get_result()->fetch_assoc()['available_balance'] ?? 0);

    if ($amount > $current_balance) {
        die(json_encode(["success" => false, "message" => "Insufficient balance. Max allowed: LKR " . number_format($current_balance, 2)]));
    }

    // 3. Insert Request
    $request_date = date('Y-m-d');
    $request_time = date('H:i:s');
    $status = 'pending';
    $recipt_no = time();

    $stmtInsert = $conn->prepare("INSERT INTO payout_request (partner_id, request_date, request_time, amount, status, recipt_no) VALUES (?, ?, ?, ?, ?, ?)");
    $stmtInsert->bind_param("issssi", $partner_id, $request_date, $request_time, $amount, $status, $recipt_no);

    if ($stmtInsert->execute()) {
        echo json_encode(["success" => true, "message" => "Payout requested successfully", "receipt_no" => $recipt_no]);
    } else {
        echo json_encode(["success" => false, "message" => "Database error: " . $stmtInsert->error]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

$conn->close();
?>
