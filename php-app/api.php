<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Database configuration
$host = getenv('DB_HOST') ?: 'mysql';
$dbname = getenv('DB_NAME') ?: 'testdb';
$username = getenv('DB_USER') ?: 'testuser';
$password = getenv('DB_PASS') ?: 'testpass';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Fetch "Hello World" from database
    $stmt = $pdo->query("SELECT message FROM messages WHERE id = 1");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result) {
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'message' => $result['message'],
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'status' => 'error',
            'message' => 'No message found'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
}
?>

