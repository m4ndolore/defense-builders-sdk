#!/bin/bash
# DBSDK Version Manager
# Automated ATAK-CIV SDK versioning and branch management system
# https://github.com/iotactical/defense-builders-sdk

set -e

# Configuration
GITHUB_ORG="iotactical"
SDK_REPO_PREFIX="ATAK-CIV"
DBSDK_REPO="defense-builders-sdk"
BASE_BRANCH="main"
SDK_DOWNLOAD_BASE="https://github.com/${GITHUB_ORG}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Help function
show_help() {
    cat << EOF
DBSDK Version Manager - Automated ATAK-CIV SDK Versioning

USAGE:
    sdk-version-manager.sh COMMAND [OPTIONS]

COMMANDS:
    list-versions           List available SDK versions
    import-version VERSION  Import a specific SDK version
    build-version VERSION   Build devcontainer for version
    sync-all               Sync all available versions
    create-branch VERSION  Create version branch
    update-matrix          Update build matrix configuration

EXAMPLES:
    sdk-version-manager.sh list-versions
    sdk-version-manager.sh import-version 5.5.0.5
    sdk-version-manager.sh build-version 5.4.0.21
    sdk-version-manager.sh sync-all

OPTIONS:
    -h, --help             Show this help message
    -v, --verbose          Enable verbose output
    --dry-run             Show what would be done without executing
    --force               Force overwrite existing branches/repos

ENVIRONMENT VARIABLES:
    DBSDK_GITHUB_TOKEN    GitHub token for API access
    DBSDK_TEMP_DIR        Temporary directory for SDK extraction (default: /tmp/dbsdk)
EOF
}

# Version parsing functions
parse_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format: $version (expected: X.Y.Z.W)"
        return 1
    fi
    echo "$version"
}

get_version_branch() {
    local version="$1"
    echo "atak-civ-${version}"
}

get_sdk_repo_name() {
    local version="$1"
    echo "${SDK_REPO_PREFIX}-${version}-SDK"
}

# GitHub API functions
check_repo_exists() {
    local repo_name="$1"
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${GITHUB_ORG}/${repo_name}")
    
    if [[ "$response" == "200" ]]; then
        return 0
    else
        return 1
    fi
}

create_github_repo() {
    local repo_name="$1"
    local description="$2"
    local private="${3:-false}"
    
    log_info "Creating GitHub repository: ${GITHUB_ORG}/${repo_name}"
    
    if [[ -z "$DBSDK_GITHUB_TOKEN" ]]; then
        log_error "DBSDK_GITHUB_TOKEN environment variable required for repo creation"
        return 1
    fi
    
    local payload=$(jq -n \
        --arg name "$repo_name" \
        --arg description "$description" \
        --argjson private "$private" \
        '{
            name: $name,
            description: $description,
            private: $private,
            has_issues: true,
            has_projects: false,
            has_wiki: false,
            auto_init: true,
            license_template: "mit"
        }')
    
    curl -s -X POST \
        -H "Authorization: token $DBSDK_GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        "https://api.github.com/orgs/${GITHUB_ORG}/repos" \
        -d "$payload" > /dev/null
    
    if [[ $? -eq 0 ]]; then
        log_success "Repository ${GITHUB_ORG}/${repo_name} created"
        return 0
    else
        log_error "Failed to create repository ${GITHUB_ORG}/${repo_name}"
        return 1
    fi
}

# SDK discovery functions
discover_sdk_versions() {
    log_info "Discovering available ATAK-CIV SDK versions..."
    
    # Check for local SDK zips first
    local versions=()
    for sdk_file in ~/Downloads/ATAK-CIV-*.zip; do
        if [[ -f "$sdk_file" ]]; then
            local filename=$(basename "$sdk_file")
            local version=$(echo "$filename" | sed -E 's/ATAK-CIV-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)-SDK\.zip/\1/')
            if [[ "$version" != "$filename" ]]; then
                versions+=("$version")
            fi
        fi
    done
    
    # Sort versions numerically
    printf '%s\n' "${versions[@]}" | sort -V
}

# SDK extraction and analysis
extract_sdk_metadata() {
    local sdk_path="$1"
    local temp_dir="${DBSDK_TEMP_DIR:-/tmp/dbsdk}/extract"
    
    mkdir -p "$temp_dir"
    
    log_info "Extracting SDK metadata from $(basename "$sdk_path")"
    
    # Extract just the metadata files
    unzip -q -j "$sdk_path" "*/main.jar" -d "$temp_dir" 2>/dev/null || true
    unzip -q -j "$sdk_path" "*/atak.apk" -d "$temp_dir" 2>/dev/null || true
    unzip -q -j "$sdk_path" "*/docs/*" -d "$temp_dir/docs" 2>/dev/null || true
    
    # Get file sizes and create manifest
    local manifest_file="$temp_dir/manifest.json"
    cat > "$manifest_file" << EOF
{
    "version": "$(basename "$sdk_path" | sed -E 's/ATAK-CIV-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)-SDK\.zip/\1/')",
    "extracted_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source_file": "$(basename "$sdk_path")",
    "file_sizes": {
        "main_jar": $(stat -c%s "$temp_dir/main.jar" 2>/dev/null || echo "0"),
        "atak_apk": $(stat -c%s "$temp_dir/atak.apk" 2>/dev/null || echo "0"),
        "total_sdk": $(stat -c%s "$sdk_path")
    },
    "capabilities": {
        "has_proguard": $(test -f "$temp_dir/proguard-release-keep.txt" && echo "true" || echo "false")
    }
}
EOF
    
    echo "$manifest_file"
}

# Branch management functions
create_version_branch() {
    local version="$1"
    local branch_name=$(get_version_branch "$version")
    local repo_name=$(get_sdk_repo_name "$version")
    
    log_info "Creating version branch: $branch_name"
    
    # Check if SDK repository exists, create if needed
    if ! check_repo_exists "$repo_name"; then
        log_warn "SDK repository $repo_name does not exist, creating..."
        create_github_repo "$repo_name" "ATAK-CIV SDK v${version} - Android Tactical Assault Kit (Civil)" "false"
    fi
    
    # Clone and set up the repository
    local temp_repo_dir="${DBSDK_TEMP_DIR:-/tmp/dbsdk}/${repo_name}"
    rm -rf "$temp_repo_dir"
    
    git clone "https://github.com/${GITHUB_ORG}/${repo_name}.git" "$temp_repo_dir"
    cd "$temp_repo_dir"
    
    # Create version-specific branch
    git checkout -b "$branch_name" || git checkout "$branch_name"
    
    # Add SDK-specific content
    setup_version_content "$version" "$temp_repo_dir"
    
    # Commit and push
    git add .
    git commit -m "Add ATAK-CIV SDK v${version} configuration

- SDK version: ${version}
- Branch: ${branch_name}
- Auto-generated by DBSDK Version Manager
- Compatible with Defense Builders SDK pipeline

🤖 Generated with [Defense Builders SDK](https://github.com/iotactical/defense-builders-sdk)"
    
    git push -u origin "$branch_name"
    
    log_success "Version branch $branch_name created and pushed"
}

setup_version_content() {
    local version="$1"
    local repo_dir="$2"
    local branch_name=$(get_version_branch "$version")
    
    # Create devcontainer configuration
    mkdir -p "$repo_dir/.devcontainer"
    
    cat > "$repo_dir/.devcontainer/devcontainer.json" << EOF
{
    "name": "ATAK-CIV SDK v${version}",
    "image": "ghcr.io/iotactical/dbsdk-atak-civ:${version}",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": true
        },
        "ghcr.io/devcontainers/features/docker-in-docker:2": {},
        "ghcr.io/devcontainers/features/github-cli:1": {}
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-json",
                "redhat.vscode-yaml",
                "ms-azuretools.vscode-docker",
                "GitHub.copilot",
                "GitHub.copilot-chat"
            ],
            "settings": {
                "terminal.integrated.defaultProfile.linux": "zsh",
                "java.configuration.updateBuildConfiguration": "interactive",
                "java.compile.nullAnalysis.mode": "automatic"
            }
        }
    },
    "forwardPorts": [8080, 3000],
    "postCreateCommand": "dbsdk version && dbsdk compliance-check",
    "remoteUser": "vscode",
    "workspaceFolder": "/workspaces",
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
    ]
}
EOF

    # Create README with version-specific information
    cat > "$repo_dir/README.md" << EOF
# ATAK-CIV SDK v${version}

Official Android Tactical Assault Kit (Civil) SDK development environment for version ${version}.

## Quick Start

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/iotactical/$(get_sdk_repo_name "$version")?quickstart=1&ref=${branch_name})

Or use with [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers):

\`\`\`bash
git clone https://github.com/iotactical/$(get_sdk_repo_name "$version").git
cd $(get_sdk_repo_name "$version")
git checkout ${branch_name}
code .
# Select "Reopen in Container" when prompted
\`\`\`

## What's Included

- **ATAK-CIV SDK v${version}**: Complete development kit
- **Android Development Tools**: Android SDK, build tools, platform tools
- **Java 17**: LTS Java runtime and development kit
- **Gradle**: Build automation and dependency management
- **DBSDK Utilities**: Compliance checking, telemetry control, SBOM management

## Development Environment

This environment includes:

- Pre-configured Android development setup
- ATAK-CIV SDK v${version} integrated and ready to use
- Sample plugin templates and examples
- Automated security scanning and compliance checks
- Privacy-first telemetry (easily disabled)

## Quick Commands

\`\`\`bash
# Check SDK version and environment
dbsdk version

# Run compliance assessment
dbsdk compliance-check

# View telemetry information
dbsdk telemetry info

# Generate SBOM for your project
dbsdk sbom generate
\`\`\`

## Plugin Development

Start developing your ATAK-CIV plugin:

\`\`\`bash
# Create new plugin from template
mkdir my-atak-plugin
cd my-atak-plugin

# Initialize with ATAK-CIV v${version} template
# (Template creation scripts will be added in future updates)
\`\`\`

## Documentation

- [ATAK-CIV Official Documentation](https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV)
- [Defense Builders SDK](https://github.com/iotactical/defense-builders-sdk)
- [Plugin Development Guide](https://iotactical.co/docs/atak-civ)

## Support

- **Community**: [GitHub Discussions](https://github.com/iotactical/defense-builders-sdk/discussions)
- **Issues**: [Report Issues](https://github.com/iotactical/defense-builders-sdk/issues)
- **Professional Support**: Available with [ioTACTICAL Premium](https://iotactical.co/premium)

---

**SDK Version**: ${version}  
**Branch**: ${branch_name}  
**Last Updated**: $(date -u +%Y-%m-%d)  

Built with ❤️ by [ioTACTICAL](https://iotactical.co) for the defense development community.
EOF

    # Create version-specific workflow
    mkdir -p "$repo_dir/.github/workflows"
    cat > "$repo_dir/.github/workflows/validate-sdk.yml" << EOF
name: Validate ATAK-CIV SDK v${version}

on:
  push:
    branches: [ "${branch_name}" ]
  pull_request:
    branches: [ "${branch_name}" ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Build and test devcontainer
      uses: devcontainers/ci@v0.3
      with:
        imageName: ghcr.io/iotactical/dbsdk-atak-civ
        imageTag: ${version}
        runCmd: |
          dbsdk version
          dbsdk compliance-check
          java --version
          gradle --version
EOF
}

# Build system integration
update_build_matrix() {
    local versions=($(discover_sdk_versions))
    local matrix_file="$PWD/.github/workflows/build-sdks.yml"
    
    log_info "Updating build matrix with ${#versions[@]} versions"
    
    # Create matrix strategy JSON
    local matrix_json=$(printf '%s\n' "${versions[@]}" | jq -R . | jq -s .)
    
    log_info "Available versions for matrix: $(echo "${versions[@]}")"
    log_info "Matrix JSON: $matrix_json"
    
    # TODO: Update the GitHub Actions workflow file with new matrix
    # This would involve parsing and updating the YAML file
    log_warn "Matrix update requires manual workflow file modification"
    log_info "Add these versions to .github/workflows/build-sdks.yml matrix:"
    printf '%s\n' "${versions[@]}" | sed 's/^/  - /'
}

# Main command processing
main() {
    local command="$1"
    shift
    
    case "$command" in
        "list-versions")
            discover_sdk_versions
            ;;
        "import-version")
            local version="$1"
            if [[ -z "$version" ]]; then
                log_error "Version required for import-version command"
                show_help
                exit 1
            fi
            version=$(parse_version "$version")
            create_version_branch "$version"
            ;;
        "build-version")
            local version="$1"
            if [[ -z "$version" ]]; then
                log_error "Version required for build-version command"
                exit 1
            fi
            log_info "Building devcontainer for version $version"
            # TODO: Integrate with Docker build system
            log_warn "Build integration not yet implemented"
            ;;
        "sync-all")
            local versions=($(discover_sdk_versions))
            log_info "Syncing ${#versions[@]} SDK versions"
            for version in "${versions[@]}"; do
                log_info "Processing version $version"
                create_version_branch "$version" || log_warn "Failed to process $version"
            done
            update_build_matrix
            ;;
        "create-branch")
            local version="$1"
            if [[ -z "$version" ]]; then
                log_error "Version required for create-branch command"
                exit 1
            fi
            version=$(parse_version "$version")
            create_version_branch "$version"
            ;;
        "update-matrix")
            update_build_matrix
            ;;
        "-h"|"--help"|"help")
            show_help
            ;;
        "")
            log_error "Command required"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"