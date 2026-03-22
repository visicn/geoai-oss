# Changelog

All notable changes to GeoAI OSS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-28

### Added - Initial OSS Release

#### Core Features
- **Geocoding** for Customer and Vendor records
  - Forward geocoding (address → coordinates)
  - Reverse geocoding (coordinates → address)
  - Confidence scoring
  - Local caching with configurable TTL
- **Map Providers** support
  - Google Maps integration
  - Azure Maps integration
  - Configurable endpoints and API keys
  - Single-point and multi-point map links
- **AI Prompt Experience** ("Ask GeoAI")
  - Microsoft (Azure) AI Foundry integration via Azure OpenAI-compatible endpoint
  - Prompt template system with categories and intents
  - Context-aware prompt building
  - Built-in test connection for Foundry endpoints
- **Customer & Vendor Extensions**
  - GeoAI fields on Customer/Vendor tables (latitude, longitude, confidence, status)
  - GeoAI actions on Customer/Vendor cards and lists
  - Batch geocoding support
  - Auto-geocode on address change (optional)

#### Configuration & Setup
- GeoAI Setup page for centralized configuration
- Support for masked API key fields
- Configurable cache behavior and retention
- Telemetry toggle (can be disabled)
- Redaction level settings for AI payloads

#### Architecture & Quality
- Event-driven design (no base object modifications)
- HTTPS/TLS for all external calls
- Proper data classification on all fields
- Retry logic with exponential backoff for AI requests
- Observability through BC telemetry (when enabled)

#### Documentation
- Comprehensive README with architecture diagrams
- Example configuration steps
- Security and privacy notes
- Translation support (English baseline)

### Target Platform
- Business Central Cloud (SaaS)
- Application version: 27.0.0.0+
- Runtime: 16.0
- Object ID range: 70000-70199

---

## Future Considerations

Ideas for future releases (not committed):
- Additional entity support (Contacts, Locations, Shipping Agents)
- Distance matrix visualization
- Advanced caching strategies
- Additional AI providers
- Enhanced telemetry dashboards

---

[1.0.0]: https://github.com/visicn/geoai-oss/releases/tag/v1.0.0
