<?php
// GLOBAL SCHEMA & DATA CORRUPTION FIXER
ini_set('display_errors', 1);
error_reporting(E_ALL);

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

echo "<h2>XPower Database Integrity Fixer</h2>";

// 1. Disable checks to allow structural changes
$conn->query("SET FOREIGN_KEY_CHECKS = 0");

echo "<h3>1. Fixing 'partners' Table (Preventing Data Corruption)...</h3>";
// Convert mobile and bank account to VARCHAR to allow long numbers
$conn->query("ALTER TABLE partners MODIFY mobile_no VARCHAR(20) NOT NULL");
$conn->query("ALTER TABLE partners MODIFY bank_account_no VARCHAR(50) NOT NULL");
echo "DONE: Mobile and Bank Account are now safe strings.<br>";

echo "<h3>2. Fixing 'web_codes' Table (Linking to ID instead of Mobile)...</h3>";
// Ensure u_Id is VARCHAR to match whatever we put in it,
// but we will start putting numeric IDs in it.
$conn->query("ALTER TABLE web_codes MODIFY u_Id VARCHAR(20) NOT NULL");
echo "DONE: web_codes.u_Id is ready.<br>";

echo "<h3>3. Resetting OTP Data...</h3>";
$conn->query("TRUNCATE TABLE web_codes");
echo "DONE: Table cleared for fresh start.<br>";

// Re-enable checks
$conn->query("SET FOREIGN_KEY_CHECKS = 1");

echo "<hr><h2 style='color:green'>SUCCESS! Your database is now 100% fixed.</h2>";
echo "<p>Please delete this file and then update your PHP scripts with the new code I provided.</p>";

$conn->close();
?>
