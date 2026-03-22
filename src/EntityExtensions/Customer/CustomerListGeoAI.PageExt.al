/// <summary>
/// PageExtension Customer List GeoAI (ID 70051) extends Page Customer List.
/// Adds GeoAI actions to Customer List page.
/// </summary>
pageextension 70051 "Customer List GeoAI" extends "Customer List"
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
                    ToolTip = 'Opens GeoAI prompt copilot for the selected customer.';
                    Image = Sparkle;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        PromptLauncher: Codeunit "GeoAI Prompt Launcher";
                    begin
                        CurrPage.SetSelectionFilter(Customer);
                        if not Customer.FindFirst() then
                            exit;

                        PromptLauncher.LaunchPromptDialog(
                          Customer.RecordId,
                          "GeoAI Entity Type"::Customer,
                          "GeoAI Template Scope"::Selection);
                    end;
                }

                action(ViewOnMap)
                {
                    ApplicationArea = All;
                    Caption = 'View on Map';
                    ToolTip = 'Opens the first selected customer location in an external mapping service.';
                    Image = Map;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        MapUrlFormatter: Codeunit "GeoAI Map URL Formatter";
                    begin
                        CurrPage.SetSelectionFilter(Customer);
                        if not Customer.FindFirst() then
                            exit;

                        MapUrlFormatter.OpenMapForCoordinates(Customer."GeoAI Latitude", Customer."GeoAI Longitude");
                    end;
                }

                action(GeocodeSelected)
                {
                    ApplicationArea = All;
                    Image = MapSetup;
                    Caption = 'Geocode Selected';
                    ToolTip = 'Geocodes addresses for all selected customers.';

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        SuccessCount: Integer;
                        FailCount: Integer;
                        ResultMsg: Label 'Geocoding complete. Success: %1, Failed: %2', Comment = '%1 = Success count, %2 = Fail count';
                    begin
                        CurrPage.SetSelectionFilter(Customer);
                        if Customer.FindSet() then
                            repeat
                                if Customer.GeocodeAddress() then
                                    SuccessCount += 1
                                else
                                    FailCount += 1;
                            until Customer.Next() = 0;

                        Message(ResultMsg, SuccessCount, FailCount);
                    end;
                }
            }
        }
    }
}
