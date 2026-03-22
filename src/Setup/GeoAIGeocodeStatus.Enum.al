/// <summary>
/// Enum GeoAI Geocode Status (ID 70044).
/// Defines the status of geocoding operations for entities.
/// </summary>
enum 70044 "GeoAI Geocode Status"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Success)
    {
        Caption = 'Success';
    }
    value(2; LowConfidence)
    {
        Caption = 'Low Confidence';
    }
    value(3; Failed)
    {
        Caption = 'Failed';
    }
}
