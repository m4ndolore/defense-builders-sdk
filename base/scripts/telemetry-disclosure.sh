#!/bin/bash
# DBSDK Telemetry Disclosure Script
# Shows users what telemetry we collect and how to opt out

set -e

PRIVACY_POLICY_URL="https://iotactical.co/privacy-policy"
SUPPORT_EMAIL="support@iotactical.co"

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

show_telemetry_disclosure() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}                    DBSDK TELEMETRY DISCLOSURE${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}Defense Builders SDK collects anonymous telemetry to improve the platform.${NC}"
    echo ""
    
    echo -e "${BOLD}${GREEN}WHAT WE COLLECT (Anonymous):${NC}"
    echo "  • SDK version and configuration"
    echo "  • Container performance metrics"
    echo "  • Feature usage analytics"
    echo "  • Error diagnostics (anonymized)"
    echo "  • System specifications (OS, memory, etc.)"
    echo ""
    
    echo -e "${BOLD}${RED}WHAT WE NEVER COLLECT:${NC}"
    echo "  • Source code content"
    echo "  • Personal information"
    echo "  • Proprietary data"
    echo "  • Project details"
    echo "  • Passwords or secrets"
    echo ""
    
    echo -e "${BOLD}${YELLOW}HOW TO OPT OUT:${NC}"
    echo "  Set environment variable: ${BOLD}DBSDK_TELEMETRY_ENABLED=false${NC}"
    echo "  In your container/environment:"
    echo "    export DBSDK_TELEMETRY_ENABLED=false"
    echo ""
    echo "  Or add to your .bashrc/.profile:"
    echo "    echo 'export DBSDK_TELEMETRY_ENABLED=false' >> ~/.bashrc"
    echo ""
    
    echo -e "${BOLD}TELEMETRY ENDPOINT:${NC}"
    echo "  Data is sent to: https://telemetry.iotactical.co/api/v1/events"
    echo ""
    
    echo -e "${BOLD}PRIVACY & SUPPORT:${NC}"
    echo "  • Privacy Policy: ${PRIVACY_POLICY_URL}"
    echo "  • Support: ${SUPPORT_EMAIL}"
    echo "  • All data collection is transparent and privacy-first"
    echo ""
    
    # Check current telemetry status
    local telemetry_status="${DBSDK_TELEMETRY_ENABLED:-true}"
    if [[ "$telemetry_status" == "true" ]]; then
        echo -e "${BOLD}${GREEN}CURRENT STATUS: Telemetry ENABLED${NC}"
        echo "  Helping improve DBSDK for the defense community"
    else
        echo -e "${BOLD}${YELLOW}CURRENT STATUS: Telemetry DISABLED${NC}"
        echo "  No data will be collected from this container"
    fi
    
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Thank you for supporting the defense development community!${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Show disclosure message
show_telemetry_disclosure

# Create a command for users to view this again
create_telemetry_command() {
    cat > /usr/local/bin/dbsdk-telemetry-info <<'EOF'
#!/bin/bash
# Command to show DBSDK telemetry information
/opt/dbsdk/scripts/telemetry-disclosure.sh
EOF
    chmod +x /usr/local/bin/dbsdk-telemetry-info
    
    echo "💡 Run 'dbsdk-telemetry-info' anytime to view this information again"
    echo ""
}

# Only create command if running as root (during container build)
if [[ $EUID -eq 0 ]]; then
    create_telemetry_command
fi