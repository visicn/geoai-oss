# Contributing to GeoAI OSS

Thank you for your interest in contributing to GeoAI OSS! This document provides guidelines for development and contributions.

## Prerequisites

### Development Environment

- **VS Code** with the AL Language extension
- **Business Central** cloud sandbox (version 27.0 or later)
- **AL-Go for GitHub** (optional, for CI/CD)

### API Access

To test the extension, you'll need:

- **Map Provider**: Google Maps API key OR Azure Maps subscription key
- **AI Provider**: Microsoft (Azure) AI Foundry endpoint with an Azure OpenAI-compatible deployment

## Getting Started

### 1. Clone and Setup

```bash
git clone https://github.com/visicn/geoai-oss.git
cd geoai-oss
```

### 2. Download Symbol Packages

Create a `.alpackages/` folder and download the required BC 27.0 symbols:
- Microsoft_System
- Microsoft_System Application
- Microsoft_Base Application
- Microsoft_Business Foundation
- Microsoft_Application

### 3. Configure Launch Settings

Create `.vscode/launch.json` (this file is gitignored):

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Your BC Sandbox",
            "request": "launch",
            "type": "al",
            "environmentType": "Sandbox",
            "environmentName": "YOUR-SANDBOX-NAME",
            "tenant": "YOUR-TENANT-ID",
            "startupObjectId": 70001,
            "startupObjectType": "Page",
            "breakOnError": "All",
            "launchBrowser": true,
            "enableLongRunningSqlStatements": true,
            "enableSqlInformationDebugger": true
        }
    ]
}
```

### 4. Build and Deploy

- Press **F5** in VS Code to build and publish to your sandbox
- Open the **GeoAI Setup** page in BC
- Configure your Map and AI providers
- Use **Test Connection** to verify

## Development Guidelines

### AL Code Standards

- Follow [Microsoft AL coding guidelines](https://docs.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-coding-guidelines)
- Use **event-driven architecture** (TableExtension, PageExtension, event subscribers)
- Keep object IDs in the 70000-70199 range (see `app.json`)
- Apply proper **DataClassification** to all fields
- Use **Masked** datatype for API keys and secrets

### Project Structure

- `/src/Setup/` - Configuration tables, pages, enums, install/upgrade codeunits
- `/src/Core/` - Geocoding, HTTP client, caching, map URL formatting
- `/src/AIEngine/` - Prompt templates, prompt engine, AI service wrappers
- `/src/EntityExtensions/` - Customer/Vendor table and page extensions
- `/src/UI/` - GeoAI-specific pages (prompt UI, result items)
- `/Translations/` - Translation files (.xlf)

### Testing

- Test on a BC cloud sandbox environment
- Verify geocoding for Customer and Vendor records
- Test prompt templates with "Ask GeoAI"
- Ensure cache behavior is correct
- Test with both Google Maps and Azure Maps providers

### Security Checklist

- [ ] No API keys or secrets committed
- [ ] Use masked fields for sensitive configuration
- [ ] HTTPS/TLS for all external calls
- [ ] Telemetry doesn't log secrets or full payloads
- [ ] Example configurations use placeholders

## Pull Request Process

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/your-feature-name`)
3. **Commit your changes** with clear, descriptive messages
4. **Test thoroughly** in a BC sandbox
5. **Update documentation** if needed (README, inline comments)
6. **Submit a PR** with:
   - Description of changes
   - Testing performed
   - Any breaking changes noted

### PR Guidelines

- Keep PRs focused on a single feature or bug fix
- Include screenshots/videos for UI changes
- Update CHANGELOG.md if applicable
- Ensure no secrets or environment-specific data

## Code Review

- All contributions require review before merge
- Address feedback constructively
- Maintainers may request changes for code quality, security, or architectural consistency

## Questions?

Open a GitHub Discussion or Issue for:
- Feature requests
- Bug reports (non-security)
- General questions

For security issues, see [SECURITY.md](SECURITY.md).

---

Thank you for contributing to GeoAI OSS! 🚀
