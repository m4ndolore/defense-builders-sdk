#!/bin/bash
# DBSDK Version Discovery Library
# GitHub API-based SDK version discovery for multiple defense SDKs
# https://github.com/iotactical/defense-builders-sdk

set -e

# Discovery configuration
GITHUB_API_BASE="https://api.github.com"
GITHUB_ORG="${GITHUB_ORG:-iotactical}"
DISCOVERY_CACHE_TTL="${DISCOVERY_CACHE_TTL:-300}" # 5 minutes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
discovery_log_info() { echo -e "${BLUE}[DISCOVERY]${NC} $1"; }
discovery_log_success() { echo -e "${GREEN}[DISCOVERY]${NC} ✓ $1"; }
discovery_log_warn() { echo -e "${YELLOW}[DISCOVERY]${NC} ⚠ $1"; }
discovery_log_error() { echo -e "${RED}[DISCOVERY]${NC} ✗ $1"; }
discovery_log_debug() { [[ "${DBSDK_DEBUG:-}" == "true" ]] && echo -e "${PURPLE}[DISCOVERY DEBUG]${NC} $1"; }

# SDK repository patterns
declare -A SDK_PATTERNS=(
    ["atak-civ"]="ATAK-CIV-*-SDK"
    ["wintak"]="WinTAK-*-SDK"
    ["tak-server"]="TAK-Server-*-SDK"
    ["atak-forwarder"]="ATAK-Forwarder-*-SDK"
)

declare -A SDK_BRANCH_PATTERNS=(
    ["atak-civ"]="atak-civ-*"
    ["wintak"]="wintak-*"
    ["tak-server"]="tak-server-*"
    ["atak-forwarder"]="atak-forwarder-*"
)

declare -A SDK_VERSION_PATTERNS=(
    ["atak-civ"]="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
    ["wintak"]="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
    ["tak-server"]="[0-9]+\.[0-9]+\.[0-9]+"
    ["atak-forwarder"]="[0-9]+\.[0-9]+\.[0-9]+"
)

# GitHub API authentication check
check_github_auth() {
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        discovery_log_warn "GITHUB_TOKEN not set - using unauthenticated API (rate limited)"
        return 1
    else
        discovery_log_debug "GitHub token available - using authenticated API"
        return 0
    fi
}

# Make GitHub API request with authentication and rate limiting
github_api_request() {
    local endpoint="$1"
    local per_page="${2:-100}"
    local page="${3:-1}"
    
    local auth_header=""
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        auth_header="Authorization: token $GITHUB_TOKEN"
    fi
    
    discovery_log_debug "API request: $endpoint (page=$page, per_page=$per_page)"
    
    local response
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        ${auth_header:+-H "$auth_header"} \
        "$GITHUB_API_BASE$endpoint?per_page=$per_page&page=$page")
    
    # Check for API rate limit
    if echo "$response" | jq -e '.message | contains("rate limit")' >/dev/null 2>&1; then
        discovery_log_error "GitHub API rate limit exceeded"
        return 1
    fi
    
    echo "$response"
}

# Discover all repositories for an SDK type
discover_sdk_repositories() {
    local sdk_type="$1"
    
    if [[ -z "${SDK_PATTERNS[$sdk_type]:-}" ]]; then
        discovery_log_error "Unknown SDK type: $sdk_type"
        return 1
    fi
    
    local repo_pattern="${SDK_PATTERNS[$sdk_type]}"
    discovery_log_info "Discovering repositories for $sdk_type (pattern: $repo_pattern)"
    
    local repositories=()
    local page=1
    local has_more=true
    
    while [[ "$has_more" == "true" ]]; do
        local response
        response=$(github_api_request "/orgs/$GITHUB_ORG/repos" 100 "$page")
        
        if [[ $? -ne 0 ]]; then
            discovery_log_error "Failed to fetch repositories from GitHub API"
            return 1
        fi
        
        # Parse repository names matching the pattern
        local page_repos
        page_repos=$(echo "$response" | jq -r '.[] | select(.name | test("'"${repo_pattern//\*/.*}"'")) | .name' 2>/dev/null)
        
        if [[ -n "$page_repos" ]]; then
            while IFS= read -r repo_name; do
                repositories+=("$repo_name")
            done <<< "$page_repos"
        fi
        
        # Check if there are more pages
        local current_page_count
        current_page_count=$(echo "$response" | jq '. | length' 2>/dev/null || echo "0")
        
        if [[ "$current_page_count" -lt 100 ]]; then
            has_more=false
        else
            ((page++))
        fi
    done
    
    discovery_log_success "Found ${#repositories[@]} repositories for $sdk_type"
    printf '%s\n' "${repositories[@]}" | sort
}

# Extract version from repository name
extract_version_from_repo() {
    local sdk_type="$1"
    local repo_name="$2"
    
    local version_pattern="${SDK_VERSION_PATTERNS[$sdk_type]:-[0-9]+\.[0-9]+\.[0-9]+}"
    
    # Extract version using the SDK-specific pattern
    local version
    version=$(echo "$repo_name" | grep -oE "$version_pattern" | head -1)
    
    if [[ -n "$version" ]]; then
        echo "$version"
        return 0
    else
        discovery_log_debug "Could not extract version from repo: $repo_name"
        return 1
    fi
}

# Check if a repository has the expected version branch
check_version_branch() {
    local sdk_type="$1"
    local repo_name="$2"
    local version="$3"
    
    local expected_branch="${sdk_type}-${version}"
    discovery_log_debug "Checking for branch '$expected_branch' in $repo_name"
    
    local response
    response=$(github_api_request "/repos/$GITHUB_ORG/$repo_name/branches")
    
    if [[ $? -ne 0 ]]; then
        discovery_log_warn "Failed to fetch branches for $repo_name"
        return 1
    fi
    
    # Check if expected branch exists
    local branch_exists
    branch_exists=$(echo "$response" | jq -r ".[] | select(.name == \"$expected_branch\") | .name" 2>/dev/null)
    
    if [[ "$branch_exists" == "$expected_branch" ]]; then
        discovery_log_debug "✓ Branch '$expected_branch' found in $repo_name"
        return 0
    else
        discovery_log_debug "✗ Branch '$expected_branch' not found in $repo_name"
        return 1
    fi
}

# Get repository metadata
get_repository_metadata() {
    local repo_name="$1"
    
    local response
    response=$(github_api_request "/repos/$GITHUB_ORG/$repo_name")
    
    if [[ $? -ne 0 ]]; then
        discovery_log_warn "Failed to fetch metadata for $repo_name"
        return 1
    fi
    
    # Extract key metadata
    local created_at updated_at description private_repo
    created_at=$(echo "$response" | jq -r '.created_at // "unknown"')
    updated_at=$(echo "$response" | jq -r '.updated_at // "unknown"')
    description=$(echo "$response" | jq -r '.description // ""')
    private_repo=$(echo "$response" | jq -r '.private // false')
    
    # Return as JSON
    jq -n \
        --arg name "$repo_name" \
        --arg created_at "$created_at" \
        --arg updated_at "$updated_at" \
        --arg description "$description" \
        --argjson private "$private_repo" \
        '{
            name: $name,
            created_at: $created_at,
            updated_at: $updated_at,
            description: $description,
            private: $private,
            url: "https://github.com/'$GITHUB_ORG'/\($name)"
        }'
}

# Discover versions for an SDK type with full validation
discover_sdk_versions_full() {
    local sdk_type="$1"
    local validate_branches="${2:-true}"
    local include_metadata="${3:-false}"
    
    discovery_log_info "Starting full discovery for SDK type: $sdk_type"
    
    # Get all repositories for this SDK type
    local repositories
    mapfile -t repositories < <(discover_sdk_repositories "$sdk_type")
    
    if [[ ${#repositories[@]} -eq 0 ]]; then
        discovery_log_warn "No repositories found for SDK type: $sdk_type"
        return 1
    fi
    
    local valid_versions=()
    local version_metadata=()
    
    for repo_name in "${repositories[@]}"; do
        discovery_log_debug "Processing repository: $repo_name"
        
        # Extract version from repository name
        local version
        if ! version=$(extract_version_from_repo "$sdk_type" "$repo_name"); then
            discovery_log_warn "Skipping $repo_name - could not extract version"
            continue
        fi
        
        # Validate branch exists if requested
        if [[ "$validate_branches" == "true" ]]; then
            if ! check_version_branch "$sdk_type" "$repo_name" "$version"; then
                discovery_log_warn "Skipping $repo_name - missing expected branch ${sdk_type}-${version}"
                continue
            fi
        fi
        
        # Add to valid versions
        valid_versions+=("$version")
        
        # Collect metadata if requested
        if [[ "$include_metadata" == "true" ]]; then
            local metadata
            if metadata=$(get_repository_metadata "$repo_name"); then
                # Add version and SDK type to metadata
                metadata=$(echo "$metadata" | jq --arg version "$version" --arg sdk_type "$sdk_type" \
                    '. + {version: $version, sdk_type: $sdk_type, branch: "\($sdk_type)-\($version)"}')
                version_metadata+=("$metadata")
            fi
        fi
    done
    
    if [[ ${#valid_versions[@]} -eq 0 ]]; then
        discovery_log_error "No valid versions found for SDK type: $sdk_type"
        return 1
    fi
    
    # Sort versions semantically
    local sorted_versions
    mapfile -t sorted_versions < <(printf '%s\n' "${valid_versions[@]}" | sort -V)
    
    discovery_log_success "Discovered ${#sorted_versions[@]} valid versions for $sdk_type: ${sorted_versions[*]}"
    
    if [[ "$include_metadata" == "true" ]]; then
        # Return JSON with versions and metadata
        jq -n \
            --argjson versions "$(printf '%s\n' "${sorted_versions[@]}" | jq -R . | jq -s .)" \
            --argjson metadata "$(printf '%s\n' "${version_metadata[@]}" | jq -s .)" \
            --arg sdk_type "$sdk_type" \
            '{
                sdk_type: $sdk_type,
                versions: $versions,
                metadata: $metadata,
                discovered_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
            }'
    else
        # Return just the versions as JSON array
        printf '%s\n' "${sorted_versions[@]}" | jq -R . | jq -s .
    fi
}

# Discover versions for an SDK type (simple interface)
discover_sdk_versions() {
    local sdk_type="$1"
    
    discover_sdk_versions_full "$sdk_type" "true" "false" | jq -r '.[]' 2>/dev/null || {
        # Fallback to basic discovery without JSON parsing
        discover_sdk_versions_full "$sdk_type" "true" "false" | sed 's/[][]//g; s/"//g; s/,/\n/g' | grep -v '^$'
    }
}

# Discover all SDK types and their versions
discover_all_sdk_versions() {
    local include_metadata="${1:-false}"
    
    discovery_log_info "Discovering versions for all SDK types"
    
    local all_results=()
    
    for sdk_type in "${!SDK_PATTERNS[@]}"; do
        discovery_log_info "Processing SDK type: $sdk_type"
        
        local result
        if result=$(discover_sdk_versions_full "$sdk_type" "true" "$include_metadata"); then
            if [[ "$include_metadata" == "true" ]]; then
                all_results+=("$result")
            else
                # Simple format: SDK_TYPE:VERSION,VERSION,...
                local versions
                versions=$(echo "$result" | jq -r 'join(",")')
                if [[ -n "$versions" && "$versions" != "null" ]]; then
                    echo "${sdk_type}:${versions}"
                fi
            fi
        else
            discovery_log_warn "Failed to discover versions for $sdk_type"
        fi
    done
    
    if [[ "$include_metadata" == "true" ]]; then
        # Return as combined JSON
        printf '%s\n' "${all_results[@]}" | jq -s '.'
    fi
}

# Cache management
get_cache_file() {
    local sdk_type="$1"
    echo "/tmp/dbsdk-discovery-${sdk_type}-cache.json"
}

is_cache_valid() {
    local cache_file="$1"
    local ttl="$2"
    
    if [[ ! -f "$cache_file" ]]; then
        return 1
    fi
    
    local cache_age
    cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
    
    [[ $cache_age -lt $ttl ]]
}

# Cached discovery
discover_sdk_versions_cached() {
    local sdk_type="$1"
    local use_cache="${2:-true}"
    
    local cache_file
    cache_file=$(get_cache_file "$sdk_type")
    
    if [[ "$use_cache" == "true" ]] && is_cache_valid "$cache_file" "$DISCOVERY_CACHE_TTL"; then
        discovery_log_debug "Using cached results for $sdk_type"
        jq -r '.versions[]' "$cache_file" 2>/dev/null || {
            discovery_log_warn "Cache file corrupted, refreshing"
            rm -f "$cache_file"
            discover_sdk_versions_cached "$sdk_type" "false"
        }
    else
        discovery_log_debug "Refreshing cache for $sdk_type"
        local result
        if result=$(discover_sdk_versions_full "$sdk_type" "true" "true"); then
            echo "$result" > "$cache_file"
            echo "$result" | jq -r '.versions[]'
        else
            return 1
        fi
    fi
}

# Validation functions
validate_sdk_type() {
    local sdk_type="$1"
    
    if [[ -z "${SDK_PATTERNS[$sdk_type]:-}" ]]; then
        discovery_log_error "Unknown SDK type: $sdk_type"
        discovery_log_info "Supported SDK types: ${!SDK_PATTERNS[*]}"
        return 1
    fi
    
    return 0
}

validate_version_format() {
    local sdk_type="$1"
    local version="$2"
    
    local version_pattern="${SDK_VERSION_PATTERNS[$sdk_type]:-[0-9]+\.[0-9]+\.[0-9]+}"
    
    if [[ ! "$version" =~ ^${version_pattern}$ ]]; then
        discovery_log_error "Invalid version format for $sdk_type: $version"
        discovery_log_info "Expected pattern: $version_pattern"
        return 1
    fi
    
    return 0
}

# Export functions for use by other scripts
export -f discovery_log_info discovery_log_success discovery_log_warn discovery_log_error discovery_log_debug
export -f check_github_auth github_api_request discover_sdk_repositories extract_version_from_repo
export -f check_version_branch get_repository_metadata discover_sdk_versions_full discover_sdk_versions
export -f discover_all_sdk_versions discover_sdk_versions_cached validate_sdk_type validate_version_format