table 70003 "GeoAI Result Item"
{
    Caption = 'GeoAI Result Item';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item Id"; Code[100])
        {
            Caption = 'Item Id';
        }
        field(3; Name; Text[250])
        {
            Caption = 'Name';
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(5; "Distance (km)"; Decimal)
        {
            Caption = 'Distance (km)';
            DecimalPlaces = 0 : 5;
        }
        field(6; "ETA (minutes)"; Decimal)
        {
            Caption = 'ETA (minutes)';
            DecimalPlaces = 0 : 2;
        }
        field(7; Score; Decimal)
        {
            Caption = 'Score';
            DecimalPlaces = 0 : 5;
        }
        field(8; Latitude; Decimal)
        {
            Caption = 'Latitude';
            DecimalPlaces = 0 : 9;
        }
        field(9; Longitude; Decimal)
        {
            Caption = 'Longitude';
            DecimalPlaces = 0 : 9;
        }
        field(10; Payload; Text[2048])
        {
            Caption = 'Payload';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
