#!/bin/bash
# DBSDK Telemetry Service Installation
# Sets up privacy-first telemetry collection

set -e

echo "Installing DBSDK telemetry service..."

# Create telemetry configuration directory
mkdir -p /etc/dbsdk
chmod 755 /etc/dbsdk

# Create telemetry configuration file
cat > /etc/dbsdk/telemetry.conf <<EOF
# DBSDK Telemetry Configuration
# Privacy-first anonymous usage analytics

# Telemetry endpoint
DBSDK_TELEMETRY_ENDPOINT=https://telemetry.iotactical.co/api/v1/events

# Default enabled state (can be overridden by environment variable)
DBSDK_TELEMETRY_ENABLED=true

# Session timeout in seconds
DBSDK_TELEMETRY_SESSION_TIMEOUT=3600

# Retry configuration
DBSDK_TELEMETRY_RETRY_COUNT=2
DBSDK_TELEMETRY_RETRY_DELAY=1

# Data retention policy (days)
DBSDK_TELEMETRY_DATA_RETENTION=30
EOF

# Set proper permissions
chmod 644 /etc/dbsdk/telemetry.conf

# Create telemetry service directories
mkdir -p /var/lib/dbsdk/telemetry
mkdir -p /var/log/dbsdk
chmod 755 /var/lib/dbsdk/telemetry
chmod 755 /var/log/dbsdk

# Create telemetry service script wrapper
cat > /usr/local/bin/dbsdk-telemetry-send <<'EOF'
#!/bin/bash
# DBSDK Telemetry Service Wrapper
# Safely sends telemetry data with proper error handling

# Source configuration
if [[ -f /etc/dbsdk/telemetry.conf ]]; then
    source /etc/dbsdk/telemetry.conf
fi

# Call the main telemetry service
exec /opt/dbsdk/telemetry/telemetry-service.sh "$@"
EOF

chmod +x /usr/local/bin/dbsdk-telemetry-send

# Set up log rotation for telemetry logs
if command -v logrotate >/dev/null 2>&1; then
    cat > /etc/logrotate.d/dbsdk <<'EOF'
/var/log/dbsdk/*.log {
    weekly
    missingok
    rotate 4
    compress
    delaycompress
    notifempty
    create 644 vscode vscode
}
EOF
fi

echo "✓ DBSDK telemetry service installed successfully"
echo "  Configuration: /etc/dbsdk/telemetry.conf"
echo "  Logs: /var/log/dbsdk/"
echo "  Service: dbsdk-telemetry-send"
echo ""
echo "Telemetry is privacy-first and can be disabled with:"
echo "  export DBSDK_TELEMETRY_ENABLED=false"