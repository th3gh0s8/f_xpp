<?php
// PRODUCTION OTP GENERATOR - ROBUST VERSION
header('Content-Type: application/json');

// Correct Path for db folder
if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Mobile number missing"]));
}

try {
    // 1. Search for partner
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
    $stmt->bind_param("s", $mobile_no);
    $stmt->execute();
    $partner = $stmt->get_result()->fetch_assoc();

    if ($partner) {
        $otp = rand(1111, 9999);
        $now = date('Y-m-d H:i:s');

        // 2. Clear old codes for this mobile number first
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no'");

        // 3. Simple Direct SQL to bypass strict server constraints
        $sql = "INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$mobile_no', $otp, '$now', 0)";

        if ($conn->query($sql)) {
            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp,
                "db_status" => "OTP Saved Successfully"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Database rejected OTP save",
                "error" => $conn->error
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Mobile number $mobile_no not found"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
