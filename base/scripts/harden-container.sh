#!/bin/bash
# DBSDK Container Security Hardening
# Applies security best practices to the container environment

set -e

echo "Hardening DBSDK container security..."

# Remove unnecessary packages to reduce attack surface
echo "Removing unnecessary packages..."
apt-get autoremove -y
apt-get autoclean

# Clear package cache
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*

# Remove temporary files
find /tmp -type f -delete 2>/dev/null || true
find /var/tmp -type f -delete 2>/dev/null || true

# Secure file permissions for sensitive directories
echo "Setting secure file permissions..."

# Secure /etc/passwd and /etc/shadow
chmod 644 /etc/passwd
if [[ -f /etc/shadow ]]; then
    chmod 640 /etc/shadow
fi

# Secure sudo configuration
if [[ -f /etc/sudoers ]]; then
    chmod 440 /etc/sudoers
fi

# Remove world-writable permissions from common directories
find /usr/local -type d -perm -002 -exec chmod o-w {} \; 2>/dev/null || true
find /opt -type d -perm -002 -exec chmod o-w {} \; 2>/dev/null || true

# Secure DBSDK directories
if [[ -d /opt/dbsdk ]]; then
    # Ensure DBSDK scripts are owned by root but executable
    chown -R root:root /opt/dbsdk
    find /opt/dbsdk -type f -name "*.sh" -exec chmod 755 {} \;
    find /opt/dbsdk -type d -exec chmod 755 {} \;
    
    # Secure sensitive files
    if [[ -f /opt/dbsdk/sbom.json ]]; then
        chmod 644 /opt/dbsdk/sbom.json
    fi
fi

# Remove potentially dangerous SUID binaries (keep essential ones)
echo "Reviewing SUID binaries..."
find /usr -perm -4000 -type f | while read -r suid_file; do
    case "$(basename "$suid_file")" in
        "sudo"|"su"|"passwd"|"chfn"|"chsh"|"newgrp"|"mount"|"umount")
            echo "  Keeping essential SUID: $suid_file"
            ;;
        *)
            echo "  Removing SUID bit from: $suid_file"
            chmod -s "$suid_file" 2>/dev/null || true
            ;;
    esac
done

# Set secure umask for vscode user
echo "umask 022" >> /home/vscode/.bashrc

# Create security configuration file
cat > /etc/dbsdk/security.conf <<EOF
# DBSDK Security Configuration
# Container security hardening settings

# Security hardening timestamp
DBSDK_SECURITY_HARDENED=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Security level
DBSDK_SECURITY_LEVEL=standard

# Enabled security features
DBSDK_SECURITY_SUID_RESTRICTED=true
DBSDK_SECURITY_PERMISSIONS_HARDENED=true
DBSDK_SECURITY_CLEANUP_APPLIED=true
EOF

chmod 644 /etc/dbsdk/security.conf

# Log security hardening completion
echo "✓ Container security hardening completed"
echo "  Configuration: /etc/dbsdk/security.conf"
echo "  Hardening level: Standard"
echo "  Applied: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""
echo "Security measures applied:"
echo "  • Removed unnecessary packages"
echo "  • Secured file permissions"
echo "  • Restricted SUID binaries"
echo "  • Cleaned temporary files"
echo "  • Set secure umask"