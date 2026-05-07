<?php
// FINAL PRODUCTION STABILIZER - ROBUST OTP RE-GENERATION
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$raw_mobile = $_GET['mobile_no'] ?? '';
if (empty($raw_mobile)) {
    die(json_encode(["success" => false, "message" => "Mobile missing"]));
}

// 1. Normalize for search
$clean_no = preg_replace('/\D/', '', $raw_mobile);
$no_zero = ltrim($clean_no, '0');
$with_zero = '0' . $no_zero;

try {
    // 2. Find Partner
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ? OR mobile_no = ? LIMIT 1");
    $stmt->bind_param("ss", $no_zero, $with_zero);
    $stmt->execute();
    $partner = $stmt->get_result()->fetch_assoc();

    if ($partner) {
        $partner_id = $partner['ID'];
        $otp = rand(1111, 9999);
        $now = date('Y-m-d H:i:s');

        // 3. LOG THE ACTIVITY (Act Type 2 = Login Request)
        $conn->query("INSERT INTO login_activity (u_id, act_type, time, status) VALUES ($partner_id, 2, '$now', 0)");

        // 4. CRITICAL FIX: FORCE EXPIRE ALL OLD CODES FOR THIS USER
        // We use a direct query to ensure every single active code for this ID is invalidated
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$partner_id' OR u_Id = '$no_zero' OR u_Id = '$with_zero'");

        // 5. INSERT NEW ACTIVE OTP
        $sql = "INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$partner_id', $otp, '$now', 0)";

        if ($conn->query($sql)) {
            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp,
                "message" => "FRESH OTP generated and logged."
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Database rejected OTP save",
                "error" => $conn->error
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Partner not found for $no_zero"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
