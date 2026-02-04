// Rust HTTP Server Benchmark
use actix_web::{web, App, HttpResponse, HttpServer};
use serde::Serialize;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Serialize)]
struct Response {
    message: String,
    timestamp: u128,
}

async fn handler() -> HttpResponse {
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis();
    
    let response = Response {
        message: "Hello from Rust".to_string(),
        timestamp,
    };
    
    HttpResponse::Ok().json(response)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = 3004;
    println!("Rust server running on http://localhost:{}", port);
    println!("PID: {}", std::process::id());
    
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(handler))
    })
    .bind(("127.0.0.1", port))?
    .run()
    .await
}
