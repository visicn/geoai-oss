/// <summary>
/// Page GeoAI Prompt Templates (ID 70021).
/// List page for managing GeoAI prompt templates.
/// </summary>
page 70021 "GeoAI Prompt Templates"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GeoAI Prompt Template";
    Caption = 'GeoAI Prompt Templates';
    CardPageId = "GeoAI Prompt Template";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entity type this template applies to.';
                }
                field("Scenario Code"; Rec."Scenario Code")
                {
                    ApplicationArea = All;
                    Caption = 'Scenario';
                    ToolTip = 'Specifies the scenario classification for this template.';
                }
                field("Anchor Entity"; Rec."Anchor Entity")
                {
                    ApplicationArea = All;
                    Caption = 'Anchor';
                    ToolTip = 'Specifies which entity provides context anchoring for the template.';
                }
                field("Target Entity"; Rec."Target Entity")
                {
                    ApplicationArea = All;
                    Caption = 'Target';
                    ToolTip = 'Specifies the primary entity this template targets when generating output.';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the taxonomy category that best describes this template.''s outcome.';
                }
                field(Intent; Rec.Intent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the intended action or analysis performed by the template.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scope of data the template expects (self, related, or network).';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the prompt template.';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the version of the prompt template.';
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
        }
    }
}
