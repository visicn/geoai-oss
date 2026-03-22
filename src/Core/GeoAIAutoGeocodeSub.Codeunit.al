/// <summary>
/// Codeunit GeoAI Auto Geocode Sub (ID 70065).
/// Automatically clears geocode data when address fields change on entities.
/// Subscribes to OnAfterModifyEvent for Customer, Vendor, Contact, Employee, Location, Resource, Job, and Bank Account.
/// </summary>
codeunit 70065 "GeoAI Auto Geocode Sub"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCustomer(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyVendor(var Rec: Record Vendor; var xRec: Record Vendor; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyContact(var Rec: Record Contact; var xRec: Record Contact; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEmployee(var Rec: Record Employee; var xRec: Record Employee; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyResource(var Rec: Record Resource; var xRec: Record Resource; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyJob(var Rec: Record Job; var xRec: Record Job; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec."Bill-to Address", xRec."Bill-to Address", Rec."Bill-to Address 2", xRec."Bill-to Address 2", Rec."Bill-to City", xRec."Bill-to City", Rec."Bill-to Post Code", xRec."Bill-to Post Code", Rec."Bill-to Country/Region Code", xRec."Bill-to Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyBankAccount(var Rec: Record "Bank Account"; var xRec: Record "Bank Account"; RunTrigger: Boolean)
    var
        Setup: Record "GeoAI Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Setup.Get() then
            exit;

        if not Setup."Auto Geocode on Address Change" then
            exit;

        if IsAddressChanged(Rec.Address, xRec.Address, Rec."Address 2", xRec."Address 2", Rec.City, xRec.City, Rec."Post Code", xRec."Post Code", Rec."Country/Region Code", xRec."Country/Region Code") then
            ClearGeocodeFields(Rec);
    end;

    local procedure IsAddressChanged(Address: Text[100]; xAddress: Text[100]; Address2: Text[50]; xAddress2: Text[50]; City: Text[30]; xCity: Text[30]; PostCode: Code[20]; xPostCode: Code[20]; CountryRegion: Code[10]; xCountryRegion: Code[10]): Boolean
    begin
        exit((Address <> xAddress) or (Address2 <> xAddress2) or (City <> xCity) or (PostCode <> xPostCode) or (CountryRegion <> xCountryRegion));
    end;

    local procedure ClearGeocodeFields(RecVariant: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        RecRef.GetTable(RecVariant);

        if TryGetFieldRef(RecRef, 1000000, FieldRef) then
            FieldRef.Value := 0;

        if TryGetFieldRef(RecRef, 1000001, FieldRef) then
            FieldRef.Value := 0;

        if TryGetFieldRef(RecRef, 1000002, FieldRef) then
            FieldRef.Value := '';

        if TryGetFieldRef(RecRef, 1000003, FieldRef) then
            FieldRef.Value := 0;

        if TryGetFieldRef(RecRef, 1000004, FieldRef) then
            FieldRef.Value := 0;

        // Clear GeoAI Geocode Source
        if TryGetFieldRef(RecRef, 1000005, FieldRef) then
            FieldRef.Value := 0; // Enum value for blank

        // Clear GeoAI Last Geocode DateTime
        if TryGetFieldRef(RecRef, 1000006, FieldRef) then
            FieldRef.Value := 0DT;

        RecRef.Modify(true);
        RecRef.SetTable(RecVariant);

        // Telemetry
        CustomDimensions.Add('TableNo', Format(RecRef.Number));
        CustomDimensions.Add('TableName', RecRef.Name);
        Session.LogMessage('GEOAI070', 'Geocode fields cleared due to address change', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    [TryFunction]
    local procedure TryGetFieldRef(var RecRef: RecordRef; FieldNo: Integer; var FieldRef: FieldRef)
    begin
        FieldRef := RecRef.Field(FieldNo);
    end;
}
