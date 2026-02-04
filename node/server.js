// Node.js Fastify Benchmark (Prime State)
const fastify = require('fastify')({ logger: false });

fastify.get('/', async (request, reply) => {
  return {
    message: 'Hello from Node.js (Fastify)',
    timestamp: Date.now()
  };
});

const start = async () => {
  try {
    await fastify.listen({ port: 3001, host: '0.0.0.0' });
    console.log(`Node.js (Fastify) running on http://localhost:3001`);
    console.log(`PID: ${process.pid}`);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

start();
