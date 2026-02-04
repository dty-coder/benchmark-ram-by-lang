#!/bin/bash

# Memory measurement script
# Usage: ./measure.sh <PID> <runtime_name>

PID=$1
RUNTIME=$2
DURATION=30
INTERVAL=1

if [ -z "$PID" ] || [ -z "$RUNTIME" ]; then
    echo "Usage: ./measure.sh <PID> <runtime_name>"
    exit 1
fi

echo "Measuring memory for $RUNTIME (PID: $PID) for ${DURATION}s..."
echo "Time(s),RSS(KB),RSS(MB)" > "results/${RUNTIME}_memory.csv"

for i in $(seq 0 $DURATION); do
    # Get RSS in KB (Resident Set Size)
    RSS=$(ps -o rss= -p $PID 2>/dev/null)
    
    if [ -z "$RSS" ]; then
        echo "Process $PID not found!"
        exit 1
    fi
    
    RSS_MB=$(echo "scale=2; $RSS / 1024" | bc)
    echo "$i,$RSS,$RSS_MB" >> "results/${RUNTIME}_memory.csv"
    
    if [ $i -eq 0 ]; then
        echo "Idle: ${RSS_MB} MB"
    elif [ $i -eq 10 ]; then
        echo "Warm: ${RSS_MB} MB"
    elif [ $i -eq $DURATION ]; then
        echo "Final: ${RSS_MB} MB"
    fi
    
    sleep $INTERVAL
done

echo "Results saved to results/${RUNTIME}_memory.csv"
