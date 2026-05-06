<?php
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$uploadDir = 'uploads/payment_slips/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// 1. Get the Partner ID or Mobile No
$partner_mobile = $_POST['partnerTb'] ?? '';
$partner_identifier = $partner_mobile; // Default to mobile number

if (!empty($partner_mobile)) {
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    $stmtP->bind_param("s", $partner_mobile);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    if ($p_res && isset($p_res['ID'])) {
        $partner_identifier = $p_res['ID']; // Use integer ID if available
    }
    $stmtP->close();
}

if (empty($partner_identifier)) {
    die(json_encode(['success' => false, 'message' => 'Partner identifier missing']));
}

// 2. Handle File Upload
$file_path = "";
if (isset($_FILES['payment_slip'])) {
    $file = $_FILES['payment_slip'];
    $file_name = time() . '_' . basename($file['name']);
    $target_file = $uploadDir . $file_name;

    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        $file_path = $target_file;
    } else {
        die(json_encode(['success' => false, 'message' => 'Failed to move uploaded file']));
    }
}

// 3. Insert Customer
$com_name = $_POST['com_name'] ?? '';
$com_address = $_POST['com_address'] ?? '';
$com_number = $_POST['com_number'] ?? '';
$admin_name = $_POST['admin_name'] ?? '';
$admin_number = $_POST['admin_number'] ?? '';
$com_area = $_POST['com_area'] ?? '';
$com_field = $_POST['com_field'] ?? '';
$remarks = $_POST['remarks'] ?? '-';
$additional_features = $_POST['additional_features'] ?? '-';

$sql = "INSERT INTO new_clients (partnerTb, com_name, com_address, com_number, admin_name, admin_number, com_area, com_field, remarks, additional_features, status, rDateTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', NOW())";

$stmt = $conn->prepare($sql);
// We bind as 's' (string) because partnerTb might be an ID or a mobile number
$stmt->bind_param("ssssssssss", $partner_identifier, $com_name, $com_address, $com_number, $admin_name, $admin_number, $com_area, $com_field, $remarks, $additional_features);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Customer registered successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
}

$conn->close();
?>
