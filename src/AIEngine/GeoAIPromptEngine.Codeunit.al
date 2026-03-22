/// <summary>
/// Codeunit GeoAI Prompt Engine (ID 70048).
/// Builds AI prompts from templates with context injection and parameter substitution.
/// </summary>
codeunit 70048 "GeoAI Prompt Engine"
{
    /// <summary>
    /// Builds a complete prompt from a template with context injection.
    /// </summary>
    /// <param name="TemplateCode">The template code to use.</param>
    /// <param name="ContextJson">The context data in JSON format.</param>
    /// <param name="SystemText">Output: The system text for the AI.</param>
    /// <param name="UserText">Output: The user text/prompt for the AI.</param>
    /// <param name="ToolsJson">Output: The tools definition JSON.</param>
    /// <param name="OutputSchema">Output: The expected output schema JSON.</param>
    /// <returns>True if successful, false otherwise.</returns>
    procedure BuildPrompt(TemplateCode: Code[50]; ContextJson: Text; var SystemText: Text; var UserText: Text; var ToolsJson: Text; var OutputSchema: Text): Boolean
    var
        PromptTemplate: Record "GeoAI Prompt Template";
        TemplateNotFoundErr: Label 'Prompt template %1 not found.', Comment = '%1 = Template code';
        TemplateNotEnabledErr: Label 'Prompt template %1 is not enabled.', Comment = '%1 = Template code';
    begin
        if not PromptTemplate.Get(TemplateCode) then
            Error(TemplateNotFoundErr, TemplateCode);

        if not PromptTemplate.Enabled then
            Error(TemplateNotEnabledErr, TemplateCode);

        SystemText := PromptTemplate.GetSystemText();
        UserText := PromptTemplate.GetTemplateText();
        ToolsJson := PromptTemplate.GetToolsJson();
        OutputSchema := PromptTemplate.GetOutputSchema();

        UserText := InjectContext(UserText, ContextJson);

        exit(true);
    end;

    local procedure InjectContext(TemplateText: Text; ContextJson: Text): Text
    var
        Result: Text;
    begin
        Result := TemplateText;

        Result := Result.Replace('{CustomerContextJson}', ContextJson);
        Result := Result.Replace('{VendorContextJson}', ContextJson);
        Result := Result.Replace('{ContextJson}', ContextJson);

        exit(Result);
    end;
}
