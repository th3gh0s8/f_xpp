<?php
$id = (int)($_GET['id'] ?? 0);
if ($id == 0) { header("Location: partners.php"); exit; }
ob_start(); include 'header.php';

// Fetch schema to build form dynamically
$result_meta = $conn->query("SELECT * FROM partners LIMIT 1");
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
    
    $sql = "UPDATE partners SET " . implode(', ', $updates) . " WHERE ID = ?";
    $stmt = $conn->prepare($sql);
    
    $types .= "i";
    $values[] = $id;
    
    $stmt->bind_param($types, ...$values);
    
    if ($stmt->execute()) {
        header("Location: partners.php?msg=updated");
        exit;
    } else {
        echo "<div class='alert alert-danger'>Update failed: " . $conn->error . "</div>";
    }
}

$partner = $conn->query("SELECT * FROM partners WHERE ID = $id")->fetch_assoc();
if (!$partner) { echo "Partner not found"; include 'footer.php'; exit; }
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Edit Partner: <?php echo htmlspecialchars($partner['first_name'] . ' ' . $partner['last_name']); ?></h2>
    <a href="partners.php" class="btn btn-secondary">Back to List</a>
</div>

<form method="POST" class="card shadow-sm">
    <div class="card-body">
        <div class="row">
            <?php foreach ($fields as $field): ?>
                <?php if ($field->name == 'ID') continue; ?>
                <div class="col-md-4 mb-3">
                    <label class="form-label small fw-bold text-uppercase"><?php echo str_replace('_', ' ', $field->name); ?></label>
                    <?php
                        $val = $partner[$field->name];
                        $name = $field->name;
                        
                        // Basic dynamic input logic
                        if (strpos($field->name, 'email') !== false) {
                            echo "<input type='email' name='$name' class='form-control' value='" . htmlspecialchars($val) . "'>";
                        } elseif (strpos($field->name, 'status') !== false) {
                            echo "<select name='$name' class='form-control'>";
                            foreach(['pending', 'authorized', 'unauthorized'] as $opt) {
                                $sel = ($val == $opt) ? 'selected' : '';
                                echo "<option value='$opt' $sel>" . strtoupper($opt) . "</option>";
                            }
                            echo "</select>";
                        } elseif (strpos($field->name, 'partner_type') !== false) {
                            echo "<select name='$name' class='form-control'>";
                            foreach(['freelancer', 'business'] as $opt) {
                                $sel = ($val == $opt) ? 'selected' : '';
                                echo "<option value='$opt' $sel>" . ucfirst($opt) . "</option>";
                            }
                            echo "</select>";
                        } elseif (strlen($val) > 100) {
                            echo "<textarea name='$name' class='form-control' rows='3'>" . htmlspecialchars($val) . "</textarea>";
                        } else {
                            echo "<input type='text' name='$name' class='form-control' value='" . htmlspecialchars($val) . "'>";
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
