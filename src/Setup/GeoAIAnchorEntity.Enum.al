/// <summary>
/// Enum GeoAI Anchor Entity (ID 70100).
/// Defines which record type a prompt template is anchored to.
/// </summary>
enum 70100 "GeoAI Anchor Entity"
{
    Extensible = true;

    value(0; Any)
    {
        Caption = 'Any';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Vendor)
    {
        Caption = 'Vendor';
    }
    value(3; Contact)
    {
        Caption = 'Contact';
    }
    value(4; Employee)
    {
        Caption = 'Employee';
    }
    value(5; Resource)
    {
        Caption = 'Resource';
    }
    value(6; Job)
    {
        Caption = 'Job';
    }
    value(7; Location)
    {
        Caption = 'Location';
    }
    value(8; BankAccount)
    {
        Caption = 'Bank Account';
    }
}
