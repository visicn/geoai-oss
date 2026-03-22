/// <summary>
/// Enum GeoAI Geocode Source (ID 70045).
/// Defines the source of geocoding data for entities.
/// </summary>
enum 70045 "GeoAI Geocode Source"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Manual)
    {
        Caption = 'Manual';
    }
    value(2; Google)
    {
        Caption = 'Google Maps';
    }
    value(3; Azure)
    {
        Caption = 'Azure Maps';
    }
}
