<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM payout_request WHERE partner_id = ? ORDER BY request_date DESC, request_time DESC");
$stmt->bind_param("s", $mobile_no);
$stmt->execute();
$result = $stmt->get_result();

$payouts = [];
while ($row = $result->fetch_assoc()) {
    $payouts[] = $row;
}

echo json_encode(["success" => true, "data" => $payouts]);

$stmt->close();
$conn->close();
?>
