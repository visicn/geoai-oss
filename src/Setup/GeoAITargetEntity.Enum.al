/// <summary>
/// Enum GeoAI Target Entity (ID 70096).
/// Identifies which record type a prompt template operates on.
/// </summary>
enum 70096 "GeoAI Target Entity"
{
    Extensible = true;

    value(0; Any)
    {
        Caption = 'Any';
    }
    value(1; SameAsAnchor)
    {
        Caption = 'Same as Anchor';
    }
    value(10; Customer)
    {
        Caption = 'Customer';
    }
    value(11; Vendor)
    {
        Caption = 'Vendor';
    }
    value(12; Contact)
    {
        Caption = 'Contact';
    }
    value(13; Employee)
    {
        Caption = 'Employee';
    }
    value(14; Resource)
    {
        Caption = 'Resource';
    }
    value(15; Job)
    {
        Caption = 'Job';
    }
    value(16; Location)
    {
        Caption = 'Location';
    }
    value(17; BankAccount)
    {
        Caption = 'Bank Account';
    }
}
