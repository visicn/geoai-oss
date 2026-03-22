/// <summary>
/// TableExtension Customer GeoAI (ID 70010) extends Record Customer.
/// Adds geolocation fields to Customer table.
/// </summary>
tableextension 70010 "Customer GeoAI" extends Customer
{
    fields
    {
        field(70000; "GeoAI Latitude"; Decimal)
        {
            Caption = 'Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 8;
        }
        field(70001; "GeoAI Longitude"; Decimal)
        {
            Caption = 'Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 8;
        }
        field(70002; "GeoAI GeoHash"; Code[20])
        {
            Caption = 'GeoHash';
            DataClassification = SystemMetadata;
        }
        field(70003; "GeoAI Geocode Status Field"; Enum "GeoAI Geocode Status")
        {
            Caption = 'Geocode Status';
            DataClassification = SystemMetadata;
        }
        field(70004; "GeoAI Geocode Confidence"; Decimal)
        {
            Caption = 'Geocode Confidence';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(70005; "GeoAI Geocode Source Field"; Enum "GeoAI Geocode Source")
        {
            Caption = 'Geocode Source';
            DataClassification = SystemMetadata;
        }
        field(70006; "GeoAI Last Geocode DateTime"; DateTime)
        {
            Caption = 'Last Geocode DateTime';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    /// <summary>
    /// Geocodes the customer address and updates coordinates.
    /// </summary>
    procedure GeocodeAddress(): Boolean
    var
        GeoLocationMgmt: Codeunit "GeoLocation Mgmt";
        Address: Text;
        Latitude: Decimal;
        Longitude: Decimal;
        Confidence: Decimal;
    begin
        Address := BuildFullAddress();
        if Address = '' then
            exit(false);

        if not GeoLocationMgmt.Geocode(Address, Latitude, Longitude, Confidence) then begin
            "GeoAI Geocode Status Field" := "GeoAI Geocode Status Field"::Failed;
            Modify(true);
            exit(false);
        end;

        "GeoAI Latitude" := Latitude;
        "GeoAI Longitude" := Longitude;
        "GeoAI Geocode Confidence" := Confidence;
        "GeoAI Last Geocode DateTime" := CurrentDateTime();

        if Confidence >= 0.75 then
            "GeoAI Geocode Status Field" := "GeoAI Geocode Status Field"::Success
        else
            "GeoAI Geocode Status Field" := "GeoAI Geocode Status Field"::LowConfidence;

        Modify(true);
        exit(true);
    end;

    /// <summary>
    /// Builds the full address string for geocoding.
    /// </summary>
    local procedure BuildFullAddress(): Text
    var
        FullAddress: Text;
    begin
        FullAddress := Address;

        if "Address 2" <> '' then
            FullAddress := FullAddress + ', ' + "Address 2";

        if City <> '' then
            FullAddress := FullAddress + ', ' + City;

        if "Post Code" <> '' then
            FullAddress := FullAddress + ' ' + "Post Code";

        if "Country/Region Code" <> '' then
            FullAddress := FullAddress + ', ' + "Country/Region Code";

        exit(FullAddress.Trim());
    end;

    /// <summary>
    /// Checks if geocoding is needed (address changed or never geocoded).
    /// </summary>
    procedure NeedsGeocoding(): Boolean
    begin
        if "GeoAI Geocode Status Field" = "GeoAI Geocode Status Field"::" " then
            exit(true);

        if "GeoAI Geocode Status Field" = "GeoAI Geocode Status Field"::Failed then
            exit(true);

        exit(false);
    end;
}
