# Security Policy

## Reporting Security Vulnerabilities

We take the security of GeoAI OSS seriously. If you discover a security vulnerability, please follow these guidelines:

### DO ✅

- **Report privately**: Email security issues to your organization's security contact or create a private security advisory on GitHub
- **Provide details**: Include steps to reproduce, affected versions, and potential impact
- **Allow time**: Give us reasonable time to fix the issue before public disclosure

### DON'T ❌

- **Don't post publicly**: Do not open public GitHub issues for security vulnerabilities
- **Don't share secrets**: Never post API keys, tokens, or credentials in issues or pull requests

## Security Best Practices

### API Keys and Credentials

- All API keys (Google Maps, Azure Maps, Microsoft Foundry) are stored using masked field datatypes
- Keys are transmitted only over HTTPS/TLS
- **Never commit real API keys** to the repository
- Use placeholder values like `YOUR-API-KEY-HERE` in examples

### Data Privacy

- Review your organization's data privacy policies before sending business data to external AI or map services
- Consider data residency requirements for your Azure AI Foundry deployment
- GeoAI OSS caches geocoding results locally - review cache retention settings

### Telemetry

- Telemetry can be disabled in GeoAI Setup
- When enabled, telemetry logs operation metadata (duration, status) but does NOT log:
  - API keys or authentication tokens
  - Full request/response payloads
  - Business data content

### Deployment

- Always deploy to a test environment first
- Configure setup fields in BC (do not hardcode secrets in AL source)
- Use Azure Key Vault or similar for production secret management if available

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Known Limitations

- This extension targets Business Central Cloud (SaaS) only
- Requires BC 27.0+ for System.AI capabilities
- External API calls depend on third-party service availability
