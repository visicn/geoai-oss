/// <summary>
/// Codeunit Vendor Geo Provider (ID 70033).
/// Implements IGeoAI Entity interface for Vendor entity.
/// Provides location context, nearby candidate search, and geocoding validation for vendors.
/// </summary>
codeunit 70033 "Vendor Geo Provider" implements "IGeoAI Entity"
{
    /// <summary>
    /// Gets location context for a specific vendor record.
    /// </summary>
    procedure GetLocationContext(RecId: RecordId): JsonObject
    var
        Vendor: Record Vendor;
        Result: JsonObject;
        RecordNotFoundErr: Label 'Vendor not found: %1', Comment = '%1 = Record ID';
    begin
        if not Vendor.Get(RecId) then
            Error(RecordNotFoundErr, RecId);

        Result.Add('entityType', 'Vendor');
        Result.Add('id', Vendor."No.");
        Result.Add('name', Vendor.Name);
        Result.Add('lat', Vendor."GeoAI Latitude");
        Result.Add('lon', Vendor."GeoAI Longitude");
        Result.Add('country', Vendor."Country/Region Code");
        Result.Add('geohash', Vendor."GeoAI GeoHash");
        Result.Add('address', BuildDisplayAddress(Vendor.Address, Vendor."Address 2", Vendor.City, Vendor."Post Code"));

        exit(Result);
    end;

    /// <summary>
    /// Gets nearby vendors within radius, sorted by distance.
    /// Prefilters using bounding box and geocode status.
    /// </summary>
    procedure GetNearbyCandidates(AnchorLat: Decimal; AnchorLon: Decimal; RadiusKm: Decimal; MaxResults: Integer): JsonArray
    var
        Vendor: Record Vendor;
        CandidateFilter: Codeunit "GeoAI Candidate Filter";
        Result: JsonArray;
        Candidate: JsonObject;
        DistanceKm: Decimal;
        Count: Integer;
        MinLat: Decimal;
        MaxLat: Decimal;
        MinLon: Decimal;
        MaxLon: Decimal;
        MaxResultsCap: Integer;
    begin
        MaxResultsCap := 200;
        if MaxResults > MaxResultsCap then
            MaxResults := MaxResultsCap;

        CandidateFilter.SetBoundingBox(AnchorLat, AnchorLon, RadiusKm);
        CandidateFilter.GetLatitudeRange(MinLat, MaxLat);
        CandidateFilter.GetLongitudeRange(MinLon, MaxLon);

        Vendor.SetRange("GeoAI Geocode Status Field", Vendor."GeoAI Geocode Status Field"::Success);
        Vendor.SetRange("GeoAI Latitude", MinLat, MaxLat);
        Vendor.SetRange("GeoAI Longitude", MinLon, MaxLon);

        if Vendor.FindSet() then
            repeat
                DistanceKm := CandidateFilter.CalculateDistance(
                  AnchorLat, AnchorLon,
                  Vendor."GeoAI Latitude", Vendor."GeoAI Longitude"
                );

                if DistanceKm <= RadiusKm then begin
                    Clear(Candidate);
                    Candidate.Add('id', Vendor."No.");
                    Candidate.Add('name', Vendor.Name);
                    Candidate.Add('lat', Vendor."GeoAI Latitude");
                    Candidate.Add('lon', Vendor."GeoAI Longitude");
                    Candidate.Add('distanceKm', Round(DistanceKm, 0.01));
                    Result.Add(Candidate);

                    Count += 1;
                    if Count >= MaxResults then
                        break;
                end;
            until Vendor.Next() = 0;

        CandidateFilter.SortByDistance(Result);

        exit(Result);
    end;

    /// <summary>
    /// Gets the entity type for Vendor.
    /// </summary>
    procedure GetEntityType(): Enum "GeoAI Entity Type"
    var
        EntityType: Enum "GeoAI Entity Type";
    begin
        exit(EntityType::Vendor);
    end;

    /// <summary>
    /// Validates if vendor record has valid geocoding data.
    /// </summary>
    procedure ValidateGeocodingStatus(RecId: RecordId): Boolean
    var
        Vendor: Record Vendor;
        LowConfidenceQst: Label 'This entity has geocoding status with Low Confidence. Coordinates may not be accurate.\\Do you want to continue?';
    begin
        if not Vendor.Get(RecId) then
            exit(false);

        if Vendor."GeoAI Geocode Status Field" in [Vendor."GeoAI Geocode Status Field"::" ", Vendor."GeoAI Geocode Status Field"::Failed] then
            exit(false);

        if (Vendor."GeoAI Latitude" = 0) and (Vendor."GeoAI Longitude" = 0) then
            exit(false);

        if Vendor."GeoAI Geocode Status Field" = Vendor."GeoAI Geocode Status Field"::LowConfidence then
            if not Confirm(LowConfidenceQst, true) then
                exit(false);

        exit(true);
    end;

    /// <summary>
    /// Builds display address from components.
    /// </summary>
    local procedure BuildDisplayAddress(Address: Text[100]; Address2: Text[50]; City: Text[30]; PostCode: Code[20]): Text
    var
        DisplayAddress: Text;
    begin
        DisplayAddress := Address;

        if Address2 <> '' then
            DisplayAddress := DisplayAddress + ', ' + Address2;

        if City <> '' then
            DisplayAddress := DisplayAddress + ', ' + City;

        if PostCode <> '' then
            DisplayAddress := DisplayAddress + ' ' + PostCode;

        exit(DisplayAddress.Trim());
    end;
}
