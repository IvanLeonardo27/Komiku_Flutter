<?php
header("Access-Control-Allow-Origin: *");    
header("Content-Type: application/json");
include("db.php");

$comic_id = intval($_GET["comic_id"] ?? 0);
$user_id  = intval($_GET["user_id"] ?? 0);

if ($comic_id === 0 || $user_id === 0) {
    echo json_encode(["rating" => 0]);
    exit;
}

$sql = "SELECT rating FROM ratings WHERE comic_id = ? AND user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $comic_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    echo json_encode([
        "result" => "success",
        "rating" => floatval($row["rating"])
    ]);
} else {
    echo json_encode([
        "result" => "success",
        "rating" => 0
    ]);
}

$conn->close();
?>
