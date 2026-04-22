<?php
header('Content-Type: application/json');
require_once 'db_config.php';

// Get POST data
$mobile_no = $_POST['mobile_no'] ?? '';
$otp_code = $_POST['otp_code'] ?? '';

if (empty($mobile_no) || empty($otp_code)) {
    echo json_encode(["success" => false, "message" => "Mobile number and OTP are required"]);
    exit;
}

// Ensure they are treated as strings to prevent overflow issues in PHP
// then bind as strings or bigints
$stmt = $conn->prepare("SELECT * FROM web_codes WHERE u_Id = ? AND otp_code = ? AND status = 0 ORDER BY time DESC LIMIT 1");
$stmt->bind_param("ss", $mobile_no, $otp_code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $id = $row['ID'];

    // Mark OTP as used (status = 1)
    $update_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE ID = ?");
    $update_stmt->bind_param("i", $id);
    $update_stmt->execute();

    // Log successful login activity
    $act_type = 'login';
    $status = 1;
    $now = date('Y-m-d H:i:s');
    $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
    $log_stmt->bind_param("sssi", $mobile_no, $act_type, $now, $status);
    $log_stmt->execute();

    echo json_encode(["success" => true, "message" => "OTP verified successfully"]);
} else {
    // Log failed attempt
    $act_type = 'login_failed';
    $status = 0;
    $now = date('Y-m-d H:i:s');
    $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
    $log_stmt->bind_param("sssi", $mobile_no, $act_type, $now, $status);
    $log_stmt->execute();

    echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
}

$stmt->close();
$conn->close();
?>
