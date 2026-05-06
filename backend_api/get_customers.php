<?php
// Enable error reporting to identify potential issues
ini_set('display_errors', 0); // Disable direct display to prevent HTML in JSON
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

try {
    if (!$conn) throw new Exception("Database connection not initialized.");

    // 1. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    if (!$stmtP) throw new Exception("Prepare failed: " . $conn->error);
    
    $stmtP->bind_param("s", $mobile_no);
    $stmtP->execute();
    $partner = $stmtP->get_result()->fetch_assoc();
    $partner_id = isset($partner['ID']) ? (int)$partner['ID'] : 0;

    // 2. Fetch customers
    // The table uses partnerTb (INT) which might hold ID or mobile number.
    // We cast partnerTb to CHAR in the query to handle both string/int comparisons.
    $sql = "SELECT * FROM new_clients WHERE CAST(partnerTb AS CHAR) = ? OR CAST(partnerTb AS CHAR) = ? ORDER BY rDateTime DESC";
    $stmtC = $conn->prepare($sql);
    if (!$stmtC) throw new Exception("Prepare failed: " . $conn->error);
    
    // We bind as strings (s) because we cast the DB column to CHAR in the query.
    $param1 = (string)($partner_id > 0 ? $partner_id : $mobile_no);
    $param2 = (string)$mobile_no;
    $stmtC->bind_param("ss", $param1, $param2);
    
    if (!$stmtC->execute()) {
        throw new Exception("Query failed: " . $stmtC->error);
    }
    
    $result = $stmtC->get_result();
    $customers = [];
    while ($row = $result->fetch_assoc()) {
        // Map 'Active' to 'APPROVED' for the app's UI
        if (isset($row['status']) && (strcasecmp($row['status'], 'Active') == 0 || strcasecmp($row['status'], 'Approved') == 0)) {
            $row['display_status'] = 'APPROVED';
        } else {
            $row['display_status'] = strtoupper($row['status'] ?? 'PENDING');
        }
        
        $customers[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $customers,
        "debug_partner_id" => $partner_id,
        "count" => count($customers)
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false, 
        "message" => "Server Error: " . $e->getMessage()
    ]);
}

$conn->close();
?>
