<?php
require_once "cors_headers.php";
header('Cache-Control: no-cache, no-store, must-revalidate');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$mobile_no = $_GET['mobile_no'] ?? '';
if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

try {
    // 1. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $no_zero = ltrim($mobile_no, '0');
    $with_zero = '0' . $no_zero;
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($p_res['ID'] ?? 0);

    if ($partner_id == 0) {
        die(json_encode(["success" => false, "message" => "Partner record not found"]));
    }

    // 2. Query invoices using Numeric ID
    $stmt = $conn->prepare("SELECT * FROM invoices WHERE partner_tb = ? ORDER BY date DESC, time DESC");
    $stmt->bind_param("i", $partner_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $invoices = [];
    while ($row = $result->fetch_assoc()) {
        $invoices[] = $row;
    }

    echo json_encode(["success" => true, "data" => $invoices]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

$conn->close();
?>
