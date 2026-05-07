<?php
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

require_once 'db/db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

// 1. Resolve Partner's internal numeric ID first (checking variations for safety)
$stmtP = $conn->prepare(\"SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?\");
$with_zero = '0' . ltrim($mobile_no, '0');
$no_zero = ltrim($mobile_no, '0');
$stmtP->bind_param(\"ss\", $no_zero, $with_zero);
$stmtP->execute();
$partner = $stmtP->get_result()->fetch_assoc();
$partner_id = $partner['ID'] ?? 0;

if ($partner_id == 0) {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
    exit;
}

// 2. Query invoices using the resolved numeric partner_id
// Column partner_tb is int(11) based on your schema
$stmt = $conn->prepare("SELECT * FROM invoices WHERE partner_tb = ? ORDER BY date DESC, time DESC");
$stmt->bind_param("i", $partner_id);
$stmt->execute();
$result = $stmt->get_result();

$invoices = [];
while ($row = $result->fetch_assoc()) {
    $invoices[] = $row;
}

echo json_encode(["success" => true, "data" => $invoices]);

$stmt->close();
$conn->close();
?>
