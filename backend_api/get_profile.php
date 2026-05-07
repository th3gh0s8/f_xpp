<?php
// FETCH PARTNER DATA WITHOUT GENERATING OTP
header('Content-Type: application/json');
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
    die(json_encode(["success" => false, "message" => "Mobile number required"]));
}

// Normalize input
$clean_no = preg_replace('/\D/', '', $mobile_no);
$no_zero = ltrim($clean_no, '0');
$with_zero = '0' . $no_zero;

try {
    // Find Partner
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ? OR mobile_no = ? LIMIT 1");
    $stmt->bind_param("ss", $no_zero, $with_zero);
    $stmt->execute();
    $partner = $stmt->get_result()->fetch_assoc();

    if ($partner) {
        echo json_encode([
            "success" => true,
            "data" => $partner
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Partner not found"]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
