/// <summary>
/// Page GeoAI Setup (ID 70020).
/// Configuration page for GeoAI OSS features.
/// </summary>
page 70020 "GeoAI Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GeoAI Setup";
    Caption = 'GeoAI Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(MapProvider)
            {
                Caption = 'Map Provider';

                field("Map Provider"; Rec."Map Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the map and geocoding service provider.';
                }
                field("Google Maps API Key"; Rec."Google Maps API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for Google Maps services.';
                }
                field("Azure Maps Key"; Rec."Azure Maps Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subscription key for Azure Maps services.';
                }
                field("Maps Endpoint URL"; Rec."Maps Endpoint URL")
                {
                    ApplicationArea = All;

                    Caption = 'Geocoding API Endpoint';

                    ToolTip = 'API endpoint for geocoding (converting addresses to coordinates). Example: https://maps.googleapis.com/maps/api/geocode/json';

                }
                field("Maps Directions URL"; Rec."Maps Directions URL")
                {
                    ApplicationArea = All;
                    Caption = 'Directions Web URL';
                    ToolTip = 'Web interface URL for displaying multi-point directions/routes. Example: https://www.google.com/maps/dir/';
                }
                field("Map View URL"; Rec."Map View URL")
                {
                    ApplicationArea = All;
                    Caption = 'Map View URL';
                    ToolTip = 'Web interface URL for viewing single location on map. Example: https://www.google.com/maps for Google or https://www.bing.com/maps for Azure/Bing';
                }
            }

            group(AIProvider)
            {
                Caption = 'AI Provider';

                field("AI Provider"; Rec."AI Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AI service provider for GeoAI operations.';
                }
                field("Microsoft Foundry Endpoint"; Rec."Microsoft Foundry Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint URL for Microsoft Foundry.';
                }
                field("Microsoft Foundry Key"; Rec."Microsoft Foundry Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API key for Microsoft Foundry.';
                }
                field("Microsoft Foundry Model"; Rec."Microsoft Foundry Model")
                {
                    ApplicationArea = All;
                    Caption = 'Model Deployment Name';
                    ToolTip = 'Name of the deployed model to use (e.g., gpt-4o, gpt-4o-mini).';
                }
                field("Microsoft Foundry API Version"; Rec."Microsoft Foundry API Version")
                {
                    ApplicationArea = All;
                    Caption = 'API Version';
                    ToolTip = 'Microsoft Foundry API version (e.g., 2025-01-01-preview).';
                }
                field("Local AI Gateway URL"; Rec."Local AI Gateway URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL for local AI gateway.';
                }
            }

            group(CachePerformance)
            {
                Caption = 'Cache & Performance';

                field("Cache Enabled"; Rec."Cache Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether result caching is enabled.';
                }
                field("Cache TTL Hours"; Rec."Cache TTL Hours")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cache time-to-live in hours.';
                }
                field("Geocode Cache Days"; Rec."Geocode Cache Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of days to retain geocode cache entries before automatic purge.';
                }
                field("Default Geohash Precision"; Rec."Default Geohash Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default precision for geohash spatial indexing (1-12). Higher = more precise/smaller area. Typical: 6 (~1.2km).';
                }
                field("Timeout (ms)"; Rec."Timeout (ms)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum time to wait for AI response in milliseconds.';
                }
                field("Max Retry Attempts"; Rec."Max Retry Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of retry attempts for failed AI calls.';
                }
                field("Max Input Tokens"; Rec."Max Input Tokens")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum tokens allowed for input (prompt + context).';
                }
                field("Auto Geocode on Address Change"; Rec."Auto Geocode on Address Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically clear geocode and mark for re-geocoding when address fields change on entities.';
                }
            }

            group(CandidateSelection)
            {
                Caption = 'Candidate Selection';

                field("Max Candidates Sent To AI"; Rec."Max Candidates Sent To AI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum number of candidate entities to send to AI for similarity analysis. Higher values increase accuracy but cost. Hard cap: 200.';
                }
                field("Candidate Search Radius"; Rec."Candidate Search Radius")
                {
                    ApplicationArea = All;
                    ToolTip = 'Geographic search radius in kilometers for candidate selection. Candidates beyond this distance from the anchor are excluded.';
                }
                field("Enforce Same Country"; Rec."Enforce Same Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Restrict candidates to the same country as the anchor entity.';
                }
            }

            group(DataSecurity)
            {
                Caption = 'Data Security & Privacy';

                field("Redaction Level"; Rec."Redaction Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Level of PII redaction before sending data to AI. Light: mask emails/phones. Strict: aggressive masking.';
                }
            }

            group(Telemetry)
            {
                Caption = 'Telemetry';

                field("Enable Telemetry"; Rec."Enable Telemetry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether telemetry logging is enabled.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateConfiguration)
            {
                ApplicationArea = All;
                Caption = 'Validate Configuration';
                ToolTip = 'Validates that all required configuration settings are present.';
                Image = Approve;

                trigger OnAction()
                var
                    ConfigValidMsg: Label 'Configuration is valid and ready to use.';
                begin
                    if Rec.ValidateConfiguration() then
                        Message(ConfigValidMsg);
                end;
            }

            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                ToolTip = 'Tests the connection to configured AI services.';
                Image = TestDatabase;

                trigger OnAction()
                var
                    GeoAISetup: Record "GeoAI Setup";
                    Http: Codeunit "GeoAI HTTP Client";
                    RequestJson: Text;
                    ResponseJson: Text;
                    StartTs: DateTime;
                    ElapsedMs: Integer;
                    SuccessMsg: Label 'AI connection OK (%1). Latency: %2 ms. Preview: %3', Comment = '%1 = provider, %2 = milliseconds, %3 = first chars of response';
                    ProviderMsg: Label 'Please select an AI Provider to test.';
                    ParseFailedMsg: Label 'Connection reached but response could not be parsed.';
                    ShortPreview: Text;
                    ProviderName: Text;
                    ChoicesToken: JsonToken;
                    RespObj: JsonObject;
                begin
                    // Ensure configuration is present (will error with missing fields)
                    if not Rec.ValidateConfiguration() then
                        exit;

                    GeoAISetup := GeoAISetup.GetInstance();

                    if GeoAISetup."AI Provider" = GeoAISetup."AI Provider"::" " then begin
                        Message(ProviderMsg);
                        exit;
                    end;

                    // Build a tiny ping request for chat completions
                    RequestJson := '{"messages":[{"role":"system","content":"ping"},{"role":"user","content":"ping"}]}';

                    // Execute and time the request
                    StartTs := CurrentDateTime();
                    if not Http.ExecuteAIRequest(RequestJson, ResponseJson) then
                        Error(GetLastErrorText());

                    ElapsedMs := CurrentDateTime() - StartTs;

                    // Try to detect a valid chat response (choices array)
                    if RespObj.ReadFrom(ResponseJson) then
                        if RespObj.Get('choices', ChoicesToken) then
                            ShortPreview := CopyStr(ResponseJson, 1, 80)
                        else
                            ShortPreview := CopyStr(ResponseJson, 1, 80)
                    else
                        ShortPreview := CopyStr(ResponseJson, 1, 80);

                    case GeoAISetup."AI Provider" of
                        GeoAISetup."AI Provider"::MicrosoftFoundry:
                            ProviderName := 'Microsoft Foundry';
                        GeoAISetup."AI Provider"::LocalGateway:
                            ProviderName := 'Local AI Gateway';
                        else
                            ProviderName := Format(GeoAISetup."AI Provider");
                    end;

                    if ResponseJson = '' then
                        Message(ParseFailedMsg)
                    else
                        Message(SuccessMsg, ProviderName, ElapsedMs, ShortPreview);
                end;
            }

            action(InitializeTemplates)
            {
                ApplicationArea = All;
                Caption = 'Initialize Prompt Templates';
                ToolTip = 'Creates the 18 standard GeoAI prompt templates (9 per entity × 2 entities: Customer, Vendor). Safe to run multiple times - only creates missing templates.';
                Image = CreateDocument;

                trigger OnAction()
                var
                    TemplateSetup: Codeunit "GeoAI Prompt Tmpl Setup";
                    ConfirmQst: Label 'This will initialize 36 standard prompt templates for Customer and Vendor entities. Continue?';
                    SuccessMsg: Label 'Prompt templates initialized successfully. Templates are now available in the Ask GeoAI dialog.';
                begin
                    if not Confirm(ConfirmQst, false) then
                        exit;

                    TemplateSetup.InitializeTemplates();
                    Message(SuccessMsg);
                end;
            }

            action(PurgeGeocodeCache)
            {
                ApplicationArea = All;
                Caption = 'Purge Geocode Cache';
                ToolTip = 'Manually purge geocode cache entries older than the configured retention period.';
                Image = ClearLog;

                trigger OnAction()
                var
                    CachePurge: Codeunit "GeoAI Cache Purge";
                    DeletedCount: Integer;
                    SuccessMsg: Label 'Geocode cache purge completed. %1 entries deleted.', Comment = '%1 = Number of entries';
                begin
                    DeletedCount := CachePurge.PurgeNow();
                    Message(SuccessMsg, DeletedCount);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
