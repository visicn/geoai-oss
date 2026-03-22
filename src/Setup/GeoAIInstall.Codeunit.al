/// <summary>
/// Codeunit GeoAI Install (ID 70106).
/// Handles installation and upgrade of the GeoAI OSS extension.
/// Registers the GeoAI Copilot Capability with Business Central.
/// </summary>
codeunit 70106 "GeoAI Install"
{
    Subtype = Install;
    Access = Internal;

    var
        LearnMoreUrlLbl: Label 'https://github.com/AzureGeoAI/geoai-oss', Locked = true;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCopilotCapability();
    end;

    trigger OnInstallAppPerCompany()
    begin
        // Company-specific installation logic (if needed)
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
    /// Manually registers the GeoAI Copilot Capability.
    /// Call this procedure if the capability was not registered during installation.
    /// </summary>
    procedure ManuallyRegisterCapability()
    begin
        RegisterCopilotCapability();
    end;

    /// <summary>
    /// Checks if the GeoAI Copilot Capability is registered.
    /// </summary>
    /// <returns>True if registered, false otherwise.</returns>
    procedure IsCapabilityRegistered(): Boolean
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        exit(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::GeoAI));
    end;

    /// <summary>
    /// Unregisters the GeoAI Copilot Capability.
    /// Use this before uninstalling the extension to clean up.
    /// </summary>
    procedure UnregisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::GeoAI) then
            CopilotCapability.UnregisterCapability(Enum::"Copilot Capability"::GeoAI);
    end;
}
