#!/bin/bash
# ATAK-CIV Post-Create Script
# Runs after the devcontainer is created

set -e

echo "ATAK-CIV post-create initialization..."

# Create workspace structure
mkdir -p /workspaces/.vscode
mkdir -p /workspaces/plugins

# Copy VS Code settings for ATAK development
cat > /workspaces/.vscode/settings.json <<'EOF'
{
    "java.home": "/usr/lib/jvm/java-17-openjdk-amd64",
    "android.home": "/opt/android-sdk",
    "java.configuration.updateBuildConfiguration": "automatic",
    "java.gradle.buildServer.enabled": "on",
    "java.import.gradle.enabled": true,
    "files.exclude": {
        "**/build/": true,
        "**/.gradle/": true,
        "**/bin/": true
    },
    "search.exclude": {
        "**/build/": true,
        "**/.gradle/": true,
        "**/bin/": true,
        "**/node_modules/": true
    }
}
EOF

# Copy launch configuration for debugging
cat > /workspaces/.vscode/launch.json <<'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "java",
            "name": "Debug ATAK Plugin",
            "request": "attach",
            "hostName": "localhost",
            "port": 5005,
            "projectName": "atak-plugin"
        }
    ]
}
EOF

# Create a sample ATAK plugin structure
if [[ ! -f /workspaces/plugins/README.md ]]; then
    cat > /workspaces/plugins/README.md <<'EOF'
# ATAK Plugins

This directory is for your ATAK plugin development.

## Getting Started

1. **ATAK-CIV Source**: Available at `/opt/atak-civ`
2. **Create Plugin**: Use the ATAK-CIV documentation to create your plugin
3. **Build**: Use Gradle to build your plugin
4. **Test**: Deploy to connected device or emulator

## Helpful Commands

- `atak-status` - Show development environment status
- `atak-source` - Navigate to ATAK-CIV source
- `atak-build` - Build ATAK-CIV
- `android-devices` - List connected Android devices

## Resources

- [ATAK-CIV GitHub](https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV)
- [ATAK Plugin Development Guide](https://www.civtak.org/)
- [ioTACTICAL Documentation](https://docs.iotactical.co)
EOF
fi

# Create a basic plugin template
if [[ ! -d /workspaces/plugins/basic-template ]]; then
    mkdir -p /workspaces/plugins/basic-template/src/main/java/com/iotactical/plugin
    
    cat > /workspaces/plugins/basic-template/build.gradle <<'EOF'
// Basic ATAK Plugin Template
apply plugin: 'com.android.application'

android {
    compileSdkVersion 30
    
    defaultConfig {
        applicationId "com.iotactical.plugin.basic"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    // Add ATAK SDK dependencies here
    // implementation files('/opt/atak-civ/atak/ATAK/app/build/libs/main.jar')
}
EOF

    cat > /workspaces/plugins/basic-template/src/main/java/com/iotactical/plugin/BasicPlugin.java <<'EOF'
package com.iotactical.plugin;

/**
 * Basic ATAK Plugin Template
 * 
 * This is a starting point for ATAK plugin development.
 * Customize this class to implement your plugin functionality.
 */
public class BasicPlugin {
    
    public static void main(String[] args) {
        System.out.println("ATAK Plugin Template - Ready for development!");
    }
}
EOF

    echo "Created basic plugin template in /workspaces/plugins/basic-template"
fi

# Set workspace permissions
chown -R vscode:vscode /workspaces

echo "Post-create setup complete!"
echo "ATAK-CIV development environment ready"
echo "Start developing in /workspaces/plugins/"

# Run DBSDK post-setup hook (shows telemetry disclosure)
if [[ -x /opt/dbsdk/scripts/post-sdk-setup.sh ]]; then
    /opt/dbsdk/scripts/post-sdk-setup.sh
fi