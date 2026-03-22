/// <summary>
/// Codeunit GeoAI Upgrade (ID 70107).
/// Handles upgrade logic for the GeoAI OSS extension.
/// Ensures Copilot Capability is registered after upgrades.
/// </summary>
codeunit 70107 "GeoAI Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    var
        LearnMoreUrlLbl: Label 'https://github.com/AzureGeoAI/geoai-oss', Locked = true;

    trigger OnUpgradePerDatabase()
    begin
        RegisterCopilotCapability();
    end;

    trigger OnUpgradePerCompany()
    begin
        NormalizeTemplateEnumsForOSS();
    end;

    local procedure RegisterCopilotCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::GeoAI) then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::GeoAI,
                Enum::"Copilot Availability"::"Generally Available",
                Enum::"Copilot Billing Type"::"Not Billed",
                LearnMoreUrlLbl);
    end;

    /// <summary>
    /// Normalizes prompt template enum values to OSS-supported values.
    /// Maps unsupported values to safe defaults without changing valid values.
    /// </summary>
    local procedure NormalizeTemplateEnumsForOSS()
    var
        PromptTemplate: Record "GeoAI Prompt Template";
        NeedsUpdate: Boolean;
    begin
        if PromptTemplate.FindSet(true) then
            repeat
                NeedsUpdate := false;

                if not (PromptTemplate."Entity Type" in [PromptTemplate."Entity Type"::" ", PromptTemplate."Entity Type"::Customer, PromptTemplate."Entity Type"::Vendor]) then begin
                    PromptTemplate."Entity Type" := PromptTemplate."Entity Type"::Customer;
                    NeedsUpdate := true;
                end;

                if not (PromptTemplate."Anchor Entity" in [PromptTemplate."Anchor Entity"::Any, PromptTemplate."Anchor Entity"::Customer, PromptTemplate."Anchor Entity"::Vendor]) then begin
                    PromptTemplate."Anchor Entity" := PromptTemplate."Anchor Entity"::Customer;
                    NeedsUpdate := true;
                end;

                if not (PromptTemplate."Target Entity" in [PromptTemplate."Target Entity"::Any, PromptTemplate."Target Entity"::SameAsAnchor, PromptTemplate."Target Entity"::Customer, PromptTemplate."Target Entity"::Vendor]) then begin
                    PromptTemplate."Target Entity" := PromptTemplate."Target Entity"::SameAsAnchor;
                    NeedsUpdate := true;
                end;

                if not (PromptTemplate.Scope in [PromptTemplate.Scope::Self, PromptTemplate.Scope::Selection, PromptTemplate.Scope::Region]) then begin
                    PromptTemplate.Scope := PromptTemplate.Scope::Self;
                    NeedsUpdate := true;
                end;

                if NeedsUpdate then
                    PromptTemplate.Modify(false);
            until PromptTemplate.Next() = 0;
    end;
}
