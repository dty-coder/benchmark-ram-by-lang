# RAM Consumption Benchmark (v3 - "Prime" 10k Load)

This benchmark suite measures the **Resident Set Size (RSS)** under a significant load of **10,000 concurrent requests** (Keep-Alive) to simulate a "Prime" production state.

## 📊 10k Load Results

| Runtime     | Tech Stack           | Idle (MB) | Warm (10k) |  Growth   |
| :---------- | :------------------- | :-------: | :--------: | :-------: |
| **Rust**    | Actix-web            |   3.38    |    3.38    | **+0.00** |
| **Go**      | Fiber (fasthttp)     |   10.11   |   10.11    | **+0.00** |
| **Java**    | GraalVM Native (v25) |   11.91   |   66.83    |  +54.92   |
| **Bun**     | Native Bun.serve     |   23.30   |   30.36    |   +7.06   |
| **Node.js** | Fastify              |   58.20   |   54.56    |  -3.64\*  |

_\*Node.js growth is negative due to Garbage Collection (GC) triggering immediately after the load test._

## 🛠 Tech Stack (The "Prime" Setup)

Each runtime was configured using its most performance-oriented, production-ready components:

- **Bun**: Uses **Native `Bun.serve`**. Written in Zig, it bypasses Node compatibility layers to communicate directly with the JavaScriptCore engine.
- **Node.js**: Uses **`Fastify`**. The industry benchmark for Node performance, utilizing Radix Tree routing and JIT-compiled JSON schema validation.
- **Go**: Uses **`Fiber`** (powered by `fasthttp`). It minimizes memory allocations by reusing Request/Response buffers, making it nearly "zero-allocation" under load.
- **Rust**: Uses **`Actix-web`**. A high-performance actor-based framework that consistently ranks at the top of world-wide benchmarks due to Rust's lack of GC.
- **Java**: Uses the **Built-in HTTP Server with a `FixedThreadPool`**, compiled into a **GraalVM Native Image (Oracle GraalVM 25)**. This eliminates JVM overhead by performing Ahead-of-Time (AOT) compilation, offering Go/Rust-like memory efficiency.

## 🧪 Methodology (10k Load)

1.  **High-Precision Tracking**: PIDs are extracted via `lsof -ti :port` to target only the actual binary/runtime.
2.  **Load Injection**: Used `ab -k -n 10000 -c 100` (Apache Benchmark with Keep-Alive).
3.  **Stability Delay**: A 5-second wait period after load injection to allow Garbage Collectors to settle before measuring "Warm Memory."

## 🔍 Key Insights

### The "Golden Triangle" (Rust, Go, Bun)

- **Bun** proves to be the most efficient choice for the JS/TS ecosystem, using ~50% less memory than Node.js while maintaining extremely stable growth (+1.25MB).

### Memory Stability

- **Bun vs Node.js**: While Node.js starts with a higher baseline, its memory growth (+6.08MB) is also nearly **5x higher** than Bun's, suggesting a more efficient memory management model in Bun (JavaScriptCore).
- **Java**: Shows the largest memory growth, which is typical of the JVM's "greedy" memory allocation strategy during warm-up.

---

### How to Run

```bash
cd ram-benchmark
chmod +x *.sh
./run-benchmarks.sh
```
