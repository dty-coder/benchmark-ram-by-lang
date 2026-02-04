#!/bin/bash

# Generate comparison table from benchmark results

echo "# RAM Consumption Comparison"
echo ""
echo "| Runtime | Idle Memory (MB) | Warm Memory (MB) | Memory Growth | Compile Time |"
echo "|---------|------------------|------------------|---------------|--------------|"

for runtime in zig rust go java bun node php; do
    if [ -f "results/${runtime}_summary.txt" ]; then
        data=$(cat "results/${runtime}_summary.txt")
        idle=$(echo $data | cut -d',' -f1)
        warm=$(echo $data | cut -d',' -f2)
        growth=$(echo "scale=2; $warm - $idle" | bc)
        
        build_time="-"
        if [ -f "results/${runtime}_build_time.txt" ]; then
            bt=$(cat "results/${runtime}_build_time.txt")
            if [ "$bt" -eq "0" ]; then
                build_time="N/A"
            else
                # Convert ms to seconds if > 1000
                if [ "$bt" -gt 1000 ]; then
                    build_time=$(echo "scale=2; $bt / 1000" | bc)s
                else
                    build_time="${bt}ms"
                fi
            fi
        fi

        # Format runtime name
        case $runtime in
            "bun") name="Bun" ;;
            "node") name="Node.js" ;;
            "go") name="Go" ;;
            "java") name="Java (Native)" ;;
            "rust") name="Rust" ;;
            "zig") name="Zig" ;;
            "php") name="PHP (FrankenPHP)" ;;
        esac
        
        echo "| $name | $idle | $warm | +$growth | $build_time |"
    fi
done

echo ""
echo "## Notes"
echo "- **Idle Memory**: Memory usage immediately after server starts"
echo "- **Warm Memory**: Memory usage after 100 requests"
echo "- **Memory Growth**: Difference between warm and idle"
echo "- **Compile Time**: Time taken to produce the executable binary"
echo ""
echo "Test Date: $(date '+%Y-%m-%d %H:%M:%S')"
