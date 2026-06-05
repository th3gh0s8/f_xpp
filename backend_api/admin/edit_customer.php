<?php
$id = (int)($_GET['id'] ?? 0);
if ($id == 0) { header("Location: customers.php"); exit; }
ob_start(); include 'header.php';

// Fetch schema to build form dynamically
$result_meta = $conn->query("SELECT * FROM new_clients LIMIT 1");
$fields = $result_meta->fetch_fields();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $updates = [];
    $types = "";
    $values = [];
    
    foreach ($fields as $field) {
        if ($field->name == 'ID') continue;
        
        $updates[] = "`{$field->name}` = ?";
        $values[] = $_POST[$field->name] ?? null;
        
        // Determine type for bind_param
        if (in_array($field->type, [3, 8, 9])) $types .= "i"; // integers
        elseif (in_array($field->type, [4, 5])) $types .= "d"; // doubles
        else $types .= "s"; // strings/others
    }
    
    $sql = "UPDATE new_clients SET " . implode(', ', $updates) . " WHERE ID = ?";
    $stmt = $conn->prepare($sql);
    
    $types .= "i";
    $values[] = $id;
    
    $stmt->bind_param($types, ...$values);
    
    if ($stmt->execute()) {
        header("Location: customers.php?msg=updated");
        exit;
    } else {
        echo "<div class='alert alert-danger'>Update failed: " . $conn->error . "</div>";
    }
}

$customer = $conn->query("SELECT * FROM new_clients WHERE ID = $id")->fetch_assoc();
if (!$customer) { echo "Customer not found"; include 'footer.php'; exit; }
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Edit Customer: <?php echo htmlspecialchars($customer['com_name']); ?></h2>
    <a href="customers.php" class="btn btn-secondary">Back to List</a>
</div>

<form method="POST" class="card shadow-sm">
    <div class="card-body">
        <div class="row">
            <?php foreach ($fields as $field): ?>
                <?php if ($field->name == 'ID') continue; ?>
                <div class="col-md-4 mb-3">
                    <label class="form-label small fw-bold text-uppercase"><?php echo str_replace('_', ' ', $field->name); ?></label>
                    <?php
                        $val = $customer[$field->name];
                        $name = $field->name;
                        
                        // Basic dynamic input logic
                        if ($field->name == 'status') {
                            echo "<select name='$name' class='form-control'>";
                            foreach(['pending', 'active'] as $opt) {
                                $sel = ($val == $opt) ? 'selected' : '';
                                echo "<option value='$opt' $sel>" . strtoupper($opt) . "</option>";
                            }
                            echo "</select>";
                        } elseif ($field->name == 'partnerTb') {
                            // Partner selection
                            $partners = $conn->query("SELECT ID, first_name, last_name FROM partners ORDER BY first_name ASC");
                            echo "<select name='$name' class='form-control'>";
                            while($p = $partners->fetch_assoc()) {
                                $sel = ($val == $p['ID']) ? 'selected' : '';
                                echo "<option value='{$p['ID']}' $sel>{$p['first_name']} {$p['last_name']} (ID: {$p['ID']})</option>";
                            }
                            echo "</select>";
                        } elseif ($field->name == 'preferred_lang') {
                            echo "<select name='$name' class='form-control'>";
                            foreach(['English','Tamil','Sinhala','Arabic','Hindi'] as $opt) {
                                $sel = ($val == $opt) ? 'selected' : '';
                                echo "<option value='$opt' $sel>$opt</option>";
                            }
                            echo "</select>";
                        } elseif (strlen($val) > 100 || strpos($field->name, 'address') !== false || strpos($field->name, 'remarks') !== false) {
                            echo "<textarea name='$name' class='form-control' rows='3'>" . htmlspecialchars($val) . "</textarea>";
                        } else {
                            $type = 'text';
                            if (strpos($field->name, 'Date') !== false || strpos($field->name, 'time') !== false) $type = 'datetime-local';
                            elseif (in_array($field->type, [3, 8, 9, 4, 5])) $type = 'number';
                            
                            echo "<input type='$type' name='$name' class='form-control' value='" . htmlspecialchars($val) . "'>";
                        }
                    ?>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
    <div class="card-footer bg-light text-end">
        <button type="submit" class="btn btn-primary px-5">Save Changes</button>
    </div>
</form>

<?php include 'footer.php'; ?>
