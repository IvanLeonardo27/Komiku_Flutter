<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Enable error logging but disable HTML display to prevent invalid JSON response
error_reporting(E_ALL);
ini_set('display_errors', 0); 

try {
    include("db.php");

    if (!isset($conn) || $conn->connect_error) {
        echo json_encode(["result" => "failed", "error" => "DB connection failed"]);
        exit;
    }

    $title = $_POST["title"] ?? "";
    $description = $_POST["description"] ?? "";
    $poster_url = $_POST["poster_url"] ?? "";
    $author_id = intval($_POST["author_id"] ?? 0);
    $categories = $_POST["categories"] ?? "";

    if (empty($title) || empty($poster_url) || $author_id === 0) {
        echo json_encode(["result" => "failed", "error" => "Judul, Poster URL, dan Author ID wajib diisi"]);
        exit;
    }

    // Gunakan try-catch untuk menangani error execute (misal: constraint error, missing default values, dll)
    // Di PHP 8.1+, execute() melempar mysqli_sql_exception jika gagal.
    
    // Kita coba lakukan INSERT standar. Jika gagal karena missing default values,
    // catch block akan menangkap pesan errornya dengan detail.
    $sql = "INSERT INTO comics (title, description, poster_url, author_id) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        echo json_encode(["result" => "failed", "error" => "Prepare failed: " . $conn->error]);
        exit;
    }

    $stmt->bind_param("sssi", $title, $description, $poster_url, $author_id);
    
    if (!$stmt->execute()) {
        echo json_encode(["result" => "failed", "error" => "Execute failed: " . $stmt->error]);
        exit;
    }

    $comic_id = $conn->insert_id;

    // Insert kategori
    if (!empty($categories)) {
        $categoryNames = explode(",", $categories);
        foreach ($categoryNames as $catName) {
            $catName = trim($catName);
            $catStmt = $conn->prepare("SELECT id FROM categories WHERE name = ?");
            $catStmt->bind_param("s", $catName);
            $catStmt->execute();
            $catResult = $catStmt->get_result();
            if ($catRow = $catResult->fetch_assoc()) {
                $cat_id = $catRow["id"];

                // Insert ke comic_categories
                $relStmt = $conn->prepare("INSERT INTO comic_categories (comic_id, category_id) VALUES (?, ?)");
                $relStmt->bind_param("ii", $comic_id, $cat_id);
                $relStmt->execute();

                // Update comic_count
                $countStmt = $conn->prepare("UPDATE categories SET comic_count = comic_count + 1 WHERE id = ?");
                $countStmt->bind_param("i", $cat_id);
                $countStmt->execute();
            }
        }
    }

    echo json_encode([
        "result" => "success",
        "comic_id" => $comic_id
    ]);

} catch (Throwable $e) {
    echo json_encode([
        "result" => "failed",
        "error" => "Server error: " . $e->getMessage()
    ]);
}

if (isset($conn)) {
    $conn->close();
}
?>
