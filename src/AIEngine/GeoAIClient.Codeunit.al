/// <summary>
/// Codeunit GeoAI Client (ID 70049).
/// Executes AI prompts and returns results.
/// </summary>
codeunit 70049 "GeoAI Client"
{
    SingleInstance = true;

    /// <summary>
    /// Executes an AI prompt and returns the result.
    /// </summary>
    /// <param name="SystemText">The system text/instructions for the AI.</param>
    /// <param name="UserText">The user text/prompt for the AI.</param>
    /// <param name="ResultJson">Output: The AI result in JSON format.</param>
    /// <returns>True if successful, false otherwise.</returns>
    procedure RunPrompt(SystemText: Text; UserText: Text; var ResultJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        GeoAISetup.ValidateConfiguration();

        if not ExecutePromptInternal(SystemText, UserText, ResultJson) then
            exit(false);

        exit(true);
    end;

    local procedure ExecutePromptInternal(SystemText: Text; UserText: Text; var ResultJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        Service: Interface "IGeoAI Service";
        MaxTokens: Integer;
        Temperature: Decimal;
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        Service := GetAOAIService();

        MaxTokens := GetMaxTokens();
        Temperature := 0.7;

        if not Service.ExecutePrompt(SystemText, UserText, MaxTokens, Temperature, ResultJson) then
            exit(false);

        exit(true);
    end;

    local procedure GetAOAIService(): Interface "IGeoAI Service"
    var
        ServiceAOAI: Codeunit "GeoAI Service (AOAI)";
    begin
        exit(ServiceAOAI);
    end;

    local procedure GetMaxTokens(): Integer
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if GeoAISetup."Max Input Tokens" > 0 then
            exit(GeoAISetup."Max Input Tokens");

        exit(4000);
    end;
}
