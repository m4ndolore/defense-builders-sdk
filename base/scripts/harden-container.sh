#!/bin/bash
# DBSDK Security Hardening Script
# Applies security best practices to the container

set -e

echo "Hardening container security..."

# Remove potentially dangerous packages
echo "Removing unnecessary packages..."
apt-get purge -y --auto-remove \
    telnet \
    netcat \
    netcat-openbsd \
    2>/dev/null || true

# Set secure file permissions
echo "Setting secure file permissions..."
chmod 700 /root 2>/dev/null || true
chmod 755 /home/vscode
chmod 750 /opt/dbsdk

# Remove world-writable permissions from common directories
find /tmp -type d -perm -002 -exec chmod o-w {} \; 2>/dev/null || true
find /var/tmp -type d -perm -002 -exec chmod o-w {} \; 2>/dev/null || true

# Set up security limits
echo "Configuring security limits..."
cat >> /etc/security/limits.conf <<'EOF'
# DBSDK Security Limits
* hard nofile 65536
* soft nofile 65536
* hard nproc 32768
* soft nproc 32768
EOF

# Configure sysctl for security (if possible in container)
cat > /etc/sysctl.d/99-dbsdk-security.conf <<'EOF'
# DBSDK Security Configuration
# Note: Some settings may not apply in containers

# Network security
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Memory protection
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
EOF

# Clean up package cache and temporary files
echo "Cleaning up temporary files..."
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*

# Remove bash history files
rm -f /home/vscode/.bash_history /root/.bash_history

echo "Container hardening complete"
echo "Security baseline applied"