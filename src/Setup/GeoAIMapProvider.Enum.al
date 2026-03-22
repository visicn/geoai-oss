/// <summary>
/// Enum GeoAI Map Provider (ID 70040).
/// Defines the available map and geocoding service providers.
/// </summary>
enum 70040 "GeoAI Map Provider"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Google)
    {
        Caption = 'Google Maps';
    }
    value(2; Azure)
    {
        Caption = 'Azure Maps';
    }
}
