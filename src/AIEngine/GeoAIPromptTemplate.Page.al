/// <summary>
/// Page GeoAI Prompt Template (ID 70022).
/// Card page for editing individual prompt templates.
/// </summary>
page 70022 "GeoAI Prompt Template"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "GeoAI Prompt Template";
    Caption = 'GeoAI Prompt Template';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for the prompt template.';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the prompt template.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the prompt template.';
                    MultiLine = true;
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entity type this template applies to. OSS supports Customer and Vendor only.';
                    ValuesAllowed = " ", Customer, Vendor;
                }
                field("Scenario Code"; Rec."Scenario Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scenario code for this template.';
                }
            }

            group(Taxonomy)
            {
                Caption = 'Taxonomy';

                field("Anchor Entity"; Rec."Anchor Entity")
                {
                    ApplicationArea = All;
                    Caption = 'Anchor';
                    ToolTip = 'Specifies which entity provides the context anchor for the template. OSS supports Any, Customer, and Vendor only.';
                    ValuesAllowed = Any, Customer, Vendor;
                }
                field("Target Entity"; Rec."Target Entity")
                {
                    ApplicationArea = All;
                    Caption = 'Target';
                    ToolTip = 'Specifies the primary entity this template targets when generating results. OSS supports Any, Same as Anchor, Customer, and Vendor only.';
                    ValuesAllowed = Any, SameAsAnchor, Customer, Vendor;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the taxonomy category that best describes the template''s outcome.';
                }
                field(Intent; Rec.Intent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the intended action or analysis performed by the template.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the template operates on the record itself, its relations, or the wider network. OSS supports Self, Selection, and Region only.';
                    ValuesAllowed = Self, Selection, Region;
                }
            }

            group(Configuration)
            {
                Caption = 'Configuration';

                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the prompt template.';
                }
                field("Max Results"; Rec."Max Results")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of results to return.';
                }
                field("Default Radius (km)"; Rec."Default Radius (km)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default search radius in kilometers.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this template is enabled.';
                }
                field("Last Modified DateTime"; Rec."Last Modified DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the template was last modified.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewSystemText)
            {
                ApplicationArea = All;
                Caption = 'View System Text';
                ToolTip = 'Opens a read-only viewer for the system text.';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TextEditor: Page "GeoAI Text Editor";
                    SystemText: Text;
                begin
                    SystemText := Rec.GetSystemText();
                    TextEditor.SetText(SystemText);
                    TextEditor.SetReadOnly(true);
                    TextEditor.RunModal();
                end;
            }

            action(EditTemplateText)
            {
                ApplicationArea = All;
                Caption = 'Edit Template Text';
                ToolTip = 'Opens an editor for the template text.';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TextEditor: Page "GeoAI Text Editor";
                    TemplateText: Text;
                begin
                    TemplateText := Rec.GetTemplateText();
                    TextEditor.SetText(TemplateText);
                    TextEditor.SetReadOnly(false);

                    if TextEditor.RunModal() = Action::OK then begin
                        Rec.SetTemplateText(TextEditor.GetText());
                        Rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }
}
