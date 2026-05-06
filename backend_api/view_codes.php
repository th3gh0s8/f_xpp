<?php
// THE TRUTH INSPECTOR - FIND THE MISSING DATA
header('Content-Type: text/html');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

require_once 'db_config.php';

echo "<h2>XPower Online Truth Inspector</h2>";

// 1. Identify which database we are ACTUALLY talking to
$db_name = "";
$res_db = $conn->query("SELECT DATABASE()");
if ($res_db) {
    $row_db = $res_db->fetch_row();
    $db_name = $row_db[0];
}

echo "<p style='background: #eee; padding: 10px;'>";
echo "<b>Server Time:</b> " . date('Y-m-d H:i:s') . "<br>";
echo "<b>Database Name:</b> <span style='color:blue'>" . $db_name . "</span><br>";
echo "<b>Unique Page ID:</b> " . uniqid() . " (Refresh to see this change)";
echo "</p>";

// 2. Try a "Force Insert" with a unique number to avoid any confusion
echo "<h3>1. Attempting Force Insert...</h3>";
$unique_mobile = "DEBUG_" . rand(100, 999);
$test_otp = 7777;
$now = date('Y-m-d H:i:s');

$test_insert = $conn->query("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$unique_mobile', $test_otp, '$now', 0)");

if ($test_insert) {
    $affected = $conn->affected_rows;
    echo "<span style='color:green'><b>SUCCESS:</b> Database accepted the row. Affected rows: $affected</span><br>";
    echo "Just saved User ID: <b>$unique_mobile</b><br>";
} else {
    echo "<span style='color:red'><b>FAILURE:</b> " . $conn->error . "</span><br>";
}

// 3. Show EVERYTHING in the table (Latest 15)
echo "<h3>2. Records in <span style='color:blue'>$db_name</span>:</h3>";
$res = $conn->query("SELECT * FROM web_codes ORDER BY time DESC LIMIT 15");

if ($res && $res->num_rows > 0) {
    echo "<table border='1' cellpadding='10' style='width:100%; border-collapse: collapse;'>";
    echo "<tr style='background:#ddd'><th>ID</th><th>User ID (u_Id)</th><th>OTP Code</th><th>Time</th><th>Status</th></tr>";
    while($row = $res->fetch_assoc()) {
        $is_new = ($row['u_Id'] == $unique_mobile) ? "style='background:#e1f5fe; font-weight:bold;'" : "";
        $status = ($row['status'] == 0) ? "<b style='color:green'>ACTIVE</b>" : "Expired";
        echo "<tr $is_new>";
        echo "<td>".$row['ID']."</td>";
        echo "<td>".$row['u_Id']."</td>";
        echo "<td><b>".$row['otp_code']."</b></td>";
        echo "<td>".$row['time']."</td>";
        echo "<td>".$status."</td>";
        echo "</tr>";
    }
    echo "</table>";
} else {
    echo "<p style='color:red'>No records found in table 'web_codes'.</p>";
}

$conn->close();
?>
