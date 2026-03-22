/// <summary>
/// Codeunit GeoAI Template Selector (ID 70102).
/// Provides centralized taxonomy filtering for prompt template selection.
/// </summary>
codeunit 70102 "GeoAI Template Selector"
{
    procedure SelectByAction(AnchorEntity: Enum "GeoAI Anchor Entity"; TargetEntity: Enum "GeoAI Target Entity";
        Category: Enum "GeoAI Template Category"; Intent: Enum "GeoAI Template Intent"; ScopePreference: Enum "GeoAI Template Scope";
        var FilteredTemplates: Record "GeoAI Prompt Template"): Integer
    var
        AnchorFilter: Text;
        TargetFilter: Text;
        ScopeFilter: Text;
    begin
        FilteredTemplates.Reset();
        FilteredTemplates.SetRange(Enabled, true);
        FilteredTemplates.SetRange(Category, Category);
        FilteredTemplates.SetRange(Intent, Intent);

        AnchorFilter := BuildAnchorFilter(AnchorEntity);
        if AnchorFilter <> '' then
            FilteredTemplates.SetFilter("Anchor Entity", AnchorFilter);

        TargetFilter := BuildTargetFilter(TargetEntity);
        if TargetFilter <> '' then
            FilteredTemplates.SetFilter("Target Entity", TargetFilter);

        ScopeFilter := BuildScopeFilter(ScopePreference);
        if ScopeFilter <> '' then
            FilteredTemplates.SetFilter(Scope, ScopeFilter);

        exit(FilteredTemplates.Count());
    end;

    local procedure BuildAnchorFilter(AnchorEntity: Enum "GeoAI Anchor Entity"): Text
    var
        Filter: Text;
    begin
        AppendFilterValue(Filter, Format("GeoAI Anchor Entity"::Any));
        if AnchorEntity <> "GeoAI Anchor Entity"::Any then
            AppendFilterValue(Filter, Format(AnchorEntity));
        exit(Filter);
    end;

    local procedure BuildTargetFilter(TargetEntity: Enum "GeoAI Target Entity"): Text
    var
        Filter: Text;
    begin
        AppendFilterValue(Filter, Format("GeoAI Target Entity"::Any));
        AppendFilterValue(Filter, Format("GeoAI Target Entity"::SameAsAnchor));

        if TargetEntity <> "GeoAI Target Entity"::SameAsAnchor then
            AppendFilterValue(Filter, Format(TargetEntity));

        exit(Filter);
    end;

    local procedure BuildScopeFilter(ScopePreference: Enum "GeoAI Template Scope"): Text
    var
        Filter: Text;
    begin
        // Always include the preferred scope
        AppendFilterValue(Filter, Format(ScopePreference));
        AppendFilterValue(Filter, Format("GeoAI Template Scope"::Region));

        if ScopePreference = "GeoAI Template Scope"::Self then
            AppendFilterValue(Filter, Format("GeoAI Template Scope"::Selection));

        exit(Filter);
    end;

    local procedure AppendFilterValue(var Filter: Text; Value: Text)
    begin
        if Value = '' then
            exit;

        if Filter = '' then
            Filter := Value
        else
            Filter := StrSubstNo('%1|%2', Filter, Value);
    end;
}
