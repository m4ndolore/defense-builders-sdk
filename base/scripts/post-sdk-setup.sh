#!/bin/bash
# DBSDK Post-SDK Setup Hook
# This script runs after any bespoke SDK has completed its setup
# It ensures users are informed about telemetry practices

set -e

echo ""
echo "🎯 DBSDK Setup Complete!"
echo ""

# Wait a moment for any previous output to settle
sleep 1

# Show telemetry disclosure
/opt/dbsdk/scripts/telemetry-disclosure.sh

# Add helpful next steps
echo "🚀 NEXT STEPS:"
echo "  • Start developing in /workspaces/"
echo "  • Check SDK-specific documentation in your workspace"
echo "  • Use 'dbsdk-telemetry-info' to review telemetry settings anytime"
echo ""
echo "Happy coding! 🔧"
echo ""