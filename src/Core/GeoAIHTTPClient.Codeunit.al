/// <summary>
/// Codeunit GeoAI HTTP Client (ID 70047).
/// Handles HTTP communication with external map and AI providers.
/// </summary>
codeunit 70047 "GeoAI HTTP Client"
{
    /// <summary>
    /// Executes a map service request (geocoding, reverse geocoding, distance matrix).
    /// </summary>
    /// <param name="RequestJson">The request payload in JSON format.</param>
    /// <param name="ResponseJson">Output: The response payload in JSON format.</param>
    /// <returns>True if request was successful, false otherwise.</returns>
    procedure ExecuteMapRequest(RequestJson: Text; var ResponseJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        ReqObj: JsonObject;
        ProviderToken: JsonToken;
        OperationToken: JsonToken;
        Provider: Text;
        Operation: Text;
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        if not ReqObj.ReadFrom(RequestJson) then
            exit(false);

        if not ReqObj.Get('provider', ProviderToken) then
            exit(false);
        Provider := ProviderToken.AsValue().AsText();

        if not ReqObj.Get('operation', OperationToken) then
            exit(false);
        Operation := OperationToken.AsValue().AsText();

        case GeoAISetup."Map Provider" of
            GeoAISetup."Map Provider"::Google:
                exit(ExecuteGoogleMapsRequest(ReqObj, Operation, ResponseJson));
            GeoAISetup."Map Provider"::Azure:
                exit(ExecuteAzureMapsRequest(ReqObj, Operation, ResponseJson));
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Executes an AI request for GeoAI operations.
    /// </summary>
    /// <param name="RequestJson">The AI request payload in JSON format.</param>
    /// <param name="ResponseJson">Output: The AI response payload in JSON format.</param>
    /// <returns>True if request was successful, false otherwise.</returns>
    procedure ExecuteAIRequest(RequestJson: Text; var ResponseJson: Text): Boolean
    var
        StartTime: DateTime;
        DurationMs: Integer;
        Success: Boolean;
    begin
        StartTime := CurrentDateTime();
        Success := ExecuteAIRequestInternal(RequestJson, ResponseJson);

        DurationMs := CurrentDateTime() - StartTime;

        if Success then
            TrackHTTPSuccess('ExecuteAIRequest', 'Direct', DurationMs)
        else
            TrackHTTPFailure('ExecuteAIRequest', 'Direct', GetLastErrorText(), DurationMs);

        exit(Success);
    end;

    local procedure ExecuteAIRequestInternal(RequestJson: Text; var ResponseJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        Endpoint: Text;
        Deployment: Text;
        ApiVersion: Text;
        AzureChatFmtLbl: Label '%1/openai/deployments/%2/chat/completions?api-version=%3', Locked = true;
    begin
        GeoAISetup := GeoAISetup.GetInstance();

        case GeoAISetup."AI Provider" of
            GeoAISetup."AI Provider"::MicrosoftFoundry:
                begin
                    // Compose Azure deployment-style chat completions endpoint
                    Deployment := GeoAISetup."Microsoft Foundry Model";
                    ApiVersion := GeoAISetup."Microsoft Foundry API Version";
                    if (GeoAISetup."Microsoft Foundry Endpoint" = '') or (Deployment = '') or (ApiVersion = '') then
                        exit(false);
                    Endpoint := StrSubstNo(AzureChatFmtLbl,
                                            GeoAISetup."Microsoft Foundry Endpoint", Deployment, ApiVersion);
                end;
            GeoAISetup."AI Provider"::LocalGateway:
                Endpoint := GeoAISetup."Local AI Gateway URL";
            else
                exit(false);
        end;

        Content.WriteFrom(RequestJson);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json; charset=utf-8');

        if GeoAISetup."AI Provider" = GeoAISetup."AI Provider"::MicrosoftFoundry then
            Client.DefaultRequestHeaders().Add('api-key', GeoAISetup."Microsoft Foundry Key");

        if not Client.Post(Endpoint, Content, Response) then
            exit(false);

        if not Response.IsSuccessStatusCode() then
            exit(false);

        Response.Content().ReadAs(ResponseJson);
        exit(true);
    end;

    local procedure ExecuteGoogleMapsRequest(ReqObj: JsonObject; Operation: Text; var ResponseJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        Response: HttpResponseMessage;
        Endpoint: Text;
        ApiKey: Text;
        AddressToken: JsonToken;
        LatToken: JsonToken;
        LonToken: JsonToken;
        Address: Text;
        EncodedAddress: Text;
        FullUrl: Text;
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        Endpoint := GetGoogleMapsEndpoint();
        ApiKey := GeoAISetup."Google Maps API Key";

        if ApiKey = '' then
            exit(false);

        case Operation of
            'geocode':
                begin
                    if not ReqObj.Get('address', AddressToken) then
                        exit(false);
                    Address := AddressToken.AsValue().AsText();
                    EncodedAddress := UrlEncode(Address);
                    FullUrl := Endpoint + '?address=' + EncodedAddress + '&key=' + ApiKey;
                end;
            'reverse':
                begin
                    if not ReqObj.Get('latitude', LatToken) then
                        exit(false);
                    if not ReqObj.Get('longitude', LonToken) then
                        exit(false);
                    FullUrl := Endpoint + '?latlng=' + Format(LatToken.AsValue().AsDecimal(), 0, 9) + ',' +
                               Format(LonToken.AsValue().AsDecimal(), 0, 9) + '&key=' + ApiKey;
                end;
            else
                exit(false);
        end;

        RequestMsg.SetRequestUri(FullUrl);
        RequestMsg.Method := 'GET';

        if not Client.Send(RequestMsg, Response) then
            exit(false);

        if not Response.IsSuccessStatusCode() then
            exit(false);

        Response.Content().ReadAs(ResponseJson);
        exit(true);
    end;

    local procedure ExecuteAzureMapsRequest(ReqObj: JsonObject; Operation: Text; var ResponseJson: Text): Boolean
    var
        GeoAISetup: Record "GeoAI Setup";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        Response: HttpResponseMessage;
        Endpoint: Text;
        ApiKey: Text;
        AddressToken: JsonToken;
        LatToken: JsonToken;
        LonToken: JsonToken;
        Address: Text;
        EncodedAddress: Text;
        FullUrl: Text;
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        Endpoint := GetAzureMapsEndpoint();
        ApiKey := GeoAISetup."Azure Maps Key";

        if ApiKey = '' then
            exit(false);

        // Azure Maps uses GET with query parameters and subscription-key
        case Operation of
            'geocode':
                begin
                    if not ReqObj.Get('address', AddressToken) then
                        exit(false);
                    Address := AddressToken.AsValue().AsText();
                    EncodedAddress := UrlEncode(Address);
                    FullUrl := Endpoint + '?api-version=1.0&query=' + EncodedAddress + '&subscription-key=' + ApiKey;
                end;
            'reverse':
                begin
                    if not ReqObj.Get('latitude', LatToken) then
                        exit(false);
                    if not ReqObj.Get('longitude', LonToken) then
                        exit(false);
                    FullUrl := 'https://atlas.microsoft.com/search/address/reverse/json?api-version=1.0&query=' +
                               Format(LatToken.AsValue().AsDecimal(), 0, 9) + ',' +
                               Format(LonToken.AsValue().AsDecimal(), 0, 9) + '&subscription-key=' + ApiKey;
                end;
            else
                exit(false);
        end;

        RequestMsg.SetRequestUri(FullUrl);
        RequestMsg.Method := 'GET';

        if not Client.Send(RequestMsg, Response) then
            exit(false);

        if not Response.IsSuccessStatusCode() then
            exit(false);

        Response.Content().ReadAs(ResponseJson);
        exit(true);
    end;

    local procedure UrlEncode(InputText: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UriEscapeDataString(InputText));
    end;

    local procedure GetGoogleMapsEndpoint(): Text
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        if GeoAISetup."Maps Endpoint URL" <> '' then
            exit(GeoAISetup."Maps Endpoint URL");
        exit('https://maps.googleapis.com/maps/api/geocode/json');
    end;

    local procedure GetAzureMapsEndpoint(): Text
    var
        GeoAISetup: Record "GeoAI Setup";
    begin
        GeoAISetup := GeoAISetup.GetInstance();
        if GeoAISetup."Maps Endpoint URL" <> '' then
            exit(GeoAISetup."Maps Endpoint URL");
        exit('https://atlas.microsoft.com/search/address/json');
    end;

    local procedure TrackHTTPSuccess(OperationName: Text; Mode: Text; DurationMs: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
        SuccessMsg: Label 'HTTP request succeeded', Locked = true;
    begin
        CustomDimensions.Add('Operation', OperationName);
        CustomDimensions.Add('Mode', Mode);
        CustomDimensions.Add('DurationMs', Format(DurationMs));
        Session.LogMessage('GEOAI001', SuccessMsg, Verbosity::Normal,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure TrackHTTPFailure(OperationName: Text; Mode: Text; ErrorMessage: Text; DurationMs: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
        FailureMsg: Label 'HTTP request failed', Locked = true;
    begin
        CustomDimensions.Add('Operation', OperationName);
        CustomDimensions.Add('Mode', Mode);
        CustomDimensions.Add('ErrorMessage', ErrorMessage);
        CustomDimensions.Add('DurationMs', Format(DurationMs));
        Session.LogMessage('GEOAI002', FailureMsg, Verbosity::Warning,
                          DataClassification::SystemMetadata,
                          TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}
