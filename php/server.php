<?php

ignore_user_abort(true);

$response = json_encode([
  'message' => 'Hello from PHP (FrankenPHP Worker)',
  'timestamp' => time() * 1000
]);

$handler = function () use ($response) {
  header('Content-Type: application/json');
  echo $response;
};

for ($nbRequests = 0; frankenphp_handle_request($handler); ++$nbRequests) {
  // The worker loop
}
