#!/bin/bash

# Automated benchmark runner
set -e

echo "=== RAM Consumption Benchmark ==="
echo "Starting all runtime benchmarks..."
echo ""

# Create results directory
mkdir -p results

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

run_benchmark() {
    local runtime=$1
    local port=$2
    local start_cmd=$3
    local dir=$4
    
    echo -e "${BLUE}[$runtime]${NC} Starting server..."
    
    # Start server in background using exec to ensure PID is correct
    cd "$dir"
    # Use exec to replace the shell process with the actual runtime
    (exec $start_cmd) > "../results/${runtime}_output.log" 2>&1 &
    local pid=$!
    cd ..
    
    # Wait for server to start and port to be bound
    echo -e "${BLUE}[$runtime]${NC} Waiting for port $port..."
    local count=0
    while ! lsof -i :$port -t > /dev/null; do
        sleep 1
        count=$((count + 1))
        if [ $count -gt 10 ]; then
            echo -e "${BLUE}[$runtime]${NC} Timeout waiting for port! Check results/${runtime}_output.log"
            return 1
        fi
    done
    
    # Get the actual PID assigned to the port
    local actual_pid=$(lsof -i :$port -t | head -n 1)
    echo -e "${BLUE}[$runtime]${NC} Server started (Port PID: $actual_pid)"
    
    # Measure idle memory
    sleep 3
    local idle_mem=$(ps -o rss= -p $actual_pid | awk '{printf "%.2f", $1/1024}')
    echo -e "${BLUE}[$runtime]${NC} Idle memory: ${idle_mem} MB"
    
    # Send some requests to warm up
    echo -e "${BLUE}[$runtime]${NC} Warming up with 10,000 requests (Keep-Alive)..."
    if ! ab -k -n 10000 -c 100 "http://localhost:$port/" > "results/${runtime}_ab.log" 2>&1; then
        echo -e "${BLUE}[$runtime]${NC} Warning: ab reported some failures. Check results/${runtime}_ab.log"
    fi
    
    sleep 5
    local warm_mem=$(ps -o rss= -p $actual_pid | awk '{printf "%.2f", $1/1024}')
    echo -e "${BLUE}[$runtime]${NC} Warm memory (10k reqs): ${warm_mem} MB"
    
    # Load test with concurrent requests
    echo -e "${BLUE}[$runtime]${NC} Running load test..."
    echo "$idle_mem,$warm_mem" > "results/${runtime}_summary.txt"
    
    # Kill the server
    kill $pid 2>/dev/null || true
    wait $pid 2>/dev/null || true
    
    echo -e "${GREEN}[$runtime]${NC} Benchmark complete!"
    echo ""
}

# Run benchmarks
echo "Starting benchmarks..."
echo ""

# Build phases
echo "Pre-building binaries..."
cd go && go build -o server server.go && cd ..
cd java && javac Server.java && cd ..
cd rust && cargo build --release && cd ..

run_benchmark "bun" 3000 "bun server.ts" "bun"
run_benchmark "node" 3001 "node server.js" "node"
run_benchmark "go" 3002 "./server" "go"
run_benchmark "java" 3003 "java -Xms16m -Xmx64m -XX:+UseSerialGC Server" "java"
run_benchmark "rust" 3004 "./target/release/rust-benchmark" "rust"

echo ""
echo "=== Benchmark Complete ==="
echo "Results saved in results/ directory"
echo ""
echo "Generating comparison table..."
./generate-table.sh
