/// <summary>
/// Codeunit GeoAI Service (AOAI) (ID 70022).
/// Azure OpenAI service implementation using BC 24+ System.AI namespace.
/// </summary>
codeunit 70022 "GeoAI Service (AOAI)" implements "IGeoAI Service"
{
    Access = Internal;
    SingleInstance = true;

    var
        FailureStatusLbl: Label 'Status %1. %2', Comment = '%1 = Status code, %2 = Error text';
        FailureDetailLbl: Label 'AOAI request failed after %1 attempts. Status: %2. %3', Comment = '%1 = attempts, %2 = status, %3 = error text';
        FailureUserMessageLbl: Label 'Azure OpenAI request failed (status %1). %2', Comment = '%1 = status code, %2 = error text surfaced to the user';
        StatusZeroHintLbl: Label 'Status 0 indicates Business Central blocked the request before reaching Azure OpenAI. Validate Copilot capability enrollment, GeoAI setup, and AOAI credentials.', Comment = 'Shown when AOAI status code is 0 and no detailed error is provided.';
        GenericNoDetailLbl: Label 'Business Central did not return additional error details.', Locked = true;
        CapabilityNotInitializedErr: Label 'GeoAI capability is not enabled or Azure OpenAI authorization is missing. Validate GeoAI setup and Copilot capability activation.', Comment = 'Shown when IsInitialized returns false.';

    /// <summary>
    /// Executes a prompt against Azure OpenAI using System.AI.
    /// Implements retry logic with exponential backoff.
    /// </summary>
    procedure ExecutePrompt(SystemText: Text; UserText: Text; MaxTokens: Integer; Temperature: Decimal; var ResultJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        Deployment: Text;
        Endpoint: Text;
        ApiKey: SecretText;
        RetryCount: Integer;
        MaxRetries: Integer;
        StartTime: DateTime;
        DurationMs: Integer;
        LastStatusCode: Integer;
        LastErrorText: Text;
        LastPromptTokens: Integer;
        LastCompletionTokens: Integer;
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        MaxRetries := GeoAISetup."Max Retry Attempts";
        if MaxRetries < 1 then
            MaxRetries := 3; // Default fallback

        StartTime := CurrentDateTime();

        if not GetDeploymentInfo(Endpoint, Deployment, ApiKey) then begin
            TrackFailure('ExecutePrompt', 'Deployment resolution failed', 0, Deployment, 0);
            exit(false);
        end;

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"GeoAI");

        if not AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Chat Completions") then
            AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", Endpoint, Deployment, ApiKey);

        if not AzureOpenAI.IsInitialized(Enum::"Copilot Capability"::"GeoAI", Enum::"AOAI Model Type"::"Chat Completions") then begin
            TrackFailure('ExecutePrompt', CapabilityNotInitializedErr, 0, Deployment, 0);
            exit(false);
        end;

        AOAIChatMessages.SetPrimarySystemMessage(SystemText);
        AOAIChatMessages.AddUserMessage(UserText);

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens);
        AOAIChatCompletionParams.SetTemperature(Temperature);

        RetryCount := 0;
        repeat
            if not TryGenerateChatCompletion(AzureOpenAI, AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse) then begin
                CaptureFailureMetadata(AOAIOperationResponse, LastStatusCode, LastErrorText);
                FinalizeFailureMetadata(LastStatusCode, LastErrorText, true);
            end else begin
                if AOAIOperationResponse.IsSuccess() then begin
                    ResultJson := AOAIChatMessages.GetLastMessage();
                    DurationMs := CurrentDateTime() - StartTime;

                    ExtractTokenMetrics(AOAIChatMessages, LastPromptTokens, LastCompletionTokens);

                    TrackSuccess('ExecutePrompt', DurationMs, Deployment, LastPromptTokens + LastCompletionTokens, RetryCount);
                    exit(true);
                end;

                CaptureFailureMetadata(AOAIOperationResponse, LastStatusCode, LastErrorText);
                FinalizeFailureMetadata(LastStatusCode, LastErrorText, false);
            end;

            RetryCount += 1;
            if RetryCount < MaxRetries then
                Sleep(Power(2, RetryCount) * 1000);

        until RetryCount >= MaxRetries;

        DurationMs := CurrentDateTime() - StartTime;
        TrackFailure('ExecutePrompt',
        StrSubstNo(FailureStatusLbl, LastStatusCode, CopyStr(LastErrorText, 1, 250)),
        DurationMs, Deployment, LastStatusCode);

        StampLastError(LastStatusCode, LastErrorText, MaxRetries);
        exit(false);
    end;

    [TryFunction]
    local procedure TryGenerateChatCompletion(var AzureOpenAI: Codeunit "Azure OpenAI"; var AOAIChatMessages: Codeunit "AOAI Chat Messages"; AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    begin
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
    end;

    local procedure ExtractTokenMetrics(AOAIChatMessages: Codeunit "AOAI Chat Messages"; var PromptTokens: Integer; var CompletionTokens: Integer)
    var
        HistoryList: List of [Text];
        MessageText: Text;
        ResponseText: Text;
    begin
        // BC's AOAI wrapper doesn't expose usage metrics directly
        // Estimate tokens based on content length

        HistoryList := AOAIChatMessages.GetHistory();
        PromptTokens := 0;
        CompletionTokens := 0;

        foreach MessageText in HistoryList do
            if MessageText <> '' then
                PromptTokens += EstimateMessageTokens(MessageText);

        ResponseText := AOAIChatMessages.GetLastMessage();
        if ResponseText <> '' then
            CompletionTokens := EstimateMessageTokens(ResponseText);
    end;

    local procedure EstimateMessageTokens(MessageText: Text): Integer
    begin
        exit(StrLen(MessageText) div 4);
    end;


    local procedure StampLastError(StatusCode: Integer; ErrorText: Text; Attempts: Integer)
    var
        Err: ErrorInfo;
    begin
        Err.Message := StrSubstNo(FailureUserMessageLbl, StatusCode, CopyStr(ErrorText, 1, 250));
        Err.DetailedMessage := StrSubstNo(FailureDetailLbl, Attempts, StatusCode, CopyStr(ErrorText, 1, 2048));
        Error(Err);
    end;

    /// <summary>
    /// Estimates token count for a given text using AOAI Token codeunit.
    /// </summary>
    procedure EstimateTokens(TextToEstimate: Text; ModelDeployment: Text): Integer
    var
        AOAIToken: Codeunit "AOAI Token";
    begin
        exit(AOAIToken.GetGPT4TokenCount(TextToEstimate));
    end;

    /// <summary>
    /// Gets available deployments or finds deployment for a specific model.
    /// Returns deployment name from setup.
    /// </summary>
    procedure GetDeployments(): List of [Text]
    var
        GeoAISetup: Record "GeoAI Setup";
        Deployments: List of [Text];
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if GeoAISetup."Microsoft Foundry Model" <> '' then
            Deployments.Add(GeoAISetup."Microsoft Foundry Model");

        exit(Deployments);
    end;

    local procedure GetDeploymentInfo(var Endpoint: Text; var Deployment: Text; var ApiKey: SecretText): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if GeoAISetup."Microsoft Foundry Endpoint" = '' then
            exit(false);
        if GeoAISetup."Microsoft Foundry Model" = '' then
            exit(false);
        if GeoAISetup."Microsoft Foundry Key" = '' then
            exit(false);

        Endpoint := GeoAISetup."Microsoft Foundry Endpoint";
        Deployment := GeoAISetup."Microsoft Foundry Model";
        ApiKey := GeoAISetup."Microsoft Foundry Key";

        exit(true);
    end;

    local procedure TrackSuccess(Operation: Text; DurationMs: Integer; ModelName: Text; TokensUsed: Integer; RetryCount: Integer)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('Feature', 'GeoAI-AOAI');
        Dimensions.Add('Operation', Operation);
        Dimensions.Add('Model', ModelName);
        Dimensions.Add('DurationMs', Format(DurationMs));
        Dimensions.Add('TokensUsed', Format(TokensUsed));
        Dimensions.Add('RetryCount', Format(RetryCount));
        Dimensions.Add('Outcome', 'Success');

        Session.LogMessage('GEOAI020', 'AOAI service operation succeeded', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    local procedure TrackFailure(Operation: Text; ErrorText: Text; DurationMs: Integer; ModelName: Text; StatusCode: Integer)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('Feature', 'GeoAI-AOAI');
        Dimensions.Add('Operation', Operation);
        Dimensions.Add('Model', ModelName);
        Dimensions.Add('DurationMs', Format(DurationMs));
        Dimensions.Add('ErrorText', ErrorText);
        Dimensions.Add('StatusCode', Format(StatusCode));
        Dimensions.Add('Outcome', 'Failure');

        Session.LogMessage('GEOAI021', 'AOAI service operation failed', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    local procedure CaptureFailureMetadata(var AOAIOperationResponse: Codeunit "AOAI Operation Response"; var StatusCode: Integer; var ErrorText: Text)
    begin
        StatusCode := AOAIOperationResponse.GetStatusCode();
        ErrorText := AOAIOperationResponse.GetError();
    end;

    local procedure FinalizeFailureMetadata(var StatusCode: Integer; var ErrorText: Text; RequestRaisedException: Boolean)
    begin
        if ErrorText = '' then
            ErrorText := GetLastErrorText();

        if ErrorText = '' then
            ErrorText := GenericNoDetailLbl;

        if RequestRaisedException and (StatusCode = 0) then
            StatusCode := -1;

        if StatusCode = 0 then
            ErrorText := StrSubstNo('%1 %2', StatusZeroHintLbl, ErrorText);
    end;
}
