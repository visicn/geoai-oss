/// <summary>
/// Enum GeoAI Template Intent (ID 70098).
/// Captures the specific intent within a category (Find Nearby, Plan Route, etc.).
/// </summary>
enum 70098 "GeoAI Template Intent"
{
    Extensible = true;

    value(0; Undefined)
    {
        Caption = 'Undefined';
    }
    value(1; FindNearby)
    {
        Caption = 'Find Nearby';
    }
    value(2; FindNearest)
    {
        Caption = 'Find Nearest';
    }
    value(3; SearchInRegion)
    {
        Caption = 'Search in Region';
    }
    value(10; PlanRoute)
    {
        Caption = 'Plan Route';
    }
    value(11; ScheduleVisits)
    {
        Caption = 'Schedule Visits';
    }
    value(12; TerritoryPlanning)
    {
        Caption = 'Territory Planning';
    }
    value(20; Coverage)
    {
        Caption = 'Coverage Analysis';
    }
    value(21; Cluster)
    {
        Caption = 'Cluster Analysis';
    }
    value(22; Expansion)
    {
        Caption = 'Expansion Opportunities';
    }
}
