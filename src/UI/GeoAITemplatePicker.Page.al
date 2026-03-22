/// <summary>
/// Page GeoAI Template Picker (ID 70049).
/// Lookup page that lets users select a prompt template filtered by entity and scenario.
/// </summary>
page 70049 "GeoAI Template Picker"
{
    PageType = List;
    SourceTable = "GeoAI Prompt Template";
    Caption = 'Select Prompt Template';
    Editable = false;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Quick Filters';
                ShowCaption = false;

                field(TargetFilterValue; TargetFilterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Target Entity';
                    ToolTip = 'Quickly narrow templates by target entity.';
                    trigger OnValidate()
                    begin
                        TargetFilterApplied := true;
                        ApplyFilterState();
                    end;
                }
                field(ScopeFilterValue; ScopeFilterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Scope';
                    ToolTip = 'Quickly narrow templates by scope.';
                    trigger OnValidate()
                    begin
                        ScopeFilterApplied := true;
                        ApplyFilterState();
                    end;
                }
            }

            repeater(Templates)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Template title that will populate the AI prompt.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Short explanation of what the template does.';
                }
                field("Target Entity"; Rec."Target Entity")
                {
                    ApplicationArea = All;
                    Caption = 'Target';
                    ToolTip = 'Primary entity this template targets when generating output.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                    Caption = 'Scope';
                    ToolTip = 'Scope of data the template expects (self, selection, company, region).';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    ToolTip = 'Template version identifier.';
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
                Caption = 'Use Template';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Apply the selected prompt template.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(ClearTargetFilter)
            {
                ApplicationArea = All;
                Caption = 'Clear Target Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Remove the quick filter for target entity.';

                trigger OnAction()
                begin
                    TargetFilterApplied := false;
                    Clear(TargetFilterValue);
                    ApplyFilterState();
                end;
            }
            action(ClearScopeFilter)
            {
                ApplicationArea = All;
                Caption = 'Clear Scope Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Remove the quick filter for scope.';

                trigger OnAction()
                begin
                    ScopeFilterApplied := false;
                    Clear(ScopeFilterValue);
                    ApplyFilterState();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        Clear(TargetFilterValue);
        TargetFilterApplied := false;
        Clear(ScopeFilterValue);
        ScopeFilterApplied := false;
    end;

    trigger OnOpenPage()
    begin
        if BaseView = '' then
            BaseView := Rec.GetView();

        ApplyFilterState();
    end;

    internal procedure PrepareWithTaxonomy(AnchorEntity: Enum "GeoAI Anchor Entity"; TargetEntity: Enum "GeoAI Target Entity";
        Category: Enum "GeoAI Template Category"; Intent: Enum "GeoAI Template Intent"; ScopePreference: Enum "GeoAI Template Scope")
    var
        FilteredTemplates: Record "GeoAI Prompt Template";
        TemplateSelector: Codeunit "GeoAI Template Selector";
    begin
        TemplateSelector.SelectByAction(AnchorEntity, TargetEntity, Category, Intent, ScopePreference, FilteredTemplates);
        CurrPage.SetTableView(FilteredTemplates);
    end;

    internal procedure GetSelectedTemplate(var Template: Record "GeoAI Prompt Template")
    begin
        Template := Rec;
    end;

    local procedure ApplyFilterState()
    begin
        if BaseView <> '' then
            Rec.SetView(BaseView)
        else
            Rec.Reset();

        if TargetFilterApplied then
            Rec.SetRange("Target Entity", TargetFilterValue);
        if ScopeFilterApplied then
            Rec.SetRange(Scope, ScopeFilterValue);

        CurrPage.Update(false);
    end;

    var
        TargetFilterValue: Enum "GeoAI Target Entity";
        ScopeFilterValue: Enum "GeoAI Template Scope";
        TargetFilterApplied: Boolean;
        ScopeFilterApplied: Boolean;
        BaseView: Text;
}
