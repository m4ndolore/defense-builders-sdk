#!/bin/bash
# DBSDK Utility Library
# Common functions and utilities for DBSDK CLI

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# API endpoints
IOTACTICAL_API_BASE="${IOTACTICAL_API_BASE:-https://api.iotactical.co/v1}"
IOTACTICAL_AUTH_ENDPOINT="${IOTACTICAL_API_BASE}/auth/validate"
IOTACTICAL_SUBSCRIPTION_ENDPOINT="${IOTACTICAL_API_BASE}/user/subscription"

# Configuration
DBSDK_CONFIG_DIR="${HOME}/.dbsdk"
DBSDK_AUTH_TOKEN_FILE="${DBSDK_CONFIG_DIR}/auth_token"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_debug() {
    if [[ "${DBSDK_DEBUG:-false}" == "true" ]]; then
        echo -e "${DIM}[DEBUG]${NC} $1" >&2
    fi
}

# Premium feature check
check_premium_feature() {
    local feature_name="$1"
    
    log_debug "Checking premium feature: $feature_name"
    
    # Check if user has authentication token
    if [[ ! -f "$DBSDK_AUTH_TOKEN_FILE" ]]; then
        show_premium_prompt "$feature_name"
        return 1
    fi
    
    # Validate token and check subscription
    local auth_token
    auth_token=$(cat "$DBSDK_AUTH_TOKEN_FILE" 2>/dev/null || echo "")
    
    if [[ -z "$auth_token" ]]; then
        show_premium_prompt "$feature_name"
        return 1
    fi
    
    # Make API call to check subscription (with timeout and error handling)
    local subscription_status
    subscription_status=$(curl -s -m 10 \
        -H "Authorization: Bearer $auth_token" \
        -H "User-Agent: DBSDK/${DBSDK_VERSION}" \
        "$IOTACTICAL_SUBSCRIPTION_ENDPOINT" 2>/dev/null | \
        jq -r '.status // "inactive"' 2>/dev/null || echo "error")
    
    log_debug "Subscription status: $subscription_status"
    
    case "$subscription_status" in
        "active"|"premium"|"enterprise")
            log_debug "Premium feature authorized"
            return 0
            ;;
        "inactive"|"free")
            show_subscription_required "$feature_name"
            return 1
            ;;
        "error"|*)
            show_connection_error "$feature_name"
            return 1
            ;;
    esac
}

# Show premium feature prompt
show_premium_prompt() {
    local feature_name="$1"
    
    echo ""
    echo -e "${BOLD}${PURPLE}Premium Feature: $feature_name${NC}"
    echo -e "${BOLD}${PURPLE}═══════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}This feature requires an ioTACTICAL Premium subscription.${NC}"
    echo ""
    echo -e "${BOLD}What you get with Premium:${NC}"
    echo "  • Code signing and verification"
    echo "  • Automated release management"
    echo "  • STIG/RMF compliance artifacts"
    echo "  • Priority support"
    echo "  • Advanced security features"
    echo ""
    echo -e "${BOLD}Get started:${NC}"
    echo "  1. Visit: ${CYAN}https://iotactical.co/premium${NC}"
    echo "  2. Sign up for Premium access"
    echo "  3. Run: ${BOLD}dbsdk account login${NC}"
    echo ""
    echo -e "${DIM}Questions? Contact support@iotactical.co${NC}"
    echo ""
}

# Show subscription required message
show_subscription_required() {
    local feature_name="$1"
    
    echo ""
    echo -e "${YELLOW}Premium Subscription Required${NC}"
    echo -e "${YELLOW}═══════════════════════════════${NC}"
    echo ""
    echo -e "The ${BOLD}$feature_name${NC} feature requires an active Premium subscription."
    echo ""
    echo -e "Your current plan: ${BOLD}Free${NC}"
    echo ""
    echo -e "Upgrade at: ${CYAN}https://iotactical.co/premium${NC}"
    echo -e "Or contact: ${CYAN}support@iotactical.co${NC}"
    echo ""
}

# Show connection error
show_connection_error() {
    local feature_name="$1"
    
    echo ""
    echo -e "${RED}Connection Error${NC}"
    echo -e "${RED}═══════════════${NC}"
    echo ""
    echo -e "Unable to verify your Premium subscription for ${BOLD}$feature_name${NC}."
    echo ""
    echo -e "This could be due to:"
    echo "  • Network connectivity issues"
    echo "  • ioTACTICAL API temporarily unavailable"
    echo "  • Expired authentication token"
    echo ""
    echo -e "Try:"
    echo "  • Check your internet connection"
    echo "  • Run: ${BOLD}dbsdk account login${NC} to refresh your token"
    echo "  • Contact support@iotactical.co if the issue persists"
    echo ""
}

# Ensure config directory exists
ensure_config_dir() {
    if [[ ! -d "$DBSDK_CONFIG_DIR" ]]; then
        mkdir -p "$DBSDK_CONFIG_DIR"
        chmod 700 "$DBSDK_CONFIG_DIR"
        log_debug "Created config directory: $DBSDK_CONFIG_DIR"
    fi
}

# Safe file operations
safe_write_file() {
    local file_path="$1"
    local content="$2"
    
    ensure_config_dir
    echo "$content" > "$file_path"
    chmod 600 "$file_path"
    log_debug "Wrote to file: $file_path"
}

# JSON parsing helper
parse_json() {
    local json_string="$1"
    local key="$2"
    
    echo "$json_string" | jq -r ".$key // empty" 2>/dev/null || echo ""
}

# Validate email format
validate_email() {
    local email="$1"
    
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Format file size
format_file_size() {
    local size_bytes="$1"
    
    if (( size_bytes < 1024 )); then
        echo "${size_bytes} B"
    elif (( size_bytes < 1048576 )); then
        echo "$((size_bytes / 1024)) KB"
    elif (( size_bytes < 1073741824 )); then
        echo "$((size_bytes / 1048576)) MB"
    else
        echo "$((size_bytes / 1073741824)) GB"
    fi
}

# Get current timestamp
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Initialize library
log_debug "DBSDK library loaded"