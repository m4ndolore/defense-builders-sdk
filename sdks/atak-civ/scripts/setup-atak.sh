#!/bin/bash
# ATAK-CIV Environment Setup Script

set -e

echo "Setting up ATAK-CIV development environment..."

# Verify ATAK-CIV source is available
if [[ ! -d /opt/atak-civ ]]; then
    echo "ATAK-CIV source not found at /opt/atak-civ"
    exit 1
fi

# Set proper permissions for ATAK directory
chown -R vscode:vscode /opt/atak-civ

# Verify Android SDK installation
if [[ ! -d $ANDROID_HOME ]]; then
    echo "Android SDK not found at $ANDROID_HOME"
    exit 1
fi

# Verify Java installation
java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
echo "Java version: $java_version"

# Verify Gradle installation
gradle_version=$(gradle --version | grep "Gradle" | head -n 1)
echo "$gradle_version"

# Test Android SDK tools
echo "Testing Android SDK..."
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --list | head -5

# Set up Git configuration for the container
git config --system user.name "ATAK Developer"
git config --system user.email "developer@iotactical.co"
git config --system init.defaultBranch main

# Create helpful aliases
cat >> /etc/bash.bashrc <<'EOF'

# ATAK-CIV Development Aliases
alias atak-source='cd /opt/atak-civ'
alias atak-build='cd /opt/atak-civ && ./gradlew assembleDebug'
alias atak-clean='cd /opt/atak-civ && ./gradlew clean'
alias android-devices='adb devices'
alias android-logcat='adb logcat'

# Show ATAK development status
atak-status() {
    echo "ATAK-CIV Development Environment Status"
    echo "====================================="
    echo "ATAK Source: /opt/atak-civ"
    echo "Java: $(java -version 2>&1 | head -n 1 | cut -d'"' -f2)"
    echo "Gradle: $(gradle --version | grep "Gradle" | head -n 1 | cut -d' ' -f2)"
    echo "Android SDK: $ANDROID_HOME"
    echo "Connected devices:"
    adb devices 2>/dev/null || echo "   No devices connected"
    echo ""
    echo "Ready to develop ATAK plugins!"
}

EOF

echo "ATAK-CIV environment setup complete!"
echo "Ready for ATAK plugin development"