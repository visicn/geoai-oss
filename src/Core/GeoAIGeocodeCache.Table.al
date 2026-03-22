/// <summary>
/// Table GeoAI Geocode Cache (ID 70002).
/// Caches geocoding and reverse geocoding results to reduce external API calls.
/// </summary>
table 70002 "GeoAI Geocode Cache"
{
    Caption = 'GeoAI Geocode Cache';
    DataClassification = CustomerContent;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Cache Key"; Text[250])
        {
            Caption = 'Cache Key';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(10; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 8;
        }
        field(11; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 8;
        }
        field(12; "Reverse Address"; Text[500])
        {
            Caption = 'Reverse Address';
            DataClassification = CustomerContent;
        }
        field(20; Quality; Enum "GeoAI Geocode Status")
        {
            Caption = 'Quality';
            DataClassification = SystemMetadata;
            InitValue = Success;
        }
        field(30; Confidence; Decimal)
        {
            Caption = 'Confidence';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 1;
            InitValue = 0.85;
        }
        field(40; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "Last Used DateTime"; DateTime)
        {
            Caption = 'Last Used DateTime';
            DataClassification = SystemMetadata;
        }
        field(42; "Usage Count"; Integer)
        {
            Caption = 'Usage Count';
            DataClassification = SystemMetadata;
            MinValue = 0;
            InitValue = 0;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(CacheKey; "Cache Key")
        {
            Unique = true;
        }
        key(Created; "Created DateTime")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created DateTime" = 0DT then
            "Created DateTime" := CurrentDateTime();
        "Last Used DateTime" := CurrentDateTime();
        "Usage Count" := 1;
    end;

    /// <summary>
    /// Records a cache hit by updating last used time and incrementing usage count.
    /// </summary>
    procedure RecordHit()
    begin
        "Last Used DateTime" := CurrentDateTime();
        "Usage Count" += 1;
        Modify(true);
    end;

    /// <summary>
    /// Purges cache entries older than the specified number of days.
    /// </summary>
    /// <param name="RetentionDays">Number of days to retain cache entries.</param>
    /// <returns>Number of entries deleted.</returns>
    procedure PurgeOldEntries(RetentionDays: Integer): Integer
    var
        GeocodeCache: Record "GeoAI Geocode Cache";
        CutoffDate: DateTime;
        DeletedCount: Integer;
    begin
        if RetentionDays <= 0 then
            exit(0);

        CutoffDate := CurrentDateTime() - (RetentionDays * 24 * 60 * 60 * 1000);
        DeletedCount := 0;

        GeocodeCache.SetFilter("Created DateTime", '<%1', CutoffDate);
        if GeocodeCache.FindSet() then
            repeat
                GeocodeCache.Delete(true);
                DeletedCount += 1;
            until GeocodeCache.Next() = 0;

        exit(DeletedCount);
    end;
}
