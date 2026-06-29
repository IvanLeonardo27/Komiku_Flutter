<?php
header("Access-Control-Allow-Origin: *");    
header("Content-Type: application/json");
include("db.php");

$comic_id = intval($_POST["comic_id"] ?? 0);
$user_id  = intval($_POST["user_id"] ?? 0);
$rating   = floatval($_POST["rating"] ?? 0.0);

if ($comic_id === 0 || $user_id === 0 || $rating <= 0) {
    echo json_encode(["result" => "failed", "error" => "Invalid inputs"]);
    exit;
}

// 1. Periksa apakah user sudah pernah memberi rating untuk komik ini (menggunakan rating bukan id)
$checkSql = "SELECT rating FROM ratings WHERE comic_id = ? AND user_id = ?";
$stmt = $conn->prepare($checkSql);
$stmt->bind_param("ii", $comic_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    // Jika sudah ada, update rating yang lama
    $updateSql = "UPDATE ratings SET rating = ? WHERE comic_id = ? AND user_id = ?";
    $stmt = $conn->prepare($updateSql);
    $stmt->bind_param("dii", $rating, $comic_id, $user_id);
    $stmt->execute();
} else {
    // Jika belum ada, masukkan rating baru
    $insertSql = "INSERT INTO ratings (comic_id, user_id, rating) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($insertSql);
    $stmt->bind_param("iid", $comic_id, $user_id, $rating);
    $stmt->execute();
}

// 2. Hitung ulang total ratings dan rata-rata rating untuk komik ini dari tabel ratings
$statsSql = "SELECT COUNT(rating) as total, AVG(rating) as avg_rating FROM ratings WHERE comic_id = ?";
$statsStmt = $conn->prepare($statsSql);
$statsStmt->bind_param("i", $comic_id);
$statsStmt->execute();
$statsRes = $statsStmt->get_result()->fetch_assoc();

$total_ratings = intval($statsRes["total"] ?? 0);
$avg_rating = floatval($statsRes["avg_rating"] ?? 0.0);

// 3. Update tabel comics dengan data rating terbaru
$updateComicSql = "UPDATE comics SET average_rating = ?, total_ratings = ? WHERE id = ?";
$updateComicStmt = $conn->prepare($updateComicSql);
$updateComicStmt->bind_param("dii", $avg_rating, $total_ratings, $comic_id);
$updateComicStmt->execute();

echo json_encode(["result" => "success"]);
$conn->close();
?>
