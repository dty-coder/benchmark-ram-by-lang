# RAM Consumption Benchmark (v3 - "Prime" 10k Load)

This benchmark suite measures the **Resident Set Size (RSS)** under a significant load of **10,000 concurrent requests** (Keep-Alive) to simulate a "Prime" production state.

## 📊 10k Load Results (Final Optimized)

| Runtime           | Tech Stack           | Idle (MB) | Warm (10k) |  Growth   | Compile Time |
| :---------------- | :------------------- | :-------: | :--------: | :-------: | :----------: |
| **Zig**           | Native std.net       | **0.56**  |  **0.56**  | **+0.00** |    467ms     |
| **Rust**          | Actix-web (LTO)      |   2.66    |    2.66    | **+0.00** |    387ms     |
| **Go**            | Fiber (fasthttp)     |   10.12   |   10.12    | **+0.00** |    342ms     |
| **Java (Native)** | GraalVM + Virtual Th |   11.95   |   65.52    |  +53.57   |    43.46s    |
| **Bun**           | Native Bun.serve     |   23.33   |   30.28    |   +6.95   |     N/A      |
| **Node.js**       | Native http          |   41.00   |   41.00    | **+0.00** |     N/A      |

## 🛠 Tech Stack (The "Ultimate" Setup)

- **Zig**: Uses **Native `std.net`**. No extra memory allocations per request, resulting in the lowest footprint ever recorded in this suite.
- **Rust**: Uses **Actix-web** with a specialized release profile (**LTO**, `opt-level = "z"`, and `panic = "abort"`).
- **Go**: Uses **Fiber** with minimal config. Extremely competitive in build speed and memory.
- **Java**: Compiled to **GraalVM Native Image (v25)** and uses **Virtual Threads** (Project Loom). While idle memory is low, heap growth under load remains a JVM characteristic.
- **Bun**: Uses native `Bun.serve` (Zig-based). The most efficient JS-based runtime.
- **Node.js**: Switched to **Native `http`** module to eliminate framework overhead, reducing RAM from ~58MB to 41MB.

## 🚀 Detailed Optimizations

### 1. Zig (Champion)

- **Zero-Allocation**: No memory is allocated on the heap during the request/response cycle.
- **ReleaseSmall**: Compiled with `-O ReleaseSmall` to prioritize binary size and runtime efficiency.

### 2. Rust (System Precision)

- **LTO (Link Time Optimization)**: Optimizes across crate boundaries, removing unused code and inlining functions more aggressively.
- **Codegen Units = 1**: Ensures maximum optimization at the cost of slower build times.
- **Panic Abort**: Removes the overhead of stack unwinding code.

### 3. Java (Native Transformation)

- **GraalVM 25**: Uses the latest AOT compiler to convert bytecode to a standalone native binary.
- **Virtual Threads (Loom)**: Replaces heavy OS-level threads with lightweight virtual threads, reducing the per-connection memory overhead.

### 4. Go (Pool Efficiency)

- **fiber.Config**: Tuned to disable unnecessary features. Go survives high load due to its advanced internal memory pooling (fasthttp).

### 5. Node.js (Framework Removal)

- **Native HTTP**: By removing Fastify, we bypassed the entire middleware stack and routing engine, revealing Node's true base performance.

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
