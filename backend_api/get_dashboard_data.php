<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

// 1. Get Total Earned and Total Invoices
$stmt = $conn->prepare("SELECT SUM(com_amount) as total_earned, COUNT(ID) as total_invoices, COUNT(DISTINCT cus_tb) as total_customers FROM invoices WHERE partner_tb = ?");
$stmt->bind_param("s", $mobile_no);
$stmt->execute();
$invoice_stats = $stmt->get_result()->fetch_assoc();

// 2. Get Pending Payouts
$stmt2 = $conn->prepare("SELECT SUM(amount) as pending_payouts FROM payout_request WHERE partner_id = ? AND status = 0");
$stmt2->bind_param("s", $mobile_no);
$stmt2->execute();
$payout_stats = $stmt2->get_result()->fetch_assoc();

// 3. Determine Level
$customers = $invoice_stats['total_customers'] ?? 0;
$stmt3 = $conn->prepare("SELECT level_name FROM partner_levels WHERE min_coustomers <= ? ORDER BY min_coustomers DESC LIMIT 1");
$stmt3->bind_param("i", $customers);
$stmt3->execute();
$level_result = $stmt3->get_result()->fetch_assoc();
$level = $level_result['level_name'] ?? 'LEVEL 1';

echo json_encode([
    "success" => true,
    "data" => [
        "total_earned" => (float)($invoice_stats['total_earned'] ?? 0),
        "total_invoices" => (int)($invoice_stats['total_invoices'] ?? 0),
        "pending_payouts" => (float)($payout_stats['pending_payouts'] ?? 0),
        "level" => $level
    ]
]);

$conn->close();
?>
