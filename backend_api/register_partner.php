<?php
// Enable error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
require_once 'db_config.php';

$first_name = $_POST['first_name'] ?? '';
$last_name = $_POST['last_name'] ?? '';
$c_code = $_POST['c_code'] ?? '';
$mobile_no = $_POST['mobile_no'] ?? '';
$email = $_POST['email'] ?? '';
$bank_account_no = $_POST['bank_account_no'] ?? '';
$bank_name = $_POST['bank_name'] ?? '';
$bank_account_type = $_POST['bank_account_type'] ?? '';

if (empty($mobile_no) || empty($first_name) || empty($last_name)) {
    echo json_encode(["success" => false, "message" => "Required fields are missing"]);
    exit;
}

try {
    // 1. Check if already exists
    $check = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
    $check->bind_param("s", $mobile_no);
    $check->execute();
    if ($check->get_result()->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "Mobile number already registered"]);
        exit;
    }

    // 2. Insert new partner
    $stmt = $conn->prepare("INSERT INTO partners (first_name, last_name, c_code, mobile_no, email, bank_account_no, bank_name, bank_account_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", $first_name, $last_name, $c_code, $mobile_no, $email, $bank_account_no, $bank_name, $bank_account_type);

    if ($stmt->execute()) {
        $partner_id = $conn->insert_id; // Get the auto-increment ID
        $now = date('Y-m-d H:i:s');

        // 3. Log registration
        $act_type = 'register';
        $status = 1;
        $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
        $log_stmt->bind_param("sssi", $partner_id, $act_type, $now, $status);
        $log_stmt->execute();
        $log_stmt->close();

        // 4. Generate and Save OTP
        $otp = rand(1000, 9999);

        // Expire previous codes for this ID
        $expire_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE u_Id = ? AND status = 0");
        $expire_stmt->bind_param("s", $partner_id);
        $expire_stmt->execute();
        $expire_stmt->close();

        // Insert new code
        $otp_stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
        $otp_stmt->bind_param("sis", $partner_id, $otp, $now);

        if ($otp_stmt->execute()) {
            echo json_encode([
                "success" => true,
                "message" => "Partner registered and OTP generated",
                "debug_otp" => $otp
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Registration successful but failed to save OTP: " . $otp_stmt->error]);
        }
        $otp_stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "System Error: " . $e->getMessage()]);
}

$conn->close();
?>
