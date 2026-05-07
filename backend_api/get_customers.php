<?php
require_once 'cors_headers.php';

// CRITICAL: Ensure NO output before JSON
ini_set('display_errors', 0);
error_reporting(E_ALL);

// 1. Path resolution for moved db folder
if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "Database file not found."]));
}

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Mobile number missing"]));
}

try {
    if (!$conn) throw new Exception("DB connection failed.");

    // Normalize mobile number
    $clean_no = preg_replace('/\D/', '', $mobile_no);
    $no_zero = ltrim($clean_no, '0');
    $with_zero = '0' . $no_zero;

    // 1. Get Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($p_res['ID'] ?? 0);

    if ($partner_id == 0) {
        die(json_encode(["success" => false, "message" => "Partner record not found"]));
    }

    // 2. Fetch Customers
    // Wide search for legacy data + new ID based data
    $sql = "SELECT * FROM new_clients WHERE partnerTb = ? OR partnerTb = ? OR partnerTb = ? ORDER BY rDateTime DESC";
    $stmtC = $conn->prepare($sql);

    // Bind parameters: partnerTb is INT, but we also check legacy strings
    $stmtC->bind_param("iss", $partner_id, $no_zero, $with_zero);
    $stmtC->execute();
    $result = $stmtC->get_result();

    $customers = [];
    while ($row = $result->fetch_assoc()) {
        $status = strtolower($row['status'] ?? 'pending');
        if ($status == 'active' || $status == 'approved') {
            $row['display_status'] = 'APPROVED';
        } else {
            $row['display_status'] = 'PENDING';
        }
        $customers[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $customers,
        "count" => count($customers)
    ]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
