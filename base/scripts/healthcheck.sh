#!/bin/bash
# DBSDK Health Check Script
# Validates container health and readiness

set -e

# Check if essential services are available
check_basic_tools() {
    command -v git >/dev/null 2>&1 || { echo "Git not available"; exit 1; }
    command -v curl >/dev/null 2>&1 || { echo "Curl not available"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "JQ not available"; exit 1; }
}

# Check file system health
check_filesystem() {
    [[ -d /workspaces ]] || { echo "Workspace directory missing"; exit 1; }
    [[ -w /workspaces ]] || { echo "Workspace not writable"; exit 1; }
    [[ -d /opt/dbsdk ]] || { echo "DBSDK directory missing"; exit 1; }
}

# Check DBSDK components
check_dbsdk_components() {
    [[ -f /opt/dbsdk/sbom.json ]] || { echo "SBOM not found"; }
    [[ -x /opt/dbsdk/telemetry/telemetry-service.sh ]] || { echo "Telemetry service not executable"; }
}

# Run all checks
main() {
    echo "DBSDK Health Check..."
    
    check_basic_tools
    check_filesystem
    check_dbsdk_components
    
    echo "Container healthy"
    echo "DBSDK v${DBSDK_VERSION:-unknown} ready"
    
    exit 0
}

main "$@"