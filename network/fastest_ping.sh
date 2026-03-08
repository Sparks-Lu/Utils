#!/bin/bash

# List of domains or URLs
# Full URLs are supported — script extracts domain automatically
urls=(
    "https://docker.1panel.live"
    "https://docker.1ms.run"
    "https://dytt.online"
    "https://docker-0.unsee.tech"
    "https://lispy.org"
    "https://docker.xiaogenban1993.com"
    "https://666860.xyz"
    "https://hub.rat.dev"
    "https://docker.m.daocloud.io"
    "https://demo.52013120.xyz"
    "https://proxy.vvvv.ee"
    "https://registry.cyou"
    "https://mirror.ccs.tencentyun.com"
)

# Temporary file to store results
results_file=$(mktemp)

# Number of pings per host
count=5

echo "📊 Pinging $count times for each domain to calculate average response time..."

# Function to extract domain from URL (remove protocol, path, etc.)
extract_domain() {
    local url="$1"
    # Remove protocol (http://, https://, etc.)
    domain="${url#*://}"
    # Remove path, query, fragment (keep only host)
    domain="${domain%%/*}"
    # Remove port if present
    domain="${domain%:*}"
    echo "$domain"
}

# Loop through each URL
for url in "${urls[@]}"; do
    domain=$(extract_domain "$url")

    # Validate domain (basic check)
    if [[ -z "$domain" ]]; then
        echo "❌ Invalid URL: $url"
        continue
    fi

    echo "📡 Pinging $domain ..."

    # Run ping, extract average time
    avg_time=$(ping -c "$count" "$domain" 2>/dev/null | \
               grep 'avg' | \
               awk -F'/' '{print $5}' 2>/dev/null)

    if [[ -n "$avg_time" ]]; then
        printf "✅ %s: %.2f ms\n" "$domain" "$avg_time"
        echo "$domain $avg_time" >> "$results_file"
    else
        echo "❌ Failed to ping $domain"
    fi
done

# Check if any results were recorded
if [[ ! -s "$results_file" ]]; then
    echo "❌ No successful ping results."
    rm -f "$results_file"
    exit 1
fi

# Find the domain with the lowest average time
fastest=$(sort -k2 -n "$results_file" | head -n1)

if [[ -n "$fastest" ]]; then
    fastest_domain=$(echo "$fastest" | awk '{print $1}')
    fastest_time=$(echo "$fastest" | awk '{print $2}')
    echo ""
    echo "🏆 Fastest Domain: $fastest_domain"
    echo "⏱️  Average Latency: $fastest_time ms"
else
    echo "❌ Could not determine fastest domain."
fi

# Cleanup
rm -f "$results_file"
