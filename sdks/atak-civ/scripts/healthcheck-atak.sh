#!/bin/bash
# ATAK-CIV Health Check Script

set -e

# Run base health check first
/opt/dbsdk/scripts/healthcheck.sh

# ATAK-specific checks
echo "ATAK-CIV specific health checks..."

# Check ATAK source availability
[[ -d /opt/atak-civ ]] || { echo "ATAK-CIV source missing"; exit 1; }
[[ -r /opt/atak-civ ]] || { echo "ATAK-CIV source not readable"; exit 1; }

# Check Java installation
java -version >/dev/null 2>&1 || { echo "Java not available"; exit 1; }

# Check Android SDK
[[ -d "$ANDROID_HOME" ]] || { echo "Android SDK missing"; exit 1; }
[[ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]] || { echo "Android SDK tools not executable"; exit 1; }

# Check Gradle
command -v gradle >/dev/null 2>&1 || { echo "Gradle not available"; exit 1; }

# Verify workspace structure
[[ -d /workspaces ]] || { echo "Workspace directory missing"; exit 1; }
[[ -w /workspaces ]] || { echo "Workspace not writable"; exit 1; }

echo "ATAK-CIV environment healthy"
echo "Ready for ATAK plugin development"

exit 0