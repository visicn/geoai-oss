/// <summary>
/// Codeunit GeoAI Prompt Launcher (ID 70103).
/// Centralizes launching of the prompt dialog.
/// </summary>
codeunit 70103 "GeoAI Prompt Launcher"
{
    procedure LaunchPromptDialog(RecordId: RecordId; EntityType: Enum "GeoAI Entity Type";
        ScopeContext: Enum "GeoAI Template Scope")
    var
        PromptDialog: Page "GeoAI Prompt";
    begin
        PromptDialog.InitializeWithScope(RecordId, EntityType, ScopeContext);
        PromptDialog.RunModal();
    end;
}
