#!/bin/bash
# DBSDK Framework - Abstract SDK Management System
# Extensible framework for managing multiple defense SDKs
# https://github.com/iotactical/defense-builders-sdk

set -e

# Framework configuration
DBSDK_FRAMEWORK_VERSION="1.0.0"
DBSDK_CONFIG_DIR="${DBSDK_CONFIG_DIR:-/etc/dbsdk}"
DBSDK_DATA_DIR="${DBSDK_DATA_DIR:-/var/lib/dbsdk}"
DBSDK_TEMP_DIR="${DBSDK_TEMP_DIR:-/tmp/dbsdk}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions with framework branding
framework_log_info() { echo -e "${BLUE}[DBSDK]${NC} $1"; }
framework_log_success() { echo -e "${GREEN}[DBSDK]${NC} ✓ $1"; }
framework_log_warn() { echo -e "${YELLOW}[DBSDK]${NC} ⚠ $1"; }
framework_log_error() { echo -e "${RED}[DBSDK]${NC} ✗ $1"; }
framework_log_debug() { [[ "${DBSDK_DEBUG:-}" == "true" ]] && echo -e "${PURPLE}[DBSDK DEBUG]${NC} $1"; }

# Framework initialization
initialize_framework() {
    framework_log_debug "Initializing DBSDK Framework v${DBSDK_FRAMEWORK_VERSION}"
    
    # Create required directories
    mkdir -p "$DBSDK_CONFIG_DIR" "$DBSDK_DATA_DIR" "$DBSDK_TEMP_DIR"
    
    # Create framework configuration if it doesn't exist
    local framework_config="$DBSDK_CONFIG_DIR/framework.conf"
    if [[ ! -f "$framework_config" ]]; then
        create_framework_config "$framework_config"
    fi
    
    # Source framework configuration
    source "$framework_config"
    
    framework_log_debug "Framework initialized successfully"
}

# Create default framework configuration
create_framework_config() {
    local config_file="$1"
    
    cat > "$config_file" << EOF
# DBSDK Framework Configuration
# Abstract SDK Management System
# Version: ${DBSDK_FRAMEWORK_VERSION}

# Framework settings
DBSDK_FRAMEWORK_VERSION="${DBSDK_FRAMEWORK_VERSION}"
DBSDK_FRAMEWORK_INITIALIZED=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Registry configuration
DBSDK_DEFAULT_REGISTRY="ghcr.io/iotactical"
DBSDK_DEFAULT_ORG="iotactical"

# SDK discovery settings
DBSDK_SDK_DISCOVERY_PATHS="/opt/sdks:/usr/local/sdks:$HOME/sdks"
DBSDK_SDK_CACHE_TTL=3600  # 1 hour

# Build configuration
DBSDK_DEFAULT_PLATFORMS="linux/amd64,linux/arm64"
DBSDK_DEFAULT_BASE_IMAGE="ghcr.io/iotactical/dbsdk-base:latest"

# Security settings
DBSDK_SECURITY_SCAN_ENABLED=true
DBSDK_SBOM_GENERATION_ENABLED=true
DBSDK_VULNERABILITY_THRESHOLD="HIGH"

# Telemetry configuration
DBSDK_TELEMETRY_ENDPOINT="https://telemetry.iotactical.co/api/v1/events"
DBSDK_TELEMETRY_ENABLED=true

# SDK type definitions and configurations loaded dynamically
DBSDK_KNOWN_SDK_TYPES="atak-civ wintak tak-server"
EOF

    framework_log_success "Framework configuration created: $config_file"
}

# Abstract SDK class definition
declare -A SDK_REGISTRY=()

# Register an SDK type with the framework
register_sdk_type() {
    local sdk_type="$1"
    local sdk_config="$2"
    
    if [[ -z "$sdk_type" || -z "$sdk_config" ]]; then
        framework_log_error "SDK type and configuration file required"
        return 1
    fi
    
    if [[ ! -f "$sdk_config" ]]; then
        framework_log_error "SDK configuration file not found: $sdk_config"
        return 1
    fi
    
    SDK_REGISTRY["$sdk_type"]="$sdk_config"
    framework_log_success "Registered SDK type: $sdk_type"
    framework_log_debug "SDK config: $sdk_config"
}

# Get SDK configuration for a type
get_sdk_config() {
    local sdk_type="$1"
    
    if [[ -z "${SDK_REGISTRY[$sdk_type]:-}" ]]; then
        framework_log_error "Unknown SDK type: $sdk_type"
        return 1
    fi
    
    echo "${SDK_REGISTRY[$sdk_type]}"
}

# List registered SDK types
list_sdk_types() {
    if [[ ${#SDK_REGISTRY[@]} -eq 0 ]]; then
        framework_log_warn "No SDK types registered"
        return 0
    fi
    
    framework_log_info "Registered SDK types:"
    for sdk_type in "${!SDK_REGISTRY[@]}"; do
        local config_file="${SDK_REGISTRY[$sdk_type]}"
        echo "  • $sdk_type -> $config_file"
    done
}

# SDK configuration validation
validate_sdk_config() {
    local sdk_config="$1"
    
    framework_log_debug "Validating SDK configuration: $sdk_config"
    
    # Check required fields
    local required_fields=(
        "SDK_TYPE"
        "SDK_NAME"
        "SDK_DESCRIPTION"
        "SDK_BASE_IMAGE"
        "SDK_VERSION_DISCOVERY"
        "SDK_BUILD_FUNCTION"
    )
    
    source "$sdk_config"
    
    local validation_errors=0
    for field in "${required_fields[@]}"; do
        if [[ -z "${!field:-}" ]]; then
            framework_log_error "Required field missing in SDK config: $field"
            ((validation_errors++))
        fi
    done
    
    if [[ $validation_errors -eq 0 ]]; then
        framework_log_success "SDK configuration valid: $sdk_config"
        return 0
    else
        framework_log_error "SDK configuration validation failed: $validation_errors errors"
        return 1
    fi
}

# Discover SDK versions for a registered type
discover_sdk_versions() {
    local sdk_type="$1"
    local config_file
    config_file=$(get_sdk_config "$sdk_type")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Source SDK configuration
    source "$config_file"
    
    framework_log_debug "Discovering versions for SDK type: $sdk_type"
    
    # Call SDK-specific version discovery function
    if declare -f "$SDK_VERSION_DISCOVERY" > /dev/null; then
        "$SDK_VERSION_DISCOVERY"
    else
        framework_log_error "Version discovery function not found: $SDK_VERSION_DISCOVERY"
        return 1
    fi
}

# Build SDK container for specific type and version
build_sdk_container() {
    local sdk_type="$1"
    local version="$2"
    local extra_args=("${@:3}")
    
    local config_file
    config_file=$(get_sdk_config "$sdk_type")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Source SDK configuration
    source "$config_file"
    
    framework_log_info "Building $SDK_NAME v$version container"
    framework_log_debug "Using build function: $SDK_BUILD_FUNCTION"
    
    # Set up build environment
    export DBSDK_BUILD_SDK_TYPE="$sdk_type"
    export DBSDK_BUILD_VERSION="$version"
    export DBSDK_BUILD_BASE_IMAGE="$SDK_BASE_IMAGE"
    export DBSDK_BUILD_REGISTRY="$DBSDK_DEFAULT_REGISTRY"
    export DBSDK_BUILD_PLATFORMS="$DBSDK_DEFAULT_PLATFORMS"
    
    # Call SDK-specific build function
    if declare -f "$SDK_BUILD_FUNCTION" > /dev/null; then
        "$SDK_BUILD_FUNCTION" "$version" "${extra_args[@]}"
    else
        framework_log_error "Build function not found: $SDK_BUILD_FUNCTION"
        return 1
    fi
}

# Generate SDK repository structure
create_sdk_repository() {
    local sdk_type="$1"
    local version="$2"
    local repo_name="$3"
    local branch_name="$4"
    
    local config_file
    config_file=$(get_sdk_config "$sdk_type")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    source "$config_file"
    
    framework_log_info "Creating repository for $SDK_NAME v$version"
    
    # Set up repository environment
    export DBSDK_REPO_SDK_TYPE="$sdk_type"
    export DBSDK_REPO_VERSION="$version"
    export DBSDK_REPO_NAME="$repo_name"
    export DBSDK_REPO_BRANCH="$branch_name"
    export DBSDK_REPO_REGISTRY="$DBSDK_DEFAULT_REGISTRY"
    export DBSDK_REPO_ORG="$DBSDK_DEFAULT_ORG"
    
    # Call SDK-specific repository creation function
    if declare -f "${SDK_REPO_FUNCTION:-}" > /dev/null; then
        "$SDK_REPO_FUNCTION" "$version" "$repo_name" "$branch_name"
    else
        framework_log_warn "No repository function defined for $sdk_type, using default"
        default_create_sdk_repository "$version" "$repo_name" "$branch_name"
    fi
}

# Default repository creation (can be overridden by SDK configs)
default_create_sdk_repository() {
    local version="$1"
    local repo_name="$2"
    local branch_name="$3"
    
    framework_log_info "Using default repository structure for version $version"
    
    # Create basic devcontainer structure
    local temp_repo="$DBSDK_TEMP_DIR/$repo_name"
    mkdir -p "$temp_repo/.devcontainer"
    
    # Generate devcontainer.json
    cat > "$temp_repo/.devcontainer/devcontainer.json" << EOF
{
    "name": "${DBSDK_REPO_SDK_TYPE^^} SDK v${version}",
    "image": "${DBSDK_REPO_REGISTRY}/${DBSDK_REPO_ORG}/dbsdk-${DBSDK_REPO_SDK_TYPE}:${version}",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-json",
                "redhat.vscode-yaml", 
                "ms-azuretools.vscode-docker"
            ]
        }
    },
    "forwardPorts": [8080],
    "postCreateCommand": "dbsdk version",
    "remoteUser": "vscode"
}
EOF

    # Generate README
    cat > "$temp_repo/README.md" << EOF
# ${DBSDK_REPO_SDK_TYPE^^} SDK v${version}

Development environment for ${DBSDK_REPO_SDK_TYPE^^} SDK version ${version}.

## Quick Start

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/${DBSDK_REPO_ORG}/${repo_name}?quickstart=1&ref=${branch_name})

## Container Image

\`${DBSDK_REPO_REGISTRY}/${DBSDK_REPO_ORG}/dbsdk-${DBSDK_REPO_SDK_TYPE}:${version}\`

Built with [Defense Builders SDK](https://github.com/iotactical/defense-builders-sdk).
EOF
    
    framework_log_success "Default repository structure created in: $temp_repo"
}

# Framework health check
framework_health_check() {
    framework_log_info "Running DBSDK Framework health check..."
    
    local health_status=0
    local checks_passed=0
    local checks_total=0
    
    # Check framework configuration
    ((checks_total++))
    if [[ -f "$DBSDK_CONFIG_DIR/framework.conf" ]]; then
        framework_log_success "Framework configuration: OK"
        ((checks_passed++))
    else
        framework_log_error "Framework configuration: MISSING"
        ((health_status++))
    fi
    
    # Check required directories
    ((checks_total++))
    if [[ -d "$DBSDK_DATA_DIR" && -d "$DBSDK_TEMP_DIR" ]]; then
        framework_log_success "Framework directories: OK"
        ((checks_passed++))
    else
        framework_log_error "Framework directories: MISSING"
        ((health_status++))
    fi
    
    # Check registered SDK types
    ((checks_total++))
    if [[ ${#SDK_REGISTRY[@]} -gt 0 ]]; then
        framework_log_success "Registered SDK types: ${#SDK_REGISTRY[@]}"
        ((checks_passed++))
    else
        framework_log_warn "No SDK types registered"
    fi
    
    # Check required tools
    local required_tools=("docker" "git" "jq" "curl")
    for tool in "${required_tools[@]}"; do
        ((checks_total++))
        if command -v "$tool" >/dev/null 2>&1; then
            framework_log_success "Tool '$tool': OK"
            ((checks_passed++))
        else
            framework_log_error "Tool '$tool': MISSING"
            ((health_status++))
        fi
    done
    
    # Summary
    echo ""
    framework_log_info "Health check complete: ${checks_passed}/${checks_total} checks passed"
    
    if [[ $health_status -eq 0 ]]; then
        framework_log_success "Framework health: HEALTHY"
        return 0
    else
        framework_log_error "Framework health: DEGRADED ($health_status issues)"
        return 1
    fi
}

# Framework version and info
framework_info() {
    cat << EOF
${CYAN}Defense Builders SDK Framework${NC}
Version: ${DBSDK_FRAMEWORK_VERSION}
Config: ${DBSDK_CONFIG_DIR}
Data: ${DBSDK_DATA_DIR}

${BLUE}Registered SDK Types:${NC}
EOF

    if [[ ${#SDK_REGISTRY[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for sdk_type in "${!SDK_REGISTRY[@]}"; do
            echo "  • $sdk_type"
        done
    fi
}

# Load SDK configurations from standard locations
load_sdk_configurations() {
    local config_patterns=(
        "$DBSDK_CONFIG_DIR/sdk-configs/*.conf"
        "/etc/dbsdk/sdk-configs/*.conf"
        "./sdk-configs/*.conf"
    )
    
    framework_log_debug "Loading SDK configurations..."
    local loaded_count=0
    
    for pattern in "${config_patterns[@]}"; do
        for config_file in $pattern; do
            if [[ -f "$config_file" ]]; then
                local sdk_type
                sdk_type=$(basename "$config_file" .conf)
                
                if validate_sdk_config "$config_file"; then
                    register_sdk_type "$sdk_type" "$config_file"
                    ((loaded_count++))
                else
                    framework_log_warn "Skipping invalid config: $config_file"
                fi
            fi
        done
    done
    
    framework_log_success "Loaded $loaded_count SDK configurations"
}

# Export framework functions for use by SDK configurations
export -f framework_log_info framework_log_success framework_log_warn framework_log_error framework_log_debug
export -f initialize_framework register_sdk_type get_sdk_config list_sdk_types
export -f validate_sdk_config discover_sdk_versions build_sdk_container create_sdk_repository
export -f framework_health_check framework_info load_sdk_configurations

# Auto-initialize framework if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    initialize_framework
    load_sdk_configurations
fi