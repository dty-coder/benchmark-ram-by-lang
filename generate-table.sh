#!/bin/bash

# Generate comparison table from benchmark results

echo "# RAM Consumption Comparison"
echo ""
echo "| Runtime | Idle Memory (MB) | Warm Memory (MB) | Memory Growth |"
echo "|---------|------------------|------------------|---------------|"

for runtime in bun node go java rust; do
    if [ -f "results/${runtime}_summary.txt" ]; then
        data=$(cat "results/${runtime}_summary.txt")
        idle=$(echo $data | cut -d',' -f1)
        warm=$(echo $data | cut -d',' -f2)
        growth=$(echo "scale=2; $warm - $idle" | bc)
        
        # Format runtime name
        case $runtime in
            "bun") name="Bun" ;;
            "node") name="Node.js" ;;
            "go") name="Go" ;;
            "java") name="Java" ;;
            "rust") name="Rust" ;;
        esac
        
        echo "| $name | $idle | $warm | +$growth |"
    fi
done

echo ""
echo "## Notes"
echo "- **Idle Memory**: Memory usage immediately after server starts"
echo "- **Warm Memory**: Memory usage after 100 requests"
echo "- **Memory Growth**: Difference between warm and idle"
echo ""
echo "Test Date: $(date '+%Y-%m-%d %H:%M:%S')"
