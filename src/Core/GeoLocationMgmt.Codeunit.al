/// <summary>
/// Codeunit GeoLocation Mgmt (ID 70046).
/// Core geolocation management for geocoding, reverse geocoding, and distance operations.
/// </summary>
codeunit 70046 "GeoLocation Mgmt"
{
    /// <summary>
    /// Geocodes an address to latitude and longitude coordinates.
    /// </summary>
    /// <param name="Address">The address text to geocode.</param>
    /// <param name="Latitude">Output: The latitude coordinate.</param>
    /// <param name="Longitude">Output: The longitude coordinate.</param>
    /// <param name="Confidence">Output: The confidence score (0-1) of the geocoding result.</param>
    /// <returns>True if geocoding was successful, false otherwise.</returns>
    procedure Geocode(Address: Text; var Latitude: Decimal; var Longitude: Decimal; var Confidence: Decimal): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        HTTPClient: Codeunit "GeoAI HTTP Client";
        RequestJson: Text;
        ResponseJson: Text;
        CacheKey: Text;
    begin
        if Address = '' then
            exit(false);

        GeoAISetup := GeoAISetup.GetInstance();

        if GeoAISetup."Cache Enabled" then begin
            CacheKey := GetGeocodeCacheKey(Address);
            if TryGetFromCache(CacheKey, Latitude, Longitude, Confidence) then
                exit(true);
        end;

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                RequestJson := BuildGoogleGeocodeRequest(Address);
            GeoAISetup."Map Provider"::Azure:
                RequestJson := BuildAzureGeocodeRequest(Address);
            else
                exit(false);
        end;

        // Execute request
        if not HTTPClient.ExecuteMapRequest(RequestJson, ResponseJson) then
            exit(false);

        if not ParseGeocodeResponse(ResponseJson, Latitude, Longitude, Confidence) then
            exit(false);

        if GeoAISetup."Cache Enabled" then
            StoreInCache(CacheKey, Latitude, Longitude, Confidence);

        exit(true);
    end;

    /// <summary>
    /// Reverse geocodes coordinates to an address.
    /// </summary>
    /// <param name="Latitude">The latitude coordinate.</param>
    /// <param name="Longitude">The longitude coordinate.</param>
    /// <returns>The address as text, or empty string if failed.</returns>
    procedure ReverseGeocode(Latitude: Decimal; Longitude: Decimal): Text
    var
        GeoAISetup: Record "GeoAI Setup";
        HTTPClient: Codeunit "GeoAI HTTP Client";
        RequestJson: Text;
        ResponseJson: Text;
        Address: Text;
        CacheKey: Text;
    begin
        if (Latitude = 0) and (Longitude = 0) then
            exit('');

        GeoAISetup := GeoAISetup.GetInstance();

        if GeoAISetup."Cache Enabled" then begin
            CacheKey := GetReverseGeocodeKey(Latitude, Longitude);
            if TryGetAddressFromCache(CacheKey, Address) then
                exit(Address);
        end;

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                RequestJson := BuildGoogleReverseRequest(Latitude, Longitude);
            GeoAISetup."Map Provider"::Azure:
                RequestJson := BuildAzureReverseRequest(Latitude, Longitude);
            else
                exit('');
        end;

        // Execute request
        if not HTTPClient.ExecuteMapRequest(RequestJson, ResponseJson) then
            exit('');

        // Parse response
        if not ParseReverseGeocodeResponse(ResponseJson, Address) then
            exit('');

        // Store in cache
        if GeoAISetup."Cache Enabled" then
            StoreAddressInCache(CacheKey, Address);

        exit(Address);
    end;

    /// <summary>
    /// Calculates distance matrix between multiple origins and destinations.
    /// </summary>
    /// <param name="OriginsJson">JSON array of origin coordinates.</param>
    /// <param name="DestinationsJson">JSON array of destination coordinates.</param>
    /// <param name="MatrixJson">Output: JSON representation of the distance matrix.</param>
    /// <returns>True if calculation was successful, false otherwise.</returns>
    procedure DistanceMatrix(OriginsJson: Text; DestinationsJson: Text; var MatrixJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        HTTPClient: Codeunit "GeoAI HTTP Client";
        RequestJson: Text;
        ResponseJson: Text;
    begin
        if (OriginsJson = '') or (DestinationsJson = '') then
            exit(false);

        GeoAISetup := GeoAISetup.GetInstance();

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                RequestJson := BuildGoogleMatrixRequest(OriginsJson, DestinationsJson);
            GeoAISetup."Map Provider"::Azure:
                RequestJson := BuildAzureMatrixRequest(OriginsJson, DestinationsJson);
            else
                exit(false);
        end;

        // Execute request
        if not HTTPClient.ExecuteMapRequest(RequestJson, ResponseJson) then
            exit(false);

        MatrixJson := ResponseJson;
        exit(true);
    end;

    /// <summary>
    /// Geocodes a record by its RecordId.
    /// Determines entity type and calls the appropriate geocoding procedure.
    /// OSS version supports Customer and Vendor only.
    /// </summary>
    /// <param name="EntityRecordId">The RecordId of the entity to geocode.</param>
    /// <returns>True if geocoding was successful, false otherwise.</returns>
    procedure GeocodeRecord(EntityRecordId: RecordId): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        RecordRef: RecordRef;
        TableNo: Integer;
        UnsupportedEntityErr: Label 'Entity type is not supported for geocoding in the OSS version. Only Customer and Vendor are supported.';
    begin
        if EntityRecordId.TableNo = 0 then
            exit(false);

        RecordRef.Open(EntityRecordId.TableNo);
        TableNo := RecordRef.Number;
        RecordRef.Close();

        case TableNo of
            Database::Customer:
                begin
                    if not Customer.Get(EntityRecordId) then
                        exit(false);
                    exit(Customer.GeocodeAddress());
                end;
            Database::Vendor:
                begin
                    if not Vendor.Get(EntityRecordId) then
                        exit(false);
                    exit(Vendor.GeocodeAddress());
                end;
            else begin
                Message(UnsupportedEntityErr);
                exit(false);
            end;
        end;
    end;

    /// <summary>
    /// Calculates the distance in kilometers between two coordinate points using Haversine formula.
    /// This is the primary distance calculation method for all GeoAI distance operations.
    /// </summary>
    /// <param name="Lat1">Latitude of first point in degrees.</param>
    /// <param name="Lon1">Longitude of first point in degrees.</param>
    /// <param name="Lat2">Latitude of second point in degrees.</param>
    /// <param name="Lon2">Longitude of second point in degrees.</param>
    /// <returns>Distance in kilometers (great circle distance).</returns>
    procedure HaversineDistanceKm(Lat1: Decimal; Lon1: Decimal; Lat2: Decimal; Lon2: Decimal): Decimal
    var
        EarthRadiusKm: Decimal;
        DLat: Decimal;
        DLon: Decimal;
        A: Decimal;
        C: Decimal;
        Lat1Rad: Decimal;
        Lat2Rad: Decimal;
    begin
        EarthRadiusKm := 6371.0;

        Lat1Rad := DegToRad(Lat1);
        Lat2Rad := DegToRad(Lat2);
        DLat := DegToRad(Lat2 - Lat1);
        DLon := DegToRad(Lon2 - Lon1);

        A := Power(Sin(DLat / 2), 2) +
             Cos(Lat1Rad) * Cos(Lat2Rad) *
             Power(Sin(DLon / 2), 2);

        C := 2 * ArcTan2(Sqrt(A), Sqrt(1 - A));

        exit(EarthRadiusKm * C);
    end;

    /// <summary>
    /// Encodes latitude and longitude into a geohash string for spatial indexing.
    /// Geohash subdivides space into buckets using base32 encoding.
    /// </summary>
    /// <param name="Lat">Latitude in decimal degrees (-90 to 90).</param>
    /// <param name="Lon">Longitude in decimal degrees (-180 to 180).</param>
    /// <param name="Precision">Number of geohash characters (1-12). Higher = more precise/smaller area.</param>
    /// <returns>Geohash string (e.g., "u4pruyd" for precision 7).</returns>
    procedure EncodeGeohash(Lat: Decimal; Lon: Decimal; Precision: Integer): Code[12]
    var
        Base32: Text;
        Result: Text;
        Bit: Integer;
        Ch: Integer;
        LatMin: Decimal;
        LatMax: Decimal;
        LonMin: Decimal;
        LonMax: Decimal;
        Mid: Decimal;
        IsEven: Boolean;
    begin
        // Validate inputs
        if (Lat < -90) or (Lat > 90) then
            Error('Latitude must be between -90 and 90 degrees.');
        if (Lon < -180) or (Lon > 180) then
            Error('Longitude must be between -180 and 180 degrees.');
        if (Precision < 1) or (Precision > 12) then
            Precision := 6;

        Base32 := '0123456789bcdefghjkmnpqrstuvwxyz';
        Result := '';

        LatMin := -90.0;
        LatMax := 90.0;
        LonMin := -180.0;
        LonMax := 180.0;

        IsEven := true;
        Bit := 0;
        Ch := 0;

        while StrLen(Result) < Precision do begin
            if IsEven then begin
                Mid := (LonMin + LonMax) / 2;
                if Lon > Mid then begin
                    Ch := Ch * 2 + 1;
                    LonMin := Mid;
                end else begin
                    Ch := Ch * 2;
                    LonMax := Mid;
                end;
            end else begin
                Mid := (LatMin + LatMax) / 2;
                if Lat > Mid then begin
                    Ch := Ch * 2 + 1;
                    LatMin := Mid;
                end else begin
                    Ch := Ch * 2;
                    LatMax := Mid;
                end;
            end;

            IsEven := not IsEven;
            Bit := Bit + 1;

            if Bit = 5 then begin
                Result := Result + CopyStr(Base32, Ch + 1, 1);
                Bit := 0;
                Ch := 0;
            end;
        end;

        exit(CopyStr(Result, 1, 12));
    end;

    /// <summary>
    /// Gets geohash prefix for a coordinate pair at specified precision.
    /// Wrapper around EncodeGeohash for clarity.
    /// </summary>
    /// <param name="Lat">Latitude in decimal degrees.</param>
    /// <param name="Lon">Longitude in decimal degrees.</param>
    /// <param name="Precision">Geohash precision (characters).</param>
    /// <returns>Geohash prefix string.</returns>
    procedure GetGeohashPrefix(Lat: Decimal; Lon: Decimal; Precision: Integer): Code[12]
    begin
        exit(EncodeGeohash(Lat, Lon, Precision));
    end;

    local procedure DegToRad(Deg: Decimal): Decimal
    begin
        exit(Deg * 3.14159265358979323846 / 180);
    end;

    local procedure GetGeocodeCacheKey(Address: Text): Text
    begin
        exit('GEOCODE:' + Address);
    end;

    local procedure GetReverseGeocodeKey(Latitude: Decimal; Longitude: Decimal): Text
    begin
        exit('REVERSE:' + Format(Latitude, 0, 9) + ',' + Format(Longitude, 0, 9));
    end;

    local procedure BuildGoogleGeocodeRequest(Address: Text): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'google');
        RequestJson.Add('operation', 'geocode');
        RequestJson.Add('address', Address);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure BuildAzureGeocodeRequest(Address: Text): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'azure');
        RequestJson.Add('operation', 'geocode');
        RequestJson.Add('address', Address);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure BuildGoogleReverseRequest(Latitude: Decimal; Longitude: Decimal): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'google');
        RequestJson.Add('operation', 'reverse');
        RequestJson.Add('latitude', Latitude);
        RequestJson.Add('longitude', Longitude);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure BuildAzureReverseRequest(Latitude: Decimal; Longitude: Decimal): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'azure');
        RequestJson.Add('operation', 'reverse');
        RequestJson.Add('latitude', Latitude);
        RequestJson.Add('longitude', Longitude);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure BuildGoogleMatrixRequest(OriginsJson: Text; DestinationsJson: Text): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'google');
        RequestJson.Add('operation', 'matrix');
        RequestJson.Add('origins', OriginsJson);
        RequestJson.Add('destinations', DestinationsJson);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure BuildAzureMatrixRequest(OriginsJson: Text; DestinationsJson: Text): Text
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('provider', 'azure');
        RequestJson.Add('operation', 'matrix');
        RequestJson.Add('origins', OriginsJson);
        RequestJson.Add('destinations', DestinationsJson);
        exit(FormatJsonText(RequestJson));
    end;

    local procedure ParseGeocodeResponse(ResponseJson: Text; var Latitude: Decimal; var Longitude: Decimal; var Confidence: Decimal): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                exit(ParseGoogleGeocodeResponse(ResponseJson, Latitude, Longitude, Confidence));
            GeoAISetup."Map Provider"::Azure:
                exit(ParseAzureGeocodeResponse(ResponseJson, Latitude, Longitude, Confidence));
            else
                exit(false);
        end;
    end;

    local procedure ParseGoogleGeocodeResponse(ResponseJson: Text; var Latitude: Decimal; var Longitude: Decimal; var Confidence: Decimal): Boolean
    var
        ResponseObject: JsonObject;
        StatusToken: JsonToken;
        ResultsToken: JsonToken;
        ResultsArray: JsonArray;
        FirstResultToken: JsonToken;
        FirstResult: JsonObject;
        GeometryToken: JsonToken;
        GeometryObject: JsonObject;
        LocationToken: JsonToken;
        LocationObject: JsonObject;
        LatToken: JsonToken;
        LngToken: JsonToken;
        LocationTypeToken: JsonToken;
        LocationType: Text;
    begin
        if not ResponseObject.ReadFrom(ResponseJson) then
            exit(false);

        // Check status
        if not ResponseObject.Get('status', StatusToken) then
            exit(false);

        if StatusToken.AsValue().AsText() <> 'OK' then
            exit(false);

        // Get results array
        if not ResponseObject.Get('results', ResultsToken) then
            exit(false);

        if not ResultsToken.IsArray() then
            exit(false);

        ResultsArray := ResultsToken.AsArray();
        if ResultsArray.Count = 0 then
            exit(false);

        // Get first result
        if not ResultsArray.Get(0, FirstResultToken) then
            exit(false);

        if not FirstResultToken.IsObject() then
            exit(false);

        FirstResult := FirstResultToken.AsObject();

        // Navigate to geometry.location
        if not FirstResult.Get('geometry', GeometryToken) then
            exit(false);

        if not GeometryToken.IsObject() then
            exit(false);

        GeometryObject := GeometryToken.AsObject();

        if not GeometryObject.Get('location', LocationToken) then
            exit(false);

        if not LocationToken.IsObject() then
            exit(false);

        LocationObject := LocationToken.AsObject();

        // Extract lat and lng
        if not LocationObject.Get('lat', LatToken) then
            exit(false);

        if not LocationObject.Get('lng', LngToken) then
            exit(false);

        Latitude := LatToken.AsValue().AsDecimal();
        Longitude := LngToken.AsValue().AsDecimal();

        // Calculate confidence from location_type
        if GeometryObject.Get('location_type', LocationTypeToken) then begin
            LocationType := LocationTypeToken.AsValue().AsText();
            case LocationType of
                'ROOFTOP':
                    Confidence := 1.0;
                'RANGE_INTERPOLATED':
                    Confidence := 0.85;
                'GEOMETRIC_CENTER':
                    Confidence := 0.75;
                'APPROXIMATE':
                    Confidence := 0.60;
                else
                    Confidence := 0.50;
            end;
        end else
            Confidence := 0.75;

        exit(true);
    end;

    local procedure ParseAzureGeocodeResponse(ResponseJson: Text; var Latitude: Decimal; var Longitude: Decimal; var Confidence: Decimal): Boolean
    var
        ResponseObject: JsonObject;
        ResultsToken: JsonToken;
        ResultsArray: JsonArray;
        FirstResultToken: JsonToken;
        FirstResult: JsonObject;
        PositionToken: JsonToken;
        PositionObject: JsonObject;
        LatToken: JsonToken;
        LonToken: JsonToken;
        ScoreToken: JsonToken;
    begin
        if not ResponseObject.ReadFrom(ResponseJson) then
            exit(false);

        // Get results array
        if not ResponseObject.Get('results', ResultsToken) then
            exit(false);

        if not ResultsToken.IsArray() then
            exit(false);

        ResultsArray := ResultsToken.AsArray();
        if ResultsArray.Count = 0 then
            exit(false);

        // Get first result
        if not ResultsArray.Get(0, FirstResultToken) then
            exit(false);

        if not FirstResultToken.IsObject() then
            exit(false);

        FirstResult := FirstResultToken.AsObject();

        // Get position
        if not FirstResult.Get('position', PositionToken) then
            exit(false);

        if not PositionToken.IsObject() then
            exit(false);

        PositionObject := PositionToken.AsObject();

        // Extract lat and lon
        if not PositionObject.Get('lat', LatToken) then
            exit(false);

        if not PositionObject.Get('lon', LonToken) then
            exit(false);

        Latitude := LatToken.AsValue().AsDecimal();
        Longitude := LonToken.AsValue().AsDecimal();

        // Get confidence from score (0-1)
        if FirstResult.Get('score', ScoreToken) then
            Confidence := ScoreToken.AsValue().AsDecimal()
        else
            Confidence := 0.75;

        exit(true);
    end;

    local procedure ParseReverseGeocodeResponse(ResponseJson: Text; var Address: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                exit(ParseGoogleReverseResponse(ResponseJson, Address));
            GeoAISetup."Map Provider"::Azure:
                exit(ParseAzureReverseResponse(ResponseJson, Address));
            else
                exit(false);
        end;
    end;

    local procedure ParseGoogleReverseResponse(ResponseJson: Text; var Address: Text): Boolean
    var
        ResponseObject: JsonObject;
        StatusToken: JsonToken;
        ResultsToken: JsonToken;
        ResultsArray: JsonArray;
        FirstResultToken: JsonToken;
        FirstResult: JsonObject;
        FormattedAddressToken: JsonToken;
    begin
        if not ResponseObject.ReadFrom(ResponseJson) then
            exit(false);

        // Check status
        if not ResponseObject.Get('status', StatusToken) then
            exit(false);

        if StatusToken.AsValue().AsText() <> 'OK' then
            exit(false);

        // Get results array
        if not ResponseObject.Get('results', ResultsToken) then
            exit(false);

        if not ResultsToken.IsArray() then
            exit(false);

        ResultsArray := ResultsToken.AsArray();
        if ResultsArray.Count = 0 then
            exit(false);

        // Get first result
        if not ResultsArray.Get(0, FirstResultToken) then
            exit(false);

        if not FirstResultToken.IsObject() then
            exit(false);

        FirstResult := FirstResultToken.AsObject();

        // Get formatted_address
        if not FirstResult.Get('formatted_address', FormattedAddressToken) then
            exit(false);

        Address := FormattedAddressToken.AsValue().AsText();
        exit(Address <> '');
    end;

    local procedure ParseAzureReverseResponse(ResponseJson: Text; var Address: Text): Boolean
    var
        ResponseObject: JsonObject;
        AddressesToken: JsonToken;
        AddressesArray: JsonArray;
        FirstAddressToken: JsonToken;
        FirstAddress: JsonObject;
        AddressToken: JsonToken;
        AddressObject: JsonObject;
        FreeformToken: JsonToken;
    begin
        if not ResponseObject.ReadFrom(ResponseJson) then
            exit(false);

        // Get addresses array
        if not ResponseObject.Get('addresses', AddressesToken) then
            exit(false);

        if not AddressesToken.IsArray() then
            exit(false);

        AddressesArray := AddressesToken.AsArray();
        if AddressesArray.Count = 0 then
            exit(false);

        // Get first address
        if not AddressesArray.Get(0, FirstAddressToken) then
            exit(false);

        if not FirstAddressToken.IsObject() then
            exit(false);

        FirstAddress := FirstAddressToken.AsObject();

        // Get address.freeformAddress
        if not FirstAddress.Get('address', AddressToken) then
            exit(false);

        if not AddressToken.IsObject() then
            exit(false);

        AddressObject := AddressToken.AsObject();

        if not AddressObject.Get('freeformAddress', FreeformToken) then
            exit(false);

        Address := FreeformToken.AsValue().AsText();
        exit(Address <> '');
    end;

    local procedure TryGetFromCache(CacheKey: Text; var Latitude: Decimal; var Longitude: Decimal; var Confidence: Decimal): Boolean
    var
        GeocodeCache: Record "GeoAI Geocode Cache";
    begin
        GeocodeCache.SetRange("Cache Key", CacheKey);
        if not GeocodeCache.FindFirst() then
            exit(false);

        Latitude := GeocodeCache.Latitude;
        Longitude := GeocodeCache.Longitude;
        Confidence := GeocodeCache.Confidence;

        GeocodeCache.RecordHit();
        exit(true);
    end;

    local procedure TryGetAddressFromCache(CacheKey: Text; var Address: Text): Boolean
    var
        GeocodeCache: Record "GeoAI Geocode Cache";
    begin
        GeocodeCache.SetRange("Cache Key", CacheKey);
        if not GeocodeCache.FindFirst() then
            exit(false);

        Address := GeocodeCache."Reverse Address";
        GeocodeCache.RecordHit();
        exit(Address <> '');
    end;

    local procedure StoreInCache(CacheKey: Text; Latitude: Decimal; Longitude: Decimal; Confidence: Decimal)
    var
        GeocodeCache: Record "GeoAI Geocode Cache";
    begin
        GeocodeCache.SetRange("Cache Key", CopyStr(CacheKey, 1, 250));
        if GeocodeCache.FindFirst() then begin
            GeocodeCache.Latitude := Latitude;
            GeocodeCache.Longitude := Longitude;
            GeocodeCache.Confidence := Confidence;
            GeocodeCache.RecordHit();
            GeocodeCache.Modify(true);
        end else begin
            GeocodeCache.Init();
            GeocodeCache."Cache Key" := CopyStr(CacheKey, 1, MaxStrLen(GeocodeCache."Cache Key"));
            GeocodeCache.Latitude := Latitude;
            GeocodeCache.Longitude := Longitude;
            GeocodeCache.Confidence := Confidence;
            GeocodeCache.Insert(true);
        end;
    end;

    local procedure StoreAddressInCache(CacheKey: Text; Address: Text)
    var
        GeocodeCache: Record "GeoAI Geocode Cache";
    begin
        GeocodeCache.SetRange("Cache Key", CopyStr(CacheKey, 1, 250));
        if GeocodeCache.FindFirst() then begin
            GeocodeCache."Reverse Address" := CopyStr(Address, 1, MaxStrLen(GeocodeCache."Reverse Address"));
            GeocodeCache.RecordHit();
            GeocodeCache.Modify(true);
        end else begin
            GeocodeCache.Init();
            GeocodeCache."Cache Key" := CopyStr(CacheKey, 1, MaxStrLen(GeocodeCache."Cache Key"));
            GeocodeCache."Reverse Address" := CopyStr(Address, 1, MaxStrLen(GeocodeCache."Reverse Address"));
            GeocodeCache.Insert(true);
        end;
    end;

    local procedure FormatJsonText(JsonObj: JsonObject): Text
    var
        JsonText: Text;
    begin
        JsonObj.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure Sin(Value: Decimal): Decimal
    var
        x: Decimal;
        x3: Decimal;
        x5: Decimal;
        x7: Decimal;
        Result: Decimal;
    begin
        // Normalize to [-π, π]
        x := Value;
        while x > 3.14159265358979323846 do
            x := x - (2 * 3.14159265358979323846);
        while x < -3.14159265358979323846 do
            x := x + (2 * 3.14159265358979323846);

        // Taylor series: sin(x) ≈ x - x³/6 + x⁵/120 - x⁷/5040
        x3 := x * x * x;
        x5 := x3 * x * x;
        x7 := x5 * x * x;

        Result := x - (x3 / 6) + (x5 / 120) - (x7 / 5040);

        exit(Result);
    end;

    local procedure Cos(Value: Decimal): Decimal
    var
        x: Decimal;
        x2: Decimal;
        x4: Decimal;
        x6: Decimal;
        Result: Decimal;
    begin
        // Normalize to [-π, π]
        x := Value;
        while x > 3.14159265358979323846 do
            x := x - (2 * 3.14159265358979323846);
        while x < -3.14159265358979323846 do
            x := x + (2 * 3.14159265358979323846);

        // Taylor series: cos(x) ≈ 1 - x²/2 + x⁴/24 - x⁶/720
        x2 := x * x;
        x4 := x2 * x2;
        x6 := x4 * x2;

        Result := 1 - (x2 / 2) + (x4 / 24) - (x6 / 720);

        // Clamp to [-1, 1]
        if Result > 1 then
            Result := 1;
        if Result < -1 then
            Result := -1;

        exit(Result);
    end;

    local procedure Sqrt(Value: Decimal): Decimal
    var
        Guess: Decimal;
        LastGuess: Decimal;
        Iteration: Integer;
        Tolerance: Decimal;
    begin
        // Clamp negative values to 0
        if Value <= 0 then
            exit(0);

        if Value = 1 then
            exit(1);

        // Initial guess
        Guess := Value / 2;
        Tolerance := 0.000001;

        // Newton's method: x_new = (x + value/x) / 2
        for Iteration := 1 to 30 do begin
            LastGuess := Guess;
            Guess := (Guess + Value / Guess) / 2;

            // Check convergence
            if Abs(Guess - LastGuess) < Tolerance then
                exit(Guess);
        end;

        exit(Guess);
    end;

    local procedure ArcTan2(Y: Decimal; X: Decimal): Decimal
    var
        Angle: Decimal;
        AbsY: Decimal;
        R: Decimal;
    begin
        // Handle special cases
        if (X = 0) and (Y = 0) then
            exit(0);

        if X = 0 then
            if Y > 0 then
                exit(3.14159265358979323846 / 2)  // π/2
            else
                exit(-3.14159265358979323846 / 2);  // -π/2

        // Use atan(y/x) approximation
        AbsY := Abs(Y);
        if Abs(X) >= AbsY then begin
            R := Y / X;
            Angle := ArcTanApprox(R);
            if X < 0 then
                if Y >= 0 then
                    Angle := Angle + 3.14159265358979323846
                else
                    Angle := Angle - 3.14159265358979323846;
        end else begin
            R := X / Y;
            Angle := ArcTanApprox(R);
            if Y < 0 then
                Angle := -3.14159265358979323846 / 2 - Angle
            else
                Angle := 3.14159265358979323846 / 2 - Angle;
        end;

        exit(Angle);
    end;

    local procedure ArcTanApprox(x: Decimal): Decimal
    var
        x3: Decimal;
        x5: Decimal;
        x7: Decimal;
    begin
        // Taylor series for small angles: atan(x) ≈ x - x³/3 + x⁵/5 - x⁷/7
        if Abs(x) > 1 then
            exit(1.5708 - ArcTanApprox(1 / x));  // Use identity for |x| > 1

        x3 := x * x * x;
        x5 := x3 * x * x;
        x7 := x5 * x * x;

        exit(x - (x3 / 3) + (x5 / 5) - (x7 / 7));
    end;
}
