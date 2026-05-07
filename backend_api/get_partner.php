<?php
// UNIFIED PRODUCTION OTP GENERATOR - ROBUST PATHS
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');

// 1. Precise path discovery for the moved db folder
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

try {
    // 2. Find Partner (checking variations for safety)
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');
    
    $stmt->bind_param("ss", $no_zero, $with_zero);
    $stmt->execute();
    $partner = $stmt->get_result()->fetch_assoc();

    if ($partner) {
        $otp = rand(1111, 9999);
        $now = date('Y-m-d H:i:s');

        // 3. Clear old codes for this mobile number
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no'");

        // 4. Naked Insert (Direct SQL is most compatible with live servers)
        $sql = "INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$mobile_no', $otp, '$now', 0)";

        if ($conn->query($sql)) {
            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp,
                "message" => "OTP generated and saved successfully"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Database rejected OTP save",
                "sql_error" => $conn->error
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Mobile number not found in database: $mobile_no"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "System Error: " . $e->getMessage()]);
}

$conn->close();
?>
