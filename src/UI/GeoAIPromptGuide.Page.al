/// <summary>
/// Page GeoAI Prompt Guide (ID 70041).
/// List part for displaying and selecting prompt templates in PromptDialog.
/// Filters templates by entity type and provides quick selection.
/// </summary>
page 70041 "GeoAI Prompt Guide"
{
    PageType = ListPart;
    SourceTable = "GeoAI Prompt Template";
    Editable = false;
    Caption = 'Prompt Templates';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Templates)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Template title';
                    StyleExpr = TitleStyle;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Template description';
                }
                field("Scenario Code"; Rec."Scenario Code")
                {
                    ApplicationArea = All;
                    Caption = 'Scenario';
                    ToolTip = 'Scenario category (Proximity, Routing, Analytics).';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UseTemplate)
            {
                ApplicationArea = All;
                Caption = 'Use This Template';
                Image = Approve;
                ToolTip = 'Apply this template to the prompt';

                trigger OnAction()
                begin
                    SelectedTemplateCode := Rec.Code;
                end;
            }
        }
    }

    var
        TitleStyle: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.Enabled then
            TitleStyle := 'Strong'
        else
            TitleStyle := 'Subordinate';
    end;

    var
        SelectedTemplateCode: Code[50];

    /// <summary>
    /// Filters templates by entity type.
    /// </summary>
    /// <param name="EntityType">Entity type to filter by.</param>
    procedure FilterByEntityType(EntityType: Enum "GeoAI Entity Type")
    begin
        Rec.SetRange("Entity Type", EntityType);
        Rec.SetRange(Enabled, true);
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Gets the selected template code.
    /// </summary>
    /// <returns>Selected template code.</returns>
    procedure GetSelectedTemplate(): Code[50]
    begin
        exit(SelectedTemplateCode);
    end;
}
