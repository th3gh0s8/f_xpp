<?php
// CRITICAL DEBUG VERSION - FIND THE SILENT FAILURE
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Empty mobile number"]));
}

try {
    // 1. Search for partner
    $stmt = $conn->prepare("SELECT first_name FROM partners WHERE mobile_no = ? LIMIT 1");
    $stmt->bind_param("s", $mobile_no);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $partner = $result->fetch_assoc();
        $otp = rand(1000, 9999);
        $now = date('Y-m-d H:i:s');

        // FORCE EXPIRE OLD
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no'");

        // 2. TRY THE INSERT
        $insert = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
        $insert->bind_param("sis", $mobile_no, $otp, $now);

        if ($insert->execute()) {
            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp
            ]);
        } else {
            // THIS WILL TELL US EXACTLY WHY IT FAILED (e.g. Constraint fails)
            echo json_encode([
                "success" => false,
                "message" => "DATABASE REJECTED INSERT",
                "sql_error" => $insert->error
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Mobile $mobile_no not found in partners table"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "PHP Crash: " . $e->getMessage()]);
}
$conn->close();
?>
