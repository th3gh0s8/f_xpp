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
    $stmt = $conn->prepare(\"SELECT * FROM partners WHERE mobile_no = ? OR mobile_no = ?\");
    if (!$stmt) {
        die(json_encode([\"success\" => false, \"message\" => \"Prepare search failed: \" . $conn->error]));
    }
    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');
    
    $stmt->bind_param(\"ss\", $no_zero, $with_zero);
    $stmt->execute();
    $result = $stmt->get_result();
    $partner = $result->fetch_assoc();
    $stmt->close();

    if ($partner) {
        $otp = rand(1111, 9999);
        $now = date('Y-m-d H:i:s');
        $matched_mobile = $partner['mobile_no']; // Use the format actually stored in DB

        // 3. Clear old codes for this mobile number (checking variations)
        $stmt_clear = $conn->prepare(\"UPDATE web_codes SET status = 1 WHERE u_Id = ? OR u_Id = ? OR u_Id = ?\");
        if (!$stmt_clear) {
            die(json_encode([\"success\" => false, \"message\" => \"Prepare clear failed: \" . $conn->error]));
        }
        $stmt_clear->bind_param(\"sss\", $no_zero, $with_zero, $matched_mobile);
        $stmt_clear->execute();
        $stmt_clear->close();

        // 4. Save new OTP
        $stmt_otp = $conn->prepare(\"INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)\");
        if (!$stmt_otp) {
            die(json_encode([\"success\" => false, \"message\" => \"Prepare insert failed: \" . $conn->error]));
        }
        $stmt_otp->bind_param(\"sis\", $matched_mobile, $otp, $now);

        if ($stmt_otp->execute()) {
            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp,
                "db_status" => "OTP Saved Successfully",
                "message" => "OTP generated and saved successfully for $matched_mobile"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "db_status" => "OTP Save Failed: " . $stmt_otp->error,
                "message" => "Database rejected OTP save: " . $stmt_otp->error
            ]);
        }
        $stmt_otp->close();
    } else {
        echo json_encode([
            \"success\" => false, 
            \"message\" => \"Mobile number not found in database: $mobile_no\",
            \"debug\" => [\"tried_no_zero\" => $no_zero, \"tried_with_zero\" => $with_zero]
        ]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "System Error: " . $e->getMessage()]);
}

$conn->close();
?>
