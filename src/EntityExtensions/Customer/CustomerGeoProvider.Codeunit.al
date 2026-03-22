/// <summary>
/// Codeunit Customer Geo Provider (ID 70032).
/// Implements IGeoAI Entity interface for Customer entity.
/// Provides location context, nearby candidate search, and geocoding validation for customers.
/// </summary>
codeunit 70032 "Customer Geo Provider" implements "IGeoAI Entity"
{
    /// <summary>
    /// Gets location context for a specific customer record.
    /// </summary>
    procedure GetLocationContext(RecId: RecordId): JsonObject
    var
        Customer: Record Customer;
        Result: JsonObject;
        RecordNotFoundErr: Label 'Customer not found: %1', Comment = '%1 = Record ID';
    begin
        if not Customer.Get(RecId) then
            Error(RecordNotFoundErr, RecId);

        Result.Add('entityType', 'Customer');
        Result.Add('id', Customer."No.");
        Result.Add('name', Customer.Name);
        Result.Add('lat', Customer."GeoAI Latitude");
        Result.Add('lon', Customer."GeoAI Longitude");
        Result.Add('country', Customer."Country/Region Code");
        Result.Add('geohash', Customer."GeoAI GeoHash");
        Result.Add('address', BuildDisplayAddress(Customer.Address, Customer."Address 2", Customer.City, Customer."Post Code"));

        exit(Result);
    end;

    /// <summary>
    /// Gets nearby customers within radius, sorted by distance.
    /// Prefilters using bounding box and geocode status.
    /// </summary>
    procedure GetNearbyCandidates(AnchorLat: Decimal; AnchorLon: Decimal; RadiusKm: Decimal; MaxResults: Integer): JsonArray
    var
        Customer: Record Customer;
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

        Customer.SetRange("GeoAI Geocode Status Field", Customer."GeoAI Geocode Status Field"::Success);
        Customer.SetRange("GeoAI Latitude", MinLat, MaxLat);
        Customer.SetRange("GeoAI Longitude", MinLon, MaxLon);

        if Customer.FindSet() then
            repeat
                DistanceKm := CandidateFilter.CalculateDistance(
                  AnchorLat, AnchorLon,
                  Customer."GeoAI Latitude", Customer."GeoAI Longitude"
                );

                if DistanceKm <= RadiusKm then begin
                    Clear(Candidate);
                    Candidate.Add('id', Customer."No.");
                    Candidate.Add('name', Customer.Name);
                    Candidate.Add('lat', Customer."GeoAI Latitude");
                    Candidate.Add('lon', Customer."GeoAI Longitude");
                    Candidate.Add('distanceKm', Round(DistanceKm, 0.01));
                    Result.Add(Candidate);

                    Count += 1;
                    if Count >= MaxResults then
                        break;
                end;
            until Customer.Next() = 0;

        CandidateFilter.SortByDistance(Result);

        exit(Result);
    end;

    /// <summary>
    /// Gets the entity type for Customer.
    /// </summary>
    procedure GetEntityType(): Enum "GeoAI Entity Type"
    var
        EntityType: Enum "GeoAI Entity Type";
    begin
        exit(EntityType::Customer);
    end;

    /// <summary>
    /// Validates if customer record has valid geocoding data.
    /// </summary>
    procedure ValidateGeocodingStatus(RecId: RecordId): Boolean
    var
        Customer: Record Customer;
        LowConfidenceQst: Label 'This entity has geocoding status with Low Confidence. Coordinates may not be accurate.\\Do you want to continue?';
    begin
        if not Customer.Get(RecId) then
            exit(false);

        if Customer."GeoAI Geocode Status Field" in [Customer."GeoAI Geocode Status Field"::" ", Customer."GeoAI Geocode Status Field"::Failed] then
            exit(false);

        if (Customer."GeoAI Latitude" = 0) and (Customer."GeoAI Longitude" = 0) then
            exit(false);

        if Customer."GeoAI Geocode Status Field" = Customer."GeoAI Geocode Status Field"::LowConfidence then
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
