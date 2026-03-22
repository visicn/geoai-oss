page 70029 "GeoAI Result Items"
{
    PageType = ListPart;
    Caption = 'Result Items';
    SourceTable = "GeoAI Result Item";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(ResultItems)
            {
                field(ItemId; Rec."Item Id")
                {
                    ApplicationArea = All;
                    Caption = 'Id';
                    ToolTip = 'Specifies the unique identifier of the result item.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the result item.';
                }
                field(DistanceKm; Rec."Distance (km)")
                {
                    ApplicationArea = All;
                    Caption = 'Distance (km)';
                    ToolTip = 'Specifies the distance in kilometers.';
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the relevance score of the result.';
                }
                field(ETAMinutes; Rec."ETA (minutes)")
                {
                    ApplicationArea = All;
                    Caption = 'ETA (minutes)';
                    ToolTip = 'Specifies the estimated time of arrival in minutes.';
                }
                field(Latitude; Rec.Latitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the latitude coordinate.';
                }
                field(Longitude; Rec.Longitude)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the longitude coordinate.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenMap)
            {
                ApplicationArea = All;
                Caption = 'Open Map';
                Image = Map;
                ToolTip = 'View the AI results on an interactive map.';

                trigger OnAction()
                begin
                    RunOpenMapViewer();
                end;
            }
            action(ExportPrompt)
            {
                ApplicationArea = All;
                Caption = 'Export Prompt';
                Image = Export;
                ToolTip = 'Export the latest AI Prompt response to a file.';

                trigger OnAction()
                begin
                    RunExportPrompt();
                end;
            }
        }
    }

    var
        RawJsonText: Text;

    /// <summary>
    /// Triggers the Open Map action (callable from parent page).
    /// </summary>
    procedure TriggerOpenMap()
    begin
        RunOpenMapViewer();
    end;

    /// <summary>
    /// Triggers the Export Prompt action (callable from parent page).
    /// </summary>
    procedure TriggerExportPrompt()
    begin
        RunExportPrompt();
    end;

    /// <summary>
    /// Sets the raw JSON response for export functionality.
    /// </summary>
    /// <param name="JsonText">The raw JSON response text.</param>
    procedure SetRawJsonForExport(JsonText: Text)
    begin
        RawJsonText := JsonText;
    end;

    local procedure RunOpenMapViewer()
    var
        TempResultItem: Record "GeoAI Result Item" temporary;
        ItemCount: Integer;
        NoDataMsg: Label 'No location data available to display on the map.';
        TooManyItemsMsg: Label 'You have %1 items to display. Opening all items on the map may be slow or limited by the map provider.\\ \Do you want to continue?', Comment = '%1 = Number of items';
        VeryLargeSetMsg: Label 'You have %1 items to display. Most map providers limit the number of waypoints to 25-50.\\ \Options:\- Click OK to open the first 25 items\- Click Cancel and use "Export Result Items" to create a KML file for advanced mapping tools', Comment = '%1 = Number of items';
    begin
        if not GetResultItems(TempResultItem) then begin
            Message(NoDataMsg);
            exit;
        end;

        TempResultItem.Reset();
        ItemCount := TempResultItem.Count();

        if ItemCount = 0 then begin
            Message(NoDataMsg);
            exit;
        end;

        case true of
            ItemCount = 1:
                OpenSingleLocation(TempResultItem);
            ItemCount <= 10:
                OpenMultipleLocations(TempResultItem, ItemCount);
            ItemCount <= 25:
                if Confirm(TooManyItemsMsg, true, ItemCount) then
                    OpenMultipleLocations(TempResultItem, ItemCount);
            else
                if Confirm(VeryLargeSetMsg, true, ItemCount) then
                    OpenMultipleLocations(TempResultItem, 25);
        end;
    end;

    local procedure OpenSingleLocation(var TempResultItem: Record "GeoAI Result Item" temporary)
    var
        Setup: Record "GeoAI Setup";
        Provider: Enum "GeoAI Map Provider";
        MapUrl: Text;
    begin
        if not TempResultItem.FindFirst() then
            exit;

        Setup := Setup.GetInstance();
        Provider := Setup."Map Provider";

        case Provider of
            Provider::Google:
                MapUrl := BuildGoogleMapsSinglePointUrl(TempResultItem.Latitude, TempResultItem.Longitude);
            Provider::Azure:
                MapUrl := BuildAzureMapsSinglePointUrl(TempResultItem.Latitude, TempResultItem.Longitude);
            else
                MapUrl := BuildGoogleMapsSinglePointUrl(TempResultItem.Latitude, TempResultItem.Longitude);
        end;

        if MapUrl <> '' then
            Hyperlink(MapUrl);
    end;

    local procedure OpenMultipleLocations(var TempResultItem: Record "GeoAI Result Item" temporary; MaxItems: Integer)
    var
        Setup: Record "GeoAI Setup";
        Provider: Enum "GeoAI Map Provider";
        MapUrl: Text;
    begin
        Setup := Setup.GetInstance();
        Provider := Setup."Map Provider";

        TempResultItem.SetCurrentKey("Distance (km)");
        TempResultItem.Ascending(true);

        case Provider of
            Provider::Google:
                MapUrl := BuildGoogleMapsMultiPointUrl(TempResultItem, MaxItems);
            Provider::Azure:
                MapUrl := BuildAzureMapsMultiPointUrl(TempResultItem, MaxItems);
            else
                MapUrl := BuildGoogleMapsMultiPointUrl(TempResultItem, MaxItems);
        end;

        if MapUrl <> '' then
            Hyperlink(MapUrl);
    end;

    local procedure BuildGoogleMapsSinglePointUrl(Lat: Decimal; Lon: Decimal): Text
    var
        LatText: Text;
        LonText: Text;
        GoogleMapsPointUrlLbl: Label 'https://www.google.com/maps?q=%1,%2', Locked = true;
    begin
        LatText := Format(Lat, 0, '<Precision,6><Standard Format,9>');
        LonText := Format(Lon, 0, '<Precision,6><Standard Format,9>');
        exit(StrSubstNo(GoogleMapsPointUrlLbl, LatText, LonText));
    end;

    local procedure BuildAzureMapsSinglePointUrl(Lat: Decimal; Lon: Decimal): Text
    var
        LatText: Text;
        LonText: Text;
        AzureMapsPointUrlLbl: Label 'https://atlas.microsoft.com/map/view?center=%2,%1&zoom=15', Locked = true;
    begin
        LatText := Format(Lat, 0, '<Precision,6><Standard Format,9>');
        LonText := Format(Lon, 0, '<Precision,6><Standard Format,9>');
        exit(StrSubstNo(AzureMapsPointUrlLbl, LatText, LonText));
    end;

    local procedure BuildGoogleMapsMultiPointUrl(var TempResultItem: Record "GeoAI Result Item" temporary; MaxItems: Integer): Text
    var
        Setup: Record "GeoAI Setup";
        BaseUrl: Text;
        Waypoints: Text;
        ItemCount: Integer;
        LatText: Text;
        LonText: Text;
        DefaultGoogleMapsUrlLbl: Label 'https://www.google.com/maps/dir/', Locked = true;
    begin
        Setup := Setup.GetInstance();
        if Setup."Maps Directions URL" <> '' then
            BaseUrl := Setup."Maps Directions URL"
        else
            BaseUrl := DefaultGoogleMapsUrlLbl;

        if not BaseUrl.EndsWith('/') then
            BaseUrl += '/';

        Waypoints := '';
        ItemCount := 0;

        if not TempResultItem.FindSet() then
            exit('');

        repeat
            if ItemCount >= MaxItems then
                break;

            LatText := Format(TempResultItem.Latitude, 0, '<Precision,6><Standard Format,9>');
            LonText := Format(TempResultItem.Longitude, 0, '<Precision,6><Standard Format,9>');
            Waypoints += LatText + ',' + LonText + '/';
            ItemCount += 1;
        until TempResultItem.Next() = 0;

        exit(BaseUrl + Waypoints);
    end;

    local procedure BuildAzureMapsMultiPointUrl(var TempResultItem: Record "GeoAI Result Item" temporary; MaxItems: Integer): Text
    var
        Setup: Record "GeoAI Setup";
        BaseUrl: Text;
        WaypointParams: Text;
        WaypointCount: Integer;
        LatText: Text;
        LonText: Text;
        DefaultAzureMapsUrlLbl: Label 'https://atlas.microsoft.com/map/directions?', Locked = true;
        WaypointFmtLbl: Label 'wp.%1=%2,%3', Locked = true, Comment = '%1 = Waypoint index, %2 = Latitude, %3 = Longitude';
    begin
        Setup := Setup.GetInstance();
        BaseUrl := DefaultAzureMapsUrlLbl;

        WaypointParams := '';
        WaypointCount := 0;

        if not TempResultItem.FindSet() then
            exit('');

        repeat
            if WaypointCount >= MaxItems then
                break;

            LatText := Format(TempResultItem.Latitude, 0, '<Precision,6><Standard Format,9>');
            LonText := Format(TempResultItem.Longitude, 0, '<Precision,6><Standard Format,9>');

            if WaypointParams <> '' then
                WaypointParams += '&';

            WaypointParams += StrSubstNo(WaypointFmtLbl, WaypointCount, LatText, LonText);
            WaypointCount += 1;
        until TempResultItem.Next() = 0;

        exit(BaseUrl + WaypointParams);
    end;

    local procedure RunExportPrompt()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
        FileNameFmtLbl: Label 'GeoAI-Result-%1.txt', Locked = true;
        NoDataToExportMsg: Label 'No data available to export.';
    begin
        if RawJsonText = '' then begin
            Message(NoDataToExportMsg);
            exit;
        end;

        FileName := StrSubstNo(FileNameFmtLbl, Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>-<Hours24><Minutes,2><Seconds,2>'));

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(RawJsonText);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

        DownloadFromStream(InStr, 'Export Prompt', '', 'Text Files (*.txt)|*.txt', FileName);
    end;

    procedure LoadFromJson(JsonText: Text; EntityType: Enum "GeoAI Entity Type"; var MapAvailable: Boolean): Boolean
    var
        JsonObj: JsonObject;
        ItemsToken: JsonToken;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ValueToken: JsonToken;
        EntryNo: Integer;
        HasData: Boolean;
        ResolvedLat: Decimal;
        ResolvedLon: Decimal;
        HasResolvedCoords: Boolean;
    begin
        MapAvailable := false;
        HasData := false;
        Rec.DeleteAll();
        EntryNo := 1;

        if JsonText = '' then
            exit(false);

        if not JsonObj.ReadFrom(JsonText) then
            exit(false);

        if not JsonObj.Get('items', ItemsToken) then
            exit(false);

        if not ItemsToken.IsArray() then
            exit(false);

        ItemsArray := ItemsToken.AsArray();
        foreach ItemToken in ItemsArray do begin
            if not ItemToken.IsObject() then
                continue;

            ItemObj := ItemToken.AsObject();
            Rec.Init();
            Rec."Entry No." := EntryNo;
            EntryNo += 1;

            if ItemObj.Get('id', ValueToken) then
                Rec."Item Id" := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Rec."Item Id"));
            if ItemObj.Get('name', ValueToken) then
                if ValueToken.IsValue() then
                    Rec.Name := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Rec.Name));
            if ItemObj.Get('description', ValueToken) then
                if ValueToken.IsValue() then
                    Rec.Description := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if ItemObj.Get('distanceKm', ValueToken) then
                if ValueToken.IsValue() and not ValueToken.AsValue().IsNull() then
                    Rec."Distance (km)" := ValueToken.AsValue().AsDecimal();
            if ItemObj.Get('etaMinutes', ValueToken) then
                if ValueToken.IsValue() and not ValueToken.AsValue().IsNull() then
                    Rec."ETA (minutes)" := ValueToken.AsValue().AsDecimal();
            if ItemObj.Get('score', ValueToken) then
                if ValueToken.IsValue() and not ValueToken.AsValue().IsNull() then
                    Rec.Score := ValueToken.AsValue().AsDecimal();

            // Resolve real coordinates from BC entity instead of trusting model output
            HasResolvedCoords := ResolveCoordinatesFromEntity(Rec."Item Id", EntityType, ResolvedLat, ResolvedLon);
            if HasResolvedCoords then begin
                Rec.Latitude := ResolvedLat;
                Rec.Longitude := ResolvedLon;
                MapAvailable := true;
            end else begin
                // Fall back to model coordinates only if BC lookup fails
                if ItemObj.Get('lat', ValueToken) then
                    if ValueToken.IsValue() and not ValueToken.AsValue().IsNull() then
                        Rec.Latitude := ValueToken.AsValue().AsDecimal();
                if ItemObj.Get('lon', ValueToken) then
                    if ValueToken.IsValue() and not ValueToken.AsValue().IsNull() then
                        Rec.Longitude := ValueToken.AsValue().AsDecimal();
            end;

            Rec.Insert(false);
            HasData := true;
        end;

        exit(HasData);
    end;

    procedure LoadFromResponsePayload(ResponsePayload: Text; EntityType: Enum "GeoAI Entity Type"; var MapAvailable: Boolean): Boolean
    begin
        if LoadFromJson(ResponsePayload, EntityType, MapAvailable) then
            exit(true);

        exit(LoadFromTextResponse(ResponsePayload, MapAvailable));
    end;

    procedure ClearItems()
    begin
        Rec.DeleteAll();
    end;

    procedure GetResultItems(var ResultItem: Record "GeoAI Result Item" temporary): Boolean
    begin
        ResultItem.DeleteAll();
        if Rec.FindSet() then begin
            repeat
                ResultItem := Rec;
                ResultItem.Insert();
            until Rec.Next() = 0;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LoadFromTextResponse(ResponsePayload: Text; var MapAvailable: Boolean): Boolean
    var
        Segments: List of [Text];
        Segment: Text;
        ItemName: Text;
        IdValue: Text;
        DistanceValue: Decimal;
        EntryNo: Integer;
    begin
        Rec.DeleteAll();
        MapAvailable := false;
        EntryNo := 1;

        if not TryExtractSegments(ResponsePayload, Segments) then
            exit(false);

        foreach Segment in Segments do begin
            if not ParseSegmentFields(Segment, ItemName, IdValue, DistanceValue) then
                continue;

            Rec.Init();
            Rec."Entry No." := EntryNo;
            EntryNo += 1;
            if IdValue <> '' then
                Rec."Item Id" := CopyStr(IdValue, 1, MaxStrLen(Rec."Item Id"));
            Rec.Name := CopyStr(ItemName, 1, MaxStrLen(Rec.Name));
            Rec."Distance (km)" := DistanceValue;
            Rec.Insert(false);
        end;

        exit(EntryNo > 1);
    end;

    local procedure TryExtractSegments(ResponsePayload: Text; var Segments: List of [Text]): Boolean
    var
        WorkingText: Text;
        Pattern: Text;
        NextPattern: Text;
        Segment: Text;
        StartPos: Integer;
        NextPos: Integer;
        SeqNo: Integer;
    begin
        WorkingText := ResponsePayload;
        SeqNo := 1;

        StartPos := StrPos(WorkingText, '1. **');
        if StartPos = 0 then
            exit(false);

        WorkingText := CopyStr(WorkingText, StartPos);
        WorkingText := TrimLeadingWhitespace(WorkingText);
        WorkingText := StripLeadingLiteralNewline(WorkingText);

        repeat
            Pattern := Format('%1. **', SeqNo);
            if StrPos(WorkingText, Pattern) <> 1 then
                break;

            NextPattern := Format('%1. **', SeqNo + 1);
            NextPos := StrPos(WorkingText, NextPattern);
            if NextPos > 0 then begin
                Segment := CopyStr(WorkingText, 1, NextPos - 1);
                WorkingText := CopyStr(WorkingText, NextPos);
            end else begin
                Segment := WorkingText;
                WorkingText := '';
            end;

            Segments.Add(Segment);
            WorkingText := TrimLeadingWhitespace(WorkingText);
            WorkingText := StripLeadingLiteralNewline(WorkingText);
            SeqNo += 1;
        until WorkingText = '';

        exit(Segments.Count() > 0);
    end;

    local procedure ParseSegmentFields(Segment: Text; var ItemName: Text; var IdValue: Text; var DistanceValue: Decimal): Boolean
    var
        WorkText: Text;
        DotPos: Integer;
        NameStart: Integer;
        NameEnd: Integer;
        DistanceText: Text;
    begin
        ItemName := '';
        IdValue := '';
        DistanceValue := 0;

        WorkText := ReplaceLineBreaksWithSpaces(Segment);
        WorkText := TrimTextSegment(WorkText);

        DotPos := StrPos(WorkText, '.');
        if DotPos > 0 then
            WorkText := TrimTextSegment(CopyStr(WorkText, DotPos + 1));

        NameStart := StrPos(WorkText, '**');
        if NameStart = 0 then
            exit(false);

        WorkText := CopyStr(WorkText, NameStart + 2);
        NameEnd := StrPos(WorkText, '**');
        if NameEnd = 0 then
            exit(false);

        ItemName := StripFormattingTokens(CopyStr(WorkText, 1, NameEnd - 1));
        WorkText := CopyStr(WorkText, NameEnd + 2);

        IdValue := StripFormattingTokens(TrimTextSegment(ExtractBetweenMarkers(WorkText, '(ID:', ')')));

        DistanceText := StripFormattingTokens(TrimTextSegment(ExtractAfterMarker(WorkText, 'Distance:')));
        if DistanceText <> '' then begin
            if StrPos(DistanceText, 'km') > 0 then
                DistanceText := TrimTextSegment(CopyStr(DistanceText, 1, StrPos(DistanceText, 'km') - 1));
            Evaluate(DistanceValue, DistanceText);
        end;

        exit(ItemName <> '');
    end;

    local procedure ReplaceLineBreaksWithSpaces(SourceText: Text): Text
    var
        Result: Text;
        Index: Integer;
        CurrentChar: Char;
        NextChar: Char;
    begin
        Result := '';
        Index := 1;

        while Index <= StrLen(SourceText) do begin
            CurrentChar := SourceText[Index];

            if (CurrentChar = 13) or (CurrentChar = 10) then begin
                Result := Result + ' ';
                Index += 1;
            end else
                if (CurrentChar = '\\') and (Index < StrLen(SourceText)) then begin
                    NextChar := SourceText[Index + 1];
                    if (NextChar = 'n') or (NextChar = 'r') then begin
                        Result := Result + ' ';
                        Index += 2;
                    end else begin
                        Result := Result + Format(CurrentChar);
                        Index += 1;
                    end;
                end else begin
                    Result := Result + Format(CurrentChar);
                    Index += 1;
                end;
        end;

        exit(Result);
    end;

    local procedure StripLeadingLiteralNewline(Input: Text): Text
    begin
        while (Input <> '') and (Input[1] = 'n') do begin
            if StrLen(Input) = 1 then
                exit('');

            if Input[2] = ' ' then begin
                if StrLen(Input) <= 2 then
                    exit('');

                Input := CopyStr(Input, 3);
            end else
                if IsDigitChar(Input[2]) or (Input[2] = '-') then
                    Input := CopyStr(Input, 2)
                else
                    break;
        end;

        exit(Input);
    end;

    local procedure TrimLeadingWhitespace(Input: Text): Text
    var
        StartIndex: Integer;
    begin
        StartIndex := 1;
        while (StartIndex <= StrLen(Input)) and IsWhitespace(Input[StartIndex]) do
            StartIndex += 1;

        exit(CopyStr(Input, StartIndex));
    end;

    local procedure TrimTextSegment(Input: Text): Text
    var
        StartIndex: Integer;
        EndIndex: Integer;
    begin
        if Input = '' then
            exit('');

        StartIndex := 1;
        while (StartIndex <= StrLen(Input)) and IsWhitespace(Input[StartIndex]) do
            StartIndex += 1;

        if StartIndex > StrLen(Input) then
            exit('');

        EndIndex := StrLen(Input);
        while (EndIndex >= StartIndex) and IsWhitespace(Input[EndIndex]) do
            EndIndex -= 1;

        exit(CopyStr(Input, StartIndex, EndIndex - StartIndex + 1));
    end;

    local procedure IsWhitespace(Value: Char): Boolean
    begin
        exit((Value = ' ') or (Value = 9) or (Value = 10) or (Value = 13));
    end;

    local procedure IsDigitChar(Value: Char): Boolean
    begin
        exit((Value >= '0') and (Value <= '9'));
    end;

    local procedure StripFormattingTokens(TextValue: Text): Text
    begin
        TextValue := TextValue.Replace('*', '');
        TextValue := TextValue.Replace('`', '');
        exit(TextValue);
    end;

    local procedure ExtractBetweenMarkers(SourceText: Text; StartMarker: Text; EndMarker: Text): Text
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        StartPos := StrPos(SourceText, StartMarker);
        if StartPos = 0 then
            exit('');

        StartPos += StrLen(StartMarker);
        if StartPos > StrLen(SourceText) then
            exit('');

        EndPos := StrPos(CopyStr(SourceText, StartPos), EndMarker);
        if EndPos = 0 then
            exit('');

        exit(CopyStr(SourceText, StartPos, EndPos - 1));
    end;

    local procedure ExtractAfterMarker(SourceText: Text; Marker: Text): Text
    var
        StartPos: Integer;
    begin
        StartPos := StrPos(SourceText, Marker);
        if StartPos = 0 then
            exit('');

        StartPos += StrLen(Marker);
        exit(CopyStr(SourceText, StartPos));
    end;

    local procedure ResolveCoordinatesFromEntity(EntityId: Text; EntityType: Enum "GeoAI Entity Type"; var Lat: Decimal; var Lon: Decimal): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        // Look up entity by ID and return real GeoAI coordinates from BC
        // OSS version supports Customer and Vendor only
        case EntityType of
            EntityType::Customer:
                if Customer.Get(EntityId) then begin
                    Lat := Customer."GeoAI Latitude";
                    Lon := Customer."GeoAI Longitude";
                    exit(true);
                end;
            EntityType::Vendor:
                if Vendor.Get(EntityId) then begin
                    Lat := Vendor."GeoAI Latitude";
                    Lon := Vendor."GeoAI Longitude";
                    exit(true);
                end;
        end;
        exit(false);
    end;
}
