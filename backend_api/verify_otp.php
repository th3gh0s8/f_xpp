<?php
// OTP VERIFICATION - WITH SUCCESS ACTIVITY LOGGING
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_POST['mobile_no'] ?? '';
$otp_code = $_POST['otp_code'] ?? '';

if (empty($mobile_no) || empty($otp_code)) {
    die(json_encode(["success" => false, "message" => "Fields missing"]));
}

try {
    // 1. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $no_zero = ltrim($mobile_no, '0');
    $with_zero = '0' . $no_zero;
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $partner = $stmtP->get_result()->fetch_assoc();

    if (!$partner) {
        die(json_encode(["success" => false, "message" => "Partner not found"]));
    }

    $partner_id = $partner['ID'];

    // 2. Check for ACTIVE OTP
    $stmt = $conn->prepare("SELECT * FROM web_codes WHERE u_Id = ? AND otp_code = ? AND status = 0 ORDER BY time DESC LIMIT 1");
    $stmt->bind_param("ss", $partner_id, $otp_code);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $code_db_id = $row['ID'];
        $now = date('Y-m-d H:i:s');
        
        // 3. SUCCESS: Mark OTP as used
        $conn->query("UPDATE web_codes SET status = 1 WHERE ID = $code_db_id");

        // 4. LOG SUCCESSFUL LOGIN (Act Type 3 = Login Success)
        $act_type = 3;
        $act_status = 1; // 1 = Success
        $conn->query("INSERT INTO login_activity (u_id, act_type, time, status) VALUES ($partner_id, $act_type, '$now', $act_status)");
        
        echo json_encode(["success" => true, "message" => "OTP verified and activity logged."]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
