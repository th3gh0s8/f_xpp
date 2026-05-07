<?php
// Enable error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
require_once 'db/db_config.php';

$first_name = $_REQUEST['first_name'] ?? '';
$last_name = $_REQUEST['last_name'] ?? '';
$c_code = $_REQUEST['c_code'] ?? '';
$mobile_no = $_REQUEST['mobile_no'] ?? '';
$email = $_REQUEST['email'] ?? '';
$bank_account_no = $_REQUEST['bank_account_no'] ?? '';
$bank_name = $_REQUEST['bank_name'] ?? '';
$bank_account_type = $_REQUEST['bank_account_type'] ?? '';

if (empty($mobile_no) || empty($first_name) || empty($last_name)) {
    echo json_encode(["success" => false, "message" => "Required fields are missing"]);
    exit;
}

try {
    // 1. Check if already exists
    $check = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
    $check->bind_param("s", $mobile_no);
    $check->execute();
    $existing = $check->get_result()->fetch_assoc();
    if ($existing) {
        echo json_encode([
            "success" => true, 
            "message" => "Mobile number already registered",
            "data" => $existing
        ]);
        exit;
    }

    // 2. Insert new partner
    $stmt = $conn->prepare("INSERT INTO partners (first_name, last_name, c_code, mobile_no, email, bank_account_no, bank_name, bank_account_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", $first_name, $last_name, $c_code, $mobile_no, $email, $bank_account_no, $bank_name, $bank_account_type);

    if ($stmt->execute()) {
        $partner_id = $conn->insert_id; // Get the auto-increment ID
        $now = date('Y-m-d H:i:s');

        // Fetch the newly created partner
        $get_stmt = $conn->prepare("SELECT * FROM partners WHERE ID = ?");
        $get_stmt->bind_param("i", $partner_id);
        $get_stmt->execute();
        $partner_data = $get_stmt->get_result()->fetch_assoc();
        $get_stmt->close();

        // 3. Log registration
        $act_type = 'register';
        $status = 1;
        $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
        $log_stmt->bind_param("sssi", $partner_id, $act_type, $now, $status);
        $log_stmt->execute();
        $log_stmt->close();

        // 4. Generate and Save OTP
        $otp = rand(1000, 9999);

        // Expire previous codes for this mobile number
        $expire_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE u_Id = ? AND status = 0");
        $expire_stmt->bind_param("s", $mobile_no);
        $expire_stmt->execute();
        $expire_stmt->close();

        // Insert new code
        $otp_stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
        $otp_stmt->bind_param("sis", $mobile_no, $otp, $now);

        if ($otp_stmt->execute()) {
            echo json_encode([
                "success" => true,
                "message" => "Partner registered and OTP generated",
                "data" => $partner_data,
                "debug_otp" => $otp,
                "db_status" => "OTP Saved Successfully"
            ]);
        } else {
            echo json_encode([
                "success" => true, 
                "message" => "Registration successful but failed to save OTP",
                "data" => $partner_data,
                "db_status" => "OTP Save Failed: " . $otp_stmt->error
            ]);
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
