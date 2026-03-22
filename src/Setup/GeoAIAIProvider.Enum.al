/// <summary>
/// Enum GeoAI AI Provider (ID 70041).
/// Defines the available AI service providers for GeoAI operations.
/// </summary>
enum 70041 "GeoAI AI Provider"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; MicrosoftFoundry)
    {
        Caption = 'Microsoft Foundry';
    }
    value(2; LocalGateway)
    {
        Caption = 'Local AI Gateway';
    }
}
