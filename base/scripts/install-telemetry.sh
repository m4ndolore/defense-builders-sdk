#!/bin/bash
# Install DBSDK telemetry service

set -e

echo "Installing DBSDK telemetry service..."

# Make telemetry service executable
chmod +x /opt/dbsdk/telemetry/telemetry-service.sh

# Add telemetry service to startup (optional, non-blocking)
cat > /etc/profile.d/dbsdk-telemetry.sh <<'EOF'
# DBSDK Telemetry - runs in background, never blocks
if [[ -x /opt/dbsdk/telemetry/telemetry-service.sh ]] && [[ "$-" == *i* ]]; then
    /opt/dbsdk/telemetry/telemetry-service.sh &
fi
EOF

chmod +x /etc/profile.d/dbsdk-telemetry.sh

echo "Telemetry service installed"
echo "   Privacy-first: Only anonymous usage data"
echo "   Opt-out: Set DBSDK_TELEMETRY_ENABLED=false"