# Defense Builders SDK (DBSDK)

Open source, auditable development environments for the defense community.

The Defense Builders SDK provides secure, standardized development containers for defense-focused software development. Built with transparency, security, and scalability in mind.

## Mission

Provide **authoritative, verifiable development environments** that enable defense contractors, first responders, and developers to build secure applications with confidence.

## Architecture

```
DBSDK Base Image
├── Security baseline (SBOM, hardened container)
├── Privacy-first telemetry (config/versions only)  
├── Common tooling (Git, networking, dev tools)
└── Update mechanisms

SDK-Specific Layers
└── ATAK-CIV: Android Tactical Assault Kit (Civil)
```

## Available SDKs

| SDK | Description | Container Image | Status |
|-----|-------------|-----------------|--------|
| **ATAK-CIV** | Android Tactical Assault Kit (Civil) | `ghcr.io/iotactical/dbsdk-atak-civ` | Active |

## Quick Start

### Using with GitHub Codespaces
1. Visit [ioTACTICAL Marketplace](https://iotactical.co)
2. Select "Launch ATAK Environment"
3. Choose your SDK version
4. Click "Create Environment" - launches automatically!

### Using Locally
```bash
# Pull the ATAK-CIV development environment
docker pull ghcr.io/iotactical/dbsdk-atak-civ:latest

# Run the development environment
docker run -it --rm \
  -v $(pwd):/workspace \
  -p 8080:8080 \
  ghcr.io/iotactical/dbsdk-atak-civ:latest
```

## Security & Compliance

- **Open Source**: All container definitions are publicly auditable
- **SBOM Included**: Software Bill of Materials for supply chain security
- **Regular Scanning**: Automated security vulnerability scanning
- **Hardened Base**: Minimal attack surface, security-first design
- **Privacy First**: Telemetry collects only configuration data, never source code

## Telemetry & Privacy

We collect **anonymous usage data** to improve the platform:

**What we collect:**
- SDK version and configuration
- Container performance metrics
- Feature usage analytics
- Error diagnostics (anonymized)

**What we NEVER collect:**
- Source code content
- Personal information
- Proprietary data
- Project details

## Versioning

### Container Images
- `ghcr.io/iotactical/dbsdk-base:latest` - Latest base image
- `ghcr.io/iotactical/dbsdk-base:v1.0.0` - Tagged base version
- `ghcr.io/iotactical/dbsdk-atak-civ:latest` - Latest ATAK-CIV SDK
- `ghcr.io/iotactical/dbsdk-atak-civ:v4.10.0` - Tagged ATAK-CIV version

### Git Tags
- `v1.0.0` - Complete DBSDK release
- `base-v1.0.0` - Base DBSDK version
- `atak-civ-v4.10.0` - ATAK-CIV SDK version

## Development

### Local Build
```bash
# Build base image
docker buildx build -t dbsdk-base:local ./base

# Build ATAK-CIV SDK
docker buildx build -t dbsdk-atak-civ:local ./sdks/atak-civ

# Test
docker run -it --rm dbsdk-atak-civ:local
```

## Contributing

We welcome contributions from the defense development community!

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

Open source to enable community verification and trust.

## Links

- **Website**: [iotactical.co](https://iotactical.co)
- **Container Registry**: [ghcr.io/iotactical](https://github.com/orgs/iotactical/packages)
- **Documentation**: [docs.iotactical.co](https://docs.iotactical.co)
- **Support**: [support@iotactical.co](mailto:support@iotactical.co)

---

*Empowering the defense community with secure, open development environments.*