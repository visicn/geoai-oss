/// <summary>
/// PageExtension Customer Card GeoAI (ID 70050) extends Page Customer Card.
/// Adds GeoAI fields and actions to Customer Card page.
/// </summary>
pageextension 70050 "Customer Card GeoAI" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group("GeoAI")
            {
                Caption = 'GeoAI';

                field("GeoAI Latitude"; Rec."GeoAI Latitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the latitude coordinate of the customer address.';
                }
                field("GeoAI Longitude"; Rec."GeoAI Longitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the longitude coordinate of the customer address.';
                }
                field("GeoAI Geocode Status Field"; Rec."GeoAI Geocode Status Field")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the geocoding operation.';
                }
                field("GeoAI Geocode Confidence"; Rec."GeoAI Geocode Confidence")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the confidence score of the geocoding result.';
                }
                field("GeoAI Last Geocode DateTime"; Rec."GeoAI Last Geocode DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the address was last geocoded.';
                }
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            group(GeoAIActions)
            {
                Caption = 'GeoAI';
                Image = Sparkle;

                action(GeocodeAddress)
                {
                    ApplicationArea = All;
                    Caption = 'Geocode Address';
                    ToolTip = 'Geocodes the customer address to get coordinates.';
                    Image = MapSetup;

                    trigger OnAction()
                    var
                        SuccessMsg: Label 'Address geocoded successfully. Confidence: %1', Comment = '%1 = Confidence score';
                        FailedMsg: Label 'Geocoding failed. Please check the address.';
                    begin
                        if Rec.GeocodeAddress() then
                            Message(SuccessMsg, Rec."GeoAI Geocode Confidence")
                        else
                            Message(FailedMsg);
                    end;
                }

                action(ViewOnMap)
                {
                    ApplicationArea = All;
                    Caption = 'View on Map';
                    ToolTip = 'Opens the customer location in an external mapping service.';
                    Image = Map;

                    trigger OnAction()
                    var
                        MapUrlFormatter: Codeunit "GeoAI Map URL Formatter";
                    begin
                        MapUrlFormatter.OpenMapForCoordinates(Rec."GeoAI Latitude", Rec."GeoAI Longitude");
                    end;
                }

                action(AskGeoAI)
                {
                    ApplicationArea = All;
                    Caption = 'Ask GeoAI...';
                    ToolTip = 'Opens GeoAI prompt copilot for this customer.';
                    Image = Sparkle;

                    trigger OnAction()
                    var
                        PromptLauncher: Codeunit "GeoAI Prompt Launcher";
                    begin
                        PromptLauncher.LaunchPromptDialog(
                          Rec.RecordId,
                          "GeoAI Entity Type"::Customer,
                          "GeoAI Template Scope"::Self);
                    end;
                }
            }
        }
    }
}
