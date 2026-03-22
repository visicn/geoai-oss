/// <summary>
/// PageExtension Vendor List GeoAI (ID 70053) extends Page Vendor List.
/// Adds GeoAI actions to Vendor List page.
/// </summary>
pageextension 70053 "Vendor List GeoAI" extends "Vendor List"
{
    actions
    {
        addlast(navigation)
        {
            group(GeoAI)
            {
                Caption = 'GeoAI';
                Image = Sparkle;

                action(AskGeoAI)
                {
                    ApplicationArea = All;
                    Caption = 'Ask GeoAI...';
                    ToolTip = 'Opens GeoAI prompt copilot for the selected vendor.';
                    Image = Sparkle;

                    trigger OnAction()
                    var
                        Vendor: Record Vendor;
                        PromptLauncher: Codeunit "GeoAI Prompt Launcher";
                    begin
                        CurrPage.SetSelectionFilter(Vendor);
                        if not Vendor.FindFirst() then
                            exit;

                        PromptLauncher.LaunchPromptDialog(
                          Vendor.RecordId,
                          "GeoAI Entity Type"::Vendor,
                          "GeoAI Template Scope"::Selection);
                    end;
                }

                action(ViewOnMap)
                {
                    ApplicationArea = All;
                    Caption = 'View on Map';
                    ToolTip = 'Opens the first selected vendor location in an external mapping service.';
                    Image = Map;

                    trigger OnAction()
                    var
                        Vendor: Record Vendor;
                        MapUrlFormatter: Codeunit "GeoAI Map URL Formatter";
                    begin
                        CurrPage.SetSelectionFilter(Vendor);
                        if not Vendor.FindFirst() then
                            exit;

                        MapUrlFormatter.OpenMapForCoordinates(Vendor."GeoAI Latitude", Vendor."GeoAI Longitude");
                    end;
                }

                action(GeocodeSelected)
                {
                    ApplicationArea = All;
                    Image = MapSetup;
                    Caption = 'Geocode Selected';
                    ToolTip = 'Geocodes addresses for all selected vendors.';

                    trigger OnAction()
                    var
                        Vendor: Record Vendor;
                        SuccessCount: Integer;
                        FailCount: Integer;
                        ResultMsg: Label 'Geocoding complete. Success: %1, Failed: %2', Comment = '%1 = Success count, %2 = Fail count';
                    begin
                        CurrPage.SetSelectionFilter(Vendor);
                        if Vendor.FindSet() then
                            repeat
                                if Vendor.GeocodeAddress() then
                                    SuccessCount += 1
                                else
                                    FailCount += 1;
                            until Vendor.Next() = 0;

                        Message(ResultMsg, SuccessCount, FailCount);
                    end;
                }
            }
        }
    }
}
