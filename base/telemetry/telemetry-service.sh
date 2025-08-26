#!/bin/bash
# DBSDK Privacy-First Telemetry Service
# Collects anonymous usage data to improve the platform
# NEVER collects source code or personal information

set -e

TELEMETRY_ENDPOINT="${DBSDK_TELEMETRY_ENDPOINT:-https://telemetry.iotactical.com/api/v1/events}"
TELEMETRY_ENABLED="${DBSDK_TELEMETRY_ENABLED:-true}"
SESSION_ID=$(uuidgen 2>/dev/null || echo "unknown-$(date +%s)")

# Check if telemetry is disabled
if [[ "$TELEMETRY_ENABLED" != "true" ]]; then
    echo "DBSDK Telemetry: Disabled by user preference"
    exit 0
fi

# Collect anonymous system information
collect_system_info() {
    local os_info=$(lsb_release -ds 2>/dev/null || echo "Unknown")
    local kernel_version=$(uname -r)
    local cpu_arch=$(uname -m)
    local memory_mb=$(free -m | awk '/^Mem:/{print $2}')
    local disk_gb=$(df -BG / | awk 'NR==2{gsub(/G/,"",$4); print $4}')
    
    cat <<EOF
{
    "event": "container_start",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "session_id": "$SESSION_ID",
    "dbsdk_version": "$DBSDK_VERSION",
    "system": {
        "os": "$os_info",
        "kernel": "$kernel_version",
        "arch": "$cpu_arch",
        "memory_mb": $memory_mb,
        "disk_gb": $disk_gb
    },
    "environment": {
        "sdk_type": "${DBSDK_SDK_TYPE:-unknown}",
        "sdk_version": "${DBSDK_SDK_VERSION:-unknown}",
        "codespace": "${CODESPACES:-false}",
        "ci": "${CI:-false}"
    }
}
EOF
}

# Send telemetry data
send_telemetry() {
    local payload="$1"
    
    # Use curl with timeout and retry
    curl -s -m 10 --retry 2 --retry-delay 1 \
        -X POST \
        -H "Content-Type: application/json" \
        -H "User-Agent: DBSDK/${DBSDK_VERSION}" \
        -d "$payload" \
        "$TELEMETRY_ENDPOINT" \
        >/dev/null 2>&1 || true
}

# Main execution
main() {
    echo "DBSDK Telemetry: Collecting anonymous usage data..."
    echo "   Privacy Policy: https://iotactical.com/privacy"
    echo "   Opt-out: Set DBSDK_TELEMETRY_ENABLED=false"
    
    local telemetry_data
    telemetry_data=$(collect_system_info)
    
    # Send in background to avoid blocking startup
    send_telemetry "$telemetry_data" &
    
    echo "DBSDK Telemetry: Data sent (anonymous)"
}

# Only run if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi