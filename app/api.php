<?php
header('Content-Type: application/json');

$host = 'mysql';
$dbname = 'testdb';
$username = 'testuser';
$password = 'testpassword';

try {
    $conn = new mysqli($host, $username, $password, $dbname);
    
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }
    
    $sql = "SELECT message FROM messages WHERE id = 1";
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            'status' => 'success',
            'message' => $row['message']
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'No data found'
        ]);
    }
    
    $conn->close();
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
?>

