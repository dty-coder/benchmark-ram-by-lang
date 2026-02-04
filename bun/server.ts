// Bun HTTP Server Benchmark
const server = Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response(
      JSON.stringify({
        message: "Hello from Bun",
        timestamp: Date.now(),
      }),
      {
        headers: {
          "Content-Type": "application/json",
        },
      }
    );
  },
});

console.log(`Bun server running on http://localhost:${server.port}`);
console.log(`PID: ${process.pid}`);

// Keep server running
process.on("SIGINT", () => {
  console.log("\nShutting down...");
  process.exit(0);
});
