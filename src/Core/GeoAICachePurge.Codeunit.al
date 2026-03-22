/// <summary>
/// Codeunit GeoAI Cache Purge (ID 70075).
/// Background job for purging old geocode cache entries.
/// </summary>
codeunit 70075 "GeoAI Cache Purge"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        GeoAISetup: Record "GeoAI Setup";
        GeocodeCache: Record "GeoAI Geocode Cache";
        DeletedCount: Integer;
        PurgeCompletedLbl: Label 'Geocode cache purge completed. %1 entries deleted.', Comment = '%1 = Number of entries';
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if not GeoAISetup."Cache Enabled" then
            exit;

        if GeoAISetup."Geocode Cache Days" <= 0 then
            exit;

        DeletedCount := GeocodeCache.PurgeOldEntries(GeoAISetup."Geocode Cache Days");

        TrackPurge(DeletedCount, GeoAISetup."Geocode Cache Days");

        if GuiAllowed() then
            Message(PurgeCompletedLbl, DeletedCount);
    end;

    /// <summary>
    /// Purges old cache entries immediately (non-job-queue).
    /// </summary>
    /// <returns>Number of entries deleted.</returns>
    procedure PurgeNow(): Integer
    var
        GeoAISetup: Record "GeoAI Setup";
        GeocodeCache: Record "GeoAI Geocode Cache";
        DeletedCount: Integer;
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if not GeoAISetup."Cache Enabled" then
            exit(0);

        if GeoAISetup."Geocode Cache Days" <= 0 then
            exit(0);

        DeletedCount := GeocodeCache.PurgeOldEntries(GeoAISetup."Geocode Cache Days");
        TrackPurge(DeletedCount, GeoAISetup."Geocode Cache Days");

        exit(DeletedCount);
    end;

    local procedure TrackPurge(DeletedCount: Integer; RetentionDays: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
        TelemetryMsg: Label 'Geocode cache purge completed', Locked = true;
    begin
        CustomDimensions.Add('Feature', 'GeoAI.Cache');
        CustomDimensions.Add('Operation', 'Purge');
        CustomDimensions.Add('DeletedCount', Format(DeletedCount));
        CustomDimensions.Add('RetentionDays', Format(RetentionDays));

        Session.LogMessage('GEOAI050', TelemetryMsg, Verbosity::Normal,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}
