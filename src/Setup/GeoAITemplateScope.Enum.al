/// <summary>
/// Enum GeoAI Template Scope (ID 70099).
/// Indicates which data scope a template expects (self record, selection, etc.).
/// </summary>
enum 70099 "GeoAI Template Scope"
{
    Extensible = true;

    value(0; Self)
    {
        Caption = 'Self';
    }
    value(1; Selection)
    {
        Caption = 'Selection';
    }
    value(2; Company)
    {
        Caption = 'Company';
    }
    value(3; Region)
    {
        Caption = 'Region';
    }
}
