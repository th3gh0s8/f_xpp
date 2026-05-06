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
    // We check for the most recent ACTIVE OTP (status 0) for this mobile number
    $stmt = $conn->prepare("SELECT * FROM web_codes WHERE u_Id = ? AND otp_code = ? AND status = 0 ORDER BY time DESC LIMIT 1");
    $stmt->bind_param("ss", $mobile_no, $otp_code);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no' AND otp_code = '$otp_code'");
        echo json_encode(["success" => true, "message" => "OTP verified successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
