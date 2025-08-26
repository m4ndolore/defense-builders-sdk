#!/bin/bash
# DBSDK SDK Synchronization
# Automated SDK repository and branch synchronization system
# https://github.com/iotactical/defense-builders-sdk

set -e

# Configuration
GITHUB_ORG="${GITHUB_ORG:-iotactical}"
DBSDK_TEMP_DIR="${DBSDK_TEMP_DIR:-/tmp/dbsdk-sync}"
SDK_DOWNLOADS="${SDK_DOWNLOADS:-$HOME/Downloads}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# GitHub API functions
check_repo_exists() {
    local repo_name="$1"
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
        "https://api.github.com/repos/${GITHUB_ORG}/${repo_name}")
    [[ "$status_code" == "200" ]]
}

create_repo() {
    local repo_name="$1"
    local description="$2"
    
    if [[ -z "$GITHUB_TOKEN" ]]; then
        log_error "GITHUB_TOKEN environment variable required"
        return 1
    fi
    
    log_info "Creating repository: ${GITHUB_ORG}/${repo_name}"
    
    local payload
    payload=$(jq -n \
        --arg name "$repo_name" \
        --arg description "$description" \
        '{
            name: $name,
            description: $description,
            private: false,
            has_issues: true,
            has_projects: false,
            has_wiki: false,
            auto_init: true,
            license_template: "mit"
        }')
    
    curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        "https://api.github.com/orgs/${GITHUB_ORG}/repos" \
        -d "$payload" > /dev/null
    
    if [[ $? -eq 0 ]]; then
        log_success "Repository created: ${GITHUB_ORG}/${repo_name}"
        return 0
    else
        log_error "Failed to create repository: ${GITHUB_ORG}/${repo_name}"
        return 1
    fi
}

# Discover SDK versions from Downloads
discover_atak_versions() {
    local versions=()
    
    for sdk_file in "$SDK_DOWNLOADS"/ATAK-CIV-*.zip; do
        if [[ -f "$sdk_file" ]]; then
            local filename=$(basename "$sdk_file")
            local version
            version=$(echo "$filename" | sed -E 's/ATAK-CIV-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)-SDK\.zip/\1/')
            
            if [[ "$version" != "$filename" ]]; then
                versions+=("$version")
            fi
        fi
    done
    
    printf '%s\n' "${versions[@]}" | sort -V
}

# Create or update SDK repository for a specific version
sync_atak_version() {
    local version="$1"
    local repo_name="ATAK-CIV-${version}-SDK"
    local branch_name="atak-civ-${version}"
    local sdk_file="$SDK_DOWNLOADS/ATAK-CIV-${version}-SDK.zip"
    
    if [[ ! -f "$sdk_file" ]]; then
        log_error "SDK file not found: $sdk_file"
        return 1
    fi
    
    log_info "Syncing ATAK-CIV v${version}"
    
    # Ensure repository exists
    if ! check_repo_exists "$repo_name"; then
        create_repo "$repo_name" "ATAK-CIV SDK v${version} - Android Tactical Assault Kit (Civil) Development Environment"
    fi
    
    # Clone repository to temp directory
    local repo_dir="$DBSDK_TEMP_DIR/$repo_name"
    rm -rf "$repo_dir"
    
    if ! git clone "https://github.com/${GITHUB_ORG}/${repo_name}.git" "$repo_dir" 2>/dev/null; then
        log_warn "Failed to clone repository, will reinitialize"
        mkdir -p "$repo_dir"
        cd "$repo_dir"
        git init
        git remote add origin "https://github.com/${GITHUB_ORG}/${repo_name}.git"
    else
        cd "$repo_dir"
    fi
    
    # Create or switch to version branch
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git checkout "$branch_name"
        log_info "Switched to existing branch: $branch_name"
    else
        git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
        log_info "Created new branch: $branch_name"
    fi
    
    # Set up repository content
    setup_atak_repo_content "$version" "$repo_dir" "$sdk_file"
    
    # Commit and push changes
    git add .
    
    if git diff --staged --quiet; then
        log_info "No changes to commit for version $version"
    else
        git commit -m "Update ATAK-CIV SDK v${version} environment

- SDK Version: ${version}
- Branch: ${branch_name}
- Updated devcontainer configuration
- Added version-specific documentation
- Ready for GitHub Codespaces

🤖 Generated with Defense Builders SDK
https://github.com/iotactical/defense-builders-sdk"
        
        # Push to remote
        if [[ -n "$GITHUB_TOKEN" ]]; then
            git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/${repo_name}.git"
        fi
        
        git push -u origin "$branch_name"
        log_success "Updated and pushed branch: $branch_name"
    fi
    
    # Clean up
    cd /
    rm -rf "$repo_dir"
}

# Set up repository content for ATAK-CIV version
setup_atak_repo_content() {
    local version="$1"
    local repo_dir="$2"
    local sdk_file="$3"
    local branch_name="atak-civ-${version}"
    
    # Create .devcontainer directory
    mkdir -p "$repo_dir/.devcontainer"
    
    # Generate devcontainer.json
    cat > "$repo_dir/.devcontainer/devcontainer.json" << EOF
{
    "name": "ATAK-CIV SDK v${version}",
    "image": "ghcr.io/iotactical/dbsdk-atak-civ:${version}",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": true,
            "username": "vscode",
            "userUid": 1000,
            "userGid": 1000
        },
        "ghcr.io/devcontainers/features/docker-in-docker:2": {
            "moby": true,
            "dockerDashComposeVersion": "v2"
        },
        "ghcr.io/devcontainers/features/github-cli:1": {
            "installDirectlyFromGitHubRelease": true,
            "version": "latest"
        }
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-json",
                "redhat.vscode-yaml",
                "ms-azuretools.vscode-docker",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "ms-vscode.remote-containers",
                "vscjava.vscode-java-pack",
                "redhat.java",
                "vscjava.vscode-gradle"
            ],
            "settings": {
                "terminal.integrated.defaultProfile.linux": "zsh",
                "java.configuration.updateBuildConfiguration": "interactive",
                "java.compile.nullAnalysis.mode": "automatic",
                "java.import.gradle.enabled": true,
                "java.configuration.maven.userSettings": null,
                "workbench.startupEditor": "readme"
            }
        }
    },
    "forwardPorts": [8080, 3000, 8443],
    "postCreateCommand": "dbsdk version && echo 'ATAK-CIV SDK v${version} ready for development!'",
    "postStartCommand": "dbsdk compliance-check --quiet || true",
    "remoteUser": "vscode",
    "workspaceFolder": "/workspaces",
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind",
        "source=atak-plugins-cache,target=/home/vscode/.gradle,type=volume"
    ],
    "containerEnv": {
        "ATAK_SDK_VERSION": "${version}",
        "ATAK_SDK_PATH": "/opt/atak-civ/${version}"
    }
}
EOF

    # Create comprehensive README
    cat > "$repo_dir/README.md" << EOF
# ATAK-CIV SDK v${version}

**Android Tactical Assault Kit (Civil) Development Environment**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/iotactical/ATAK-CIV-${version}-SDK?quickstart=1&ref=${branch_name})

> 🚀 **Ready to use**: Complete ATAK-CIV development environment with SDK v${version} pre-configured

## Quick Start

### Option 1: GitHub Codespaces (Recommended)

Click the "Open in GitHub Codespaces" badge above for instant cloud development.

### Option 2: VS Code Dev Containers

1. **Prerequisites**: [VS Code](https://code.visualstudio.com/) + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

2. **Clone and open**:
   \`\`\`bash
   git clone https://github.com/iotactical/ATAK-CIV-${version}-SDK.git
   cd ATAK-CIV-${version}-SDK
   git checkout ${branch_name}
   code .
   \`\`\`

3. **Reopen in container** when VS Code prompts

## What's Included

### 🎯 ATAK-CIV SDK v${version}
- Complete development kit with all libraries and tools
- Pre-configured Android development environment
- Java 17 LTS runtime and development tools
- Gradle build system with Android plugins

### 🛠️ Development Tools
- **Android SDK**: Platform tools, build tools, and emulators
- **DBSDK Utilities**: Compliance checking, telemetry control, SBOM management
- **Security Tools**: Vulnerability scanning and hardening
- **Git & GitHub CLI**: Version control and CI/CD integration

### 🔒 Security & Compliance
- Privacy-first telemetry (easily disabled)
- Security hardening applied to container
- STIG compliance assessment tools
- Software Bill of Materials (SBOM) generation

## Development Workflow

### 1. Environment Check
\`\`\`bash
# Verify SDK version and tools
dbsdk version

# Check compliance status
dbsdk compliance-check

# View telemetry settings (privacy-first)
dbsdk telemetry info
\`\`\`

### 2. Plugin Development

Create your ATAK-CIV plugin in the \`/workspaces\` directory:

\`\`\`bash
# Your plugin development starts here
cd /workspaces

# Example: Create a new plugin project
mkdir my-atak-plugin
cd my-atak-plugin

# SDK is available at: \$ATAK_SDK_PATH
echo "ATAK SDK located at: \$ATAK_SDK_PATH"
\`\`\`

### 3. Build and Test

\`\`\`bash
# Use Gradle to build your plugin
gradle build

# Run tests
gradle test

# Generate plugin APK
gradle assembleDebug
\`\`\`

## SDK Version Information

| Attribute | Value |
|-----------|-------|
| **SDK Version** | ${version} |
| **Branch** | \`${branch_name}\` |
| **Container** | \`ghcr.io/iotactical/dbsdk-atak-civ:${version}\` |
| **Java Version** | 17 (LTS) |
| **Android API** | 30, 33 |
| **Gradle Version** | 8.5 |

## Documentation & Resources

### 📚 Official Documentation
- [ATAK-CIV GitHub Repository](https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV)
- [Plugin Development Guide](https://iotactical.co/docs/atak-civ)
- [Defense Builders SDK](https://github.com/iotactical/defense-builders-sdk)

### 💬 Community & Support
- [GitHub Discussions](https://github.com/iotactical/defense-builders-sdk/discussions) - Community Q&A
- [Report Issues](https://github.com/iotactical/defense-builders-sdk/issues) - Bug reports and feature requests
- [ioTACTICAL Premium](https://iotactical.co/premium) - Professional support and advanced features

### 🎓 Learning Resources
- [ATAK Plugin Tutorial Series](https://iotactical.co/tutorials/atak-plugins)
- [Android Development Best Practices](https://developer.android.com/guide)
- [Tactical Software Architecture Patterns](https://iotactical.co/architecture)

## Advanced Configuration

### Custom Container Settings

Modify \`.devcontainer/devcontainer.json\` to customize:
- Port forwarding
- VS Code extensions
- Environment variables
- Volume mounts

### Telemetry Control

\`\`\`bash
# Disable telemetry completely
export DBSDK_TELEMETRY_ENABLED=false

# View what data is collected
dbsdk telemetry info --detailed

# Check privacy policy
dbsdk telemetry privacy
\`\`\`

### Security Assessment

\`\`\`bash
# Run STIG compliance check
dbsdk compliance-check --stig

# Generate security report
dbsdk security report

# View container hardening status
dbsdk security status
\`\`\`

## Troubleshooting

### Common Issues

**Container won't start**: Ensure Docker is running and you have sufficient resources allocated.

**Permission errors**: The container runs as the \`vscode\` user (UID 1000). File permissions are automatically handled.

**SDK not found**: The ATAK-CIV SDK is pre-installed at \`/opt/atak-civ/${version}\`. Check \`\$ATAK_SDK_PATH\` environment variable.

### Getting Help

1. **Check logs**: \`dbsdk logs\`
2. **Environment info**: \`dbsdk info\`
3. **Community**: [GitHub Discussions](https://github.com/iotactical/defense-builders-sdk/discussions)
4. **Professional**: [ioTACTICAL Premium Support](https://iotactical.co/premium)

---

## About

**Defense Builders SDK** provides secure, compliant development environments for the defense community. Built with ❤️ by [ioTACTICAL](https://iotactical.co).

- **Repository**: https://github.com/iotactical/defense-builders-sdk
- **Website**: https://iotactical.co
- **SDK Version**: ${version}
- **Last Updated**: $(date -u +%Y-%m-%d)

### License

MIT License - see [LICENSE](LICENSE) file for details.

### Acknowledgments

- Department of Defense for the ATAK-CIV project
- The defense development community
- Open source contributors

---

*Ready to build defense software? Start coding in your cloud development environment!* 🚀
EOF

    # Create basic GitHub workflow
    mkdir -p "$repo_dir/.github/workflows"
    cat > "$repo_dir/.github/workflows/validate-environment.yml" << EOF
name: Validate ATAK-CIV v${version} Environment

on:
  push:
    branches: [ "${branch_name}" ]
  pull_request:
    branches: [ "${branch_name}" ]
  workflow_dispatch:

jobs:
  validate-devcontainer:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Build and test devcontainer
      uses: devcontainers/ci@v0.3
      with:
        imageName: ghcr.io/iotactical/dbsdk-atak-civ
        imageTag: ${version}
        runCmd: |
          set -e
          echo "=== Environment Validation ==="
          
          # Check DBSDK utilities
          dbsdk version
          dbsdk compliance-check
          
          # Verify Java and Android tools
          java --version
          gradle --version
          android list targets || echo "Android command not available (expected)"
          
          # Check ATAK SDK availability
          if [[ -d "\$ATAK_SDK_PATH" ]]; then
            echo "✓ ATAK-CIV SDK v${version} found at \$ATAK_SDK_PATH"
            ls -la "\$ATAK_SDK_PATH"
          else
            echo "✗ ATAK-CIV SDK not found at \$ATAK_SDK_PATH"
            exit 1
          fi
          
          echo "=== Environment validation completed successfully ==="

  security-scan:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'ghcr.io/iotactical/dbsdk-atak-civ:${version}'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
EOF

    # Create example plugin structure
    mkdir -p "$repo_dir/examples/hello-world-plugin"
    cat > "$repo_dir/examples/hello-world-plugin/README.md" << EOF
# Hello World ATAK Plugin Example

This directory will contain an example "Hello World" plugin for ATAK-CIV v${version}.

## Structure (To Be Added)

\`\`\`
hello-world-plugin/
├── src/main/java/
│   └── com/example/helloworld/
│       └── HelloWorldPlugin.java
├── src/main/res/
│   └── layout/
├── AndroidManifest.xml
├── build.gradle
└── README.md
\`\`\`

## Development Status

🚧 **Coming Soon**: Complete example plugin will be added in future updates.

For now, you can start developing your plugin in the \`/workspaces\` directory of the devcontainer.
EOF

    log_success "Repository content set up for ATAK-CIV v${version}"
}

# Sync all discovered versions
sync_all_versions() {
    local versions
    mapfile -t versions < <(discover_atak_versions)
    
    if [[ ${#versions[@]} -eq 0 ]]; then
        log_error "No ATAK-CIV SDK versions found in $SDK_DOWNLOADS"
        return 1
    fi
    
    log_info "Syncing ${#versions[@]} ATAK-CIV versions: ${versions[*]}"
    
    # Create temp directory
    mkdir -p "$DBSDK_TEMP_DIR"
    
    local failed_versions=()
    for version in "${versions[@]}"; do
        log_info "Processing ATAK-CIV v${version}"
        if ! sync_atak_version "$version"; then
            log_warn "Failed to sync version: $version"
            failed_versions+=("$version")
        fi
    done
    
    # Clean up temp directory
    rm -rf "$DBSDK_TEMP_DIR"
    
    # Report results
    local success_count=$((${#versions[@]} - ${#failed_versions[@]}))
    log_success "Successfully synced ${success_count}/${#versions[@]} versions"
    
    if [[ ${#failed_versions[@]} -gt 0 ]]; then
        log_warn "Failed versions: ${failed_versions[*]}"
        return 1
    fi
    
    return 0
}

# Show help
show_help() {
    cat << EOF
DBSDK SDK Synchronization Tool

USAGE:
    sdk-sync.sh COMMAND [VERSION]

COMMANDS:
    discover              List available SDK versions
    sync VERSION          Sync specific SDK version
    sync-all             Sync all discovered versions
    
EXAMPLES:
    ./scripts/sdk-sync.sh discover
    ./scripts/sdk-sync.sh sync 5.5.0.5
    ./scripts/sdk-sync.sh sync-all

ENVIRONMENT VARIABLES:
    GITHUB_TOKEN         GitHub personal access token (required for repo creation)
    GITHUB_ORG          GitHub organization (default: iotactical)
    SDK_DOWNLOADS       Directory containing SDK zip files (default: ~/Downloads)
    DBSDK_TEMP_DIR      Temporary directory (default: /tmp/dbsdk-sync)

REQUIREMENTS:
    - curl, jq, git
    - GitHub token with repo creation permissions
    - ATAK-CIV SDK zip files in \$SDK_DOWNLOADS directory
EOF
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        "discover")
            discover_atak_versions
            ;;
        "sync")
            local version="$2"
            if [[ -z "$version" ]]; then
                log_error "Version required for sync command"
                exit 1
            fi
            sync_atak_version "$version"
            ;;
        "sync-all")
            sync_all_versions
            ;;
        "-h"|"--help"|"help"|"")
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"