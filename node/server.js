// Node.js Native HTTP Benchmark (Minimalist)
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Hello from Node.js (Native)',
    timestamp: Date.now()
  }));
});

const PORT = 3001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Node.js (Native) running on http://localhost:${PORT}`);
  console.log(`PID: ${process.pid}`);
});

