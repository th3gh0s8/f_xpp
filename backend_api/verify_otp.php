<?php
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_POST['mobile_no'] ?? '';
$otp_code = $_POST['otp_code'] ?? '';

if (empty($mobile_no) || empty($otp_code)) {
    echo json_encode(["success" => false, "message" => "Required fields missing"]);
    exit;
}

try {
    // We check for the most recent ACTIVE OTP (status 0) for this mobile number (checking variations)
    $stmt = $conn->prepare(\"SELECT * FROM web_codes WHERE (u_Id = ? OR u_Id = ? OR u_Id = ?) AND otp_code = ? AND status = 0 ORDER BY time DESC LIMIT 1\");
    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');
    $stmt->bind_param(\"ssss\", $no_zero, $with_zero, $mobile_no, $otp_code);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $matched_u_id = $row['u_Id'];
        
        // Use the exact u_Id matched to clear the code
        $stmt_upd = $conn->prepare(\"UPDATE web_codes SET status = 1 WHERE u_Id = ? AND otp_code = ?\");
        $stmt_upd->bind_param(\"ss\", $matched_u_id, $otp_code);
        $stmt_upd->execute();
        $stmt_upd->close();
        
        echo json_encode([\"success\" => true, \"message\" => \"OTP verified successfully\"]);
    } else {
        echo json_encode([\"success\" => false, \"message\" => \"Invalid or expired OTP\"]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
