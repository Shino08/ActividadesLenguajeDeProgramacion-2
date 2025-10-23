<?php
$emails = [
    $_POST['email_1'],
    $_POST['email_2'],
    $_POST['email_3']
];

$sanitizedEmails = [];
foreach ($emails as $email) {

    $sanitized = filter_var($email, FILTER_SANITIZE_EMAIL);
    
    if (filter_var($sanitized, FILTER_VALIDATE_EMAIL)) {
        $sanitizedEmails[] = $sanitized;
    } else {
        echo "Correo inválido detectado y descartado: " . htmlspecialchars($email) . "<br>";
    }
}
 
if (!empty($sanitizedEmails)) {
    echo "Correos validos y limpios:<br>";
    echo "<br>";
    foreach ($sanitizedEmails as $email) {
        echo htmlspecialchars($email) . "<br>";
    }
    echo "<br>";
    echo "<a href='index.html'>Volver</a>";
} else {
    echo "Ningún dato válido fue recibido.";
    echo "<br>";
    echo "<a href='index.html'>Volver</a>";
}
?>
