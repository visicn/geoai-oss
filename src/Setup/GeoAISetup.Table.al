/// <summary>
/// Table GeoAI Setup (ID 70000).
/// Configuration table for GeoAI OSS features including map providers, AI providers, and cache settings.
/// </summary>
table 70000 "GeoAI Setup"
{
    Caption = 'GeoAI Setup';
    DataPerCompany = true;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        // Map Provider Configuration
        field(20; "Map Provider"; Enum "GeoAI Map Provider")
        {
            Caption = 'Map Provider';
            DataClassification = CustomerContent;
        }
        field(21; "Google Maps API Key"; Text[250])
        {
            Caption = 'Google Maps API Key';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = Masked;
        }
        field(22; "Azure Maps Key"; Text[250])
        {
            Caption = 'Azure Maps Key';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = Masked;
        }
        field(23; "Maps Endpoint URL"; Text[250])
        {
            Caption = 'Maps Endpoint URL';
            DataClassification = CustomerContent;
            ToolTip = 'Geocoding API endpoint (e.g., https://maps.googleapis.com/maps/api/geocode/json)';
        }
        field(24; "Maps Directions URL"; Text[250])
        {
            Caption = 'Maps Directions URL';
            DataClassification = CustomerContent;
            ToolTip = 'Web interface for multi-point directions (e.g., https://www.google.com/maps/dir/)';
        }
        field(25; "Map View URL"; Text[250])
        {
            Caption = 'Map View URL';
            DataClassification = CustomerContent;
            ToolTip = 'Web interface for viewing single location on map (e.g., https://www.google.com/maps for Google or https://www.bing.com/maps for Azure/Bing)';
        }

        // AI Provider Configuration
        field(30; "AI Provider"; Enum "GeoAI AI Provider")
        {
            Caption = 'AI Provider';
            DataClassification = CustomerContent;
        }
        field(31; "Microsoft Foundry Endpoint"; Text[250])
        {
            Caption = 'Microsoft Foundry Endpoint';
            DataClassification = CustomerContent;
        }
        field(32; "Microsoft Foundry Key"; Text[250])
        {
            Caption = 'Microsoft Foundry Key';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = Masked;
        }
        field(33; "Local AI Gateway URL"; Text[250])
 
        {
            Caption = 'Local AI Gateway URL';
            DataClassification = CustomerContent;
        }
        field(34; "Microsoft Foundry Model"; Text[100])
        {
            Caption = 'Model Deployment Name';
            DataClassification = CustomerContent;
        }
        field(35; "Microsoft Foundry API Version"; Text[40])
        {
            Caption = 'API Version';
            DataClassification = CustomerContent;
            InitValue = '2025-01-01-preview';
        }

        // Cache and Performance
        field(80; "Cache Enabled"; Boolean)
        {
            Caption = 'Cache Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(81; "Cache TTL Hours"; Integer)
        {
            Caption = 'Cache TTL (Hours)';
            DataClassification = CustomerContent;
            MinValue = 1;
            InitValue = 24;
        }
        field(82; "Geocode Cache Days"; Integer)
        {
            Caption = 'Geocode Cache Days';
            DataClassification = CustomerContent;
            MinValue = 1;
            InitValue = 30;
            ToolTip = 'Number of days to retain geocode cache entries before automatic purge.';
        }
        field(83; "Default Geohash Precision"; Integer)
        {
            Caption = 'Default Geohash Precision';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 12;
            InitValue = 6;
            ToolTip = 'Default precision for geohash encoding (1-12 characters). Higher values = smaller area, more precise. Typical: 4 (~39km), 6 (~1.2km), 8 (~38m).';
        }

        // Timeout and Retry Configuration
        field(96; "Timeout (ms)"; Integer)
        {
            Caption = 'Timeout (ms)';
            DataClassification = CustomerContent;
            MinValue = 1000;
            MaxValue = 60000;
            InitValue = 10000;
            ToolTip = 'Maximum time to wait for AI response in milliseconds.';
        }
        field(97; "Max Retry Attempts"; Integer)
        {
            Caption = 'Max Retry Attempts';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 5;
            InitValue = 3;
            ToolTip = 'Number of retry attempts for failed AI calls.';
        }

        // Token Budget Control
        field(110; "Max Input Tokens"; Integer)
        {
            Caption = 'Max Input Tokens';
            DataClassification = CustomerContent;
            MinValue = 100;
            InitValue = 4000;
            ToolTip = 'Maximum tokens allowed for input (prompt + context).';
        }
        field(111; "Auto Geocode on Address Change"; Boolean)
        {
            Caption = 'Auto Geocode on Address Change';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Automatically clear geocode and mark for re-geocoding when address fields change on entities.';
        }

        // Candidate Selection (Anchor-Candidate Pattern)
        field(92; "Max Candidates Sent To AI"; Integer)
        {
            Caption = 'Max Candidates Sent To AI';
            DataClassification = CustomerContent;
            InitValue = 25;
            MinValue = 1;
            MaxValue = 200;
            ToolTip = 'Maximum number of candidate entities to send to AI for similarity analysis. Higher values increase accuracy but cost. Hard cap: 200.';
        }
        field(93; "Candidate Search Radius"; Integer)
        {
            Caption = 'Candidate Search Radius (km)';
            DataClassification = CustomerContent;
            InitValue = 50;
            MinValue = 1;
            ToolTip = 'Geographic search radius in kilometers for candidate selection. Candidates beyond this distance from the anchor are excluded.';
        }
        field(94; "Enforce Same Country"; Boolean)
        {
            Caption = 'Enforce Same Country';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Restrict candidates to the same country as the anchor entity.';
        }

        // Data Redaction
        field(100; "Redaction Level"; Option)
        {
            Caption = 'Redaction Level';
            DataClassification = CustomerContent;
            OptionMembers = None,Light,Strict;
            OptionCaption = 'None,Light,Strict';
            InitValue = Light;
            ToolTip = 'Level of PII redaction before sending data to AI. Light: mask emails/phones. Strict: aggressive masking.';
        }

        // Telemetry
        field(90; "Enable Telemetry"; Boolean)
        {
            Caption = 'Enable Telemetry';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the singleton instance of GeoAI Setup.
    /// Creates the record if it doesn't exist.
    /// </summary>
    procedure GetInstance(): Record "GeoAI Setup"
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        if not GeoAISetup.Get() then begin
            GeoAISetup.Init();
            GeoAISetup."Primary Key" := '';
            GeoAISetup.Insert();
        end;
        exit(GeoAISetup);
    end;

    /// <summary>
    /// Validates that required configuration is present.
    /// </summary>
    procedure ValidateConfiguration(): Boolean
    var
        MissingConfigErr: Label 'Missing required configuration: %1', Comment = '%1 = Configuration field name';
    begin
        // Validate Map Provider configuration
        if "Map Provider" = "Map Provider"::" " then
            Error(MissingConfigErr, FieldCaption("Map Provider"));

        case "Map Provider" of
            "Map Provider"::Google:
                if "Google Maps API Key" = '' then
                    Error(MissingConfigErr, FieldCaption("Google Maps API Key"));
            "Map Provider"::Azure:
                if "Azure Maps Key" = '' then
                    Error(MissingConfigErr, FieldCaption("Azure Maps Key"));
        end;

        if "Maps Endpoint URL" = '' then
            Error(MissingConfigErr, FieldCaption("Maps Endpoint URL"));

        // Validate AI Provider configuration
        if "AI Provider" = "AI Provider"::" " then
            Error(MissingConfigErr, FieldCaption("AI Provider"));

        case "AI Provider" of
            "AI Provider"::MicrosoftFoundry:
                begin
                    if "Microsoft Foundry Endpoint" = '' then
                        Error(MissingConfigErr, FieldCaption("Microsoft Foundry Endpoint"));
                    if "Microsoft Foundry Key" = '' then
                        Error(MissingConfigErr, FieldCaption("Microsoft Foundry Key"));
                    if "Microsoft Foundry Model" = '' then
                        Error(MissingConfigErr, FieldCaption("Microsoft Foundry Model"));
                end;
            "AI Provider"::LocalGateway:
                if "Local AI Gateway URL" = '' then
                    Error(MissingConfigErr, FieldCaption("Local AI Gateway URL"));
        end;

        exit(true);
    end;
}
