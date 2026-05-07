<?php
// Capture all output to prevent corrupting JSON
ob_start();

// Disable errors and display to prevent contamination
ini_set('display_errors', 0);
error_reporting(0);

header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');

require_once 'db/db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    ob_end_clean();
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

try {
    if (!$conn) throw new Exception("DB connection failed.");

    $sql = \"SELECT c.* 
            FROM new_clients c 
            JOIN partners p ON c.partnerTb = p.ID 
            WHERE (p.mobile_no = ? OR p.mobile_no = ?)
            ORDER BY c.rDateTime DESC\";
            
    $stmtC = $conn->prepare($sql);
    if (!$stmtC) throw new Exception("Prepare failed: " . $conn->error);

    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');

    $stmtC->bind_param(\"ss\", $no_zero, $with_zero);
    $stmtC->execute();
    $result = $stmtC->get_result();

    $customers = [];
    while ($row = $result->fetch_assoc()) {
        $status = strtolower($row['status'] ?? 'pending');
        $row['display_status'] = ($status == 'active' || $status == 'approved') ? 'APPROVED' : 'PENDING';
        $customers[] = $row;
    }

    $response = [
        "success" => true,
        "data" => $customers,
        "count" => count($customers)
    ];

    ob_end_clean();
    echo json_encode($response);

} catch (Exception $e) {
    ob_end_clean();
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
