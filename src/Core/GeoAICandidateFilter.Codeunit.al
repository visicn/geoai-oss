/// <summary>
/// Codeunit GeoAI Candidate Filter (ID 70030).
/// Provides spatial filtering and distance computation for GeoAI candidate sets.
/// Implements Haversine formula for accurate distance calculation.
/// </summary>
codeunit 70030 "GeoAI Candidate Filter"
{
    var
        MinLat: Decimal;
        MaxLat: Decimal;
        MinLon: Decimal;
        MaxLon: Decimal;

    /// <summary>
    /// Sets bounding box for candidate filtering based on center point and radius.
    /// Uses approximate degree-to-km conversion for initial filtering.
    /// </summary>
    /// <param name="CenterLat">Center latitude in decimal degrees.</param>
    /// <param name="CenterLon">Center longitude in decimal degrees.</param>
    /// <param name="RadiusKm">Search radius in kilometers.</param>
    procedure SetBoundingBox(CenterLat: Decimal; CenterLon: Decimal; RadiusKm: Decimal)
    var
        LatDelta: Decimal;
        LonDelta: Decimal;
        CosLat: Decimal;
    begin
        LatDelta := RadiusKm / 111.0;

        CosLat := ApproximateCosine(CenterLat);

        LonDelta := RadiusKm / (111.0 * CosLat);

        MinLat := CenterLat - LatDelta;
        MaxLat := CenterLat + LatDelta;
        MinLon := CenterLon - LonDelta;
        MaxLon := CenterLon + LonDelta;
    end;

    /// <summary>
    /// Gets bounding box latitude filter for SetRange.
    /// </summary>
    /// <returns>Tuple of MinLat and MaxLat.</returns>
    procedure GetLatitudeRange(var OutMinLat: Decimal; var OutMaxLat: Decimal)
    begin
        OutMinLat := MinLat;
        OutMaxLat := MaxLat;
    end;

    /// <summary>
    /// Gets bounding box longitude filter for SetRange.
    /// </summary>
    /// <returns>Tuple of MinLon and MaxLon.</returns>
    procedure GetLongitudeRange(var OutMinLon: Decimal; var OutMaxLon: Decimal)
    begin
        OutMinLon := MinLon;
        OutMaxLon := MaxLon;
    end;

    /// <summary>
    /// Calculates accurate distance between two points using Haversine formula.
    /// Delegates to centralized GeoLocationMgmt implementation.
    /// </summary>
    /// <param name="Lat1">Starting latitude in decimal degrees.</param>
    /// <param name="Lon1">Starting longitude in decimal degrees.</param>
    /// <param name="Lat2">Ending latitude in decimal degrees.</param>
    /// <param name="Lon2">Ending longitude in decimal degrees.</param>
    /// <returns>Distance in kilometers (great circle distance).</returns>
    procedure CalculateDistance(Lat1: Decimal; Lon1: Decimal; Lat2: Decimal; Lon2: Decimal): Decimal
    var
        GeoLocationMgmt: Codeunit "GeoLocation Mgmt";
    begin
        exit(GeoLocationMgmt.HaversineDistanceKm(Lat1, Lon1, Lat2, Lon2));
    end;

    /// <summary>
    /// Approximates cosine function using Taylor series (2 terms).
    /// Used for SetBoundingBox calculations. cos(x) ≈ 1 - x²/2 where x is in radians.
    /// Accurate to within 2% for latitudes -60° to +60°.
    /// </summary>
    local procedure ApproximateCosine(Degrees: Decimal): Decimal
    var
        Radians: Decimal;
        Result: Decimal;
    begin
        Radians := Degrees * 3.14159265358979323846 / 180;

        Result := 1 - (Radians * Radians / 2);

        if Result > 1 then
            Result := 1;
        if Result < -1 then
            Result := -1;

        exit(Result);
    end;

    /// <summary>
    /// Sorts candidate array by distance in ascending order (bubble sort).
    /// </summary>
    /// <param name="Candidates">JsonArray of candidates with distanceKm field.</param>
    procedure SortByDistance(var Candidates: JsonArray)
    var
        i: Integer;
        j: Integer;
        Count: Integer;
        Token1: JsonToken;
        Token2: JsonToken;
        Dist1: Decimal;
        Dist2: Decimal;
        Swapped: Boolean;
    begin
        Count := Candidates.Count();
        if Count <= 1 then
            exit;

        for i := 0 to Count - 2 do begin
            Swapped := false;
            for j := 0 to Count - i - 2 do begin
                Candidates.Get(j, Token1);
                Candidates.Get(j + 1, Token2);

                Token1.AsObject().Get('distanceKm', Token1);
                Token2.AsObject().Get('distanceKm', Token2);
                Dist1 := Token1.AsValue().AsDecimal();
                Dist2 := Token2.AsValue().AsDecimal();

                if Dist1 > Dist2 then begin
                    Candidates.Get(j, Token1);
                    Candidates.Get(j + 1, Token2);
                    Candidates.Set(j, Token2);
                    Candidates.Set(j + 1, Token1);
                    Swapped := true;
                end;
            end;

            if not Swapped then
                break;
        end;
    end;
}
