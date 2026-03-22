/// <summary>
/// Page GeoAI Prompt (ID 70028).
/// PromptDialog for GeoAI interactions with Copilot UX.
/// Provides prompt guide, parameter options, and result display.
/// </summary>
page 70028 "GeoAI Prompt"
{
    PageType = PromptDialog;
    Extensible = false;
    Caption = 'GeoAI for Business Central';
    IsPreview = true;

    layout
    {
        area(Prompt)
        {
            field(InputPrompt; InputPrompt)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
                InstructionalText = 'Describe what you need, or pick a prompt from the guide below...';
            }
            group(ContextInfo)
            {
                Caption = 'Context';

                field(EntityContext; EntityContext)
                {
                    ApplicationArea = All;
                    Caption = 'Entity';
                    Editable = false;
                    ToolTip = 'Shows the entity this prompt is about.';
                }
                field(RadiusKm; RadiusKm)
                {
                    ApplicationArea = All;
                    Caption = 'Search Radius (km)';
                    ToolTip = 'The radius in kilometers for proximity searches.';
                    MinValue = 1;
                    MaxValue = 500;
                    Visible = ShowRadiusInput;
                }
                field(MaxResults; MaxResults)
                {
                    ApplicationArea = All;
                    Caption = 'Max Results';
                    ToolTip = 'Maximum number of results to return.';
                    MinValue = 1;
                    MaxValue = 100;
                    Visible = ShowMaxResultsInput;
                }
            }
        }

        area(PromptOptions)
        {
        }

        area(Content)
        {
            group(ResultSurface)
            {
                Caption = 'GeoAI Result';
                Visible = ResultVisible;
                field(AnswerText; ResponseText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    MultiLine = true;
                    //ExtendedDataType = RichContent;
                    Editable = false;
                    ToolTip = 'Answer-focused view of the latest GeoAI response.';
                }

            }
            group(ResultActions)
            {
                Caption = 'Result Actions';
                Visible = ResultVisible;

                group(ErrorBanner)
                {
                    ShowCaption = false;
                    Visible = HasError;

                    field(ResultError; ResultErrorMessage)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        Style = Attention;
                        ToolTip = 'Displays errors returned by the AI provider.';
                    }
                }

            }
            // part(ResultTable; "GeoAI Result Items")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Items';
            //     Visible = HasTableData;
            //     UpdatePropagation = Both;
            // }
            group(ResultItens)
            {
                Visible = HasTableData;
                ShowCaption = false;

                part(ResultTable; "GeoAI Result Items")
                {
                    ApplicationArea = All;
                }
            }

            part(PromptGuide; "GeoAI Prompt Guide")
            {
                ApplicationArea = All;
                Caption = 'Prompt Templates';
                Visible = not HasRunOnce;
            }
        }
    }

    actions
    {
        area(PromptGuide)
        {
            // action(ChangeTemplate)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Change Template…';
            //     ToolTip = 'Select a different prompt template.';

            //     trigger OnAction()
            //     begin
            //         RunChangeTemplate();
            //     end;
            // }

            group(ProximityScenarios)
            {
                Caption = 'Proximity & Search';

                action(FindNearby)
                {
                    ApplicationArea = All;
                    Caption = 'Find Nearby...';
                    ToolTip = 'Find nearby records relative to the current entity.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::ProximitySearch,
                          "GeoAI Template Intent"::FindNearby,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(FindNearest)
                {
                    ApplicationArea = All;
                    Caption = 'Find Nearest...';
                    ToolTip = 'Find the nearest relevant records based on anchor context.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::ProximitySearch,
                          "GeoAI Template Intent"::FindNearest,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(SearchRegion)
                {
                    ApplicationArea = All;
                    Caption = 'Search in Region...';
                    ToolTip = 'Search within a broader region around the current entity.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::ProximitySearch,
                          "GeoAI Template Intent"::SearchInRegion,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }
            }

            group(RoutingScenarios)
            {
                Caption = 'Routing & Planning';

                action(PlanRoute)
                {
                    ApplicationArea = All;
                    Caption = 'Plan Route...';
                    ToolTip = 'Create an optimized multi-stop route.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::RoutingPlanning,
                          "GeoAI Template Intent"::PlanRoute,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(ScheduleVisits)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule Visits...';
                    ToolTip = 'Schedule deliveries or visits based on proximity and time windows.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::RoutingPlanning,
                          "GeoAI Template Intent"::ScheduleVisits,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(TerritoryPlanning)
                {
                    ApplicationArea = All;
                    Caption = 'Territory Planning...';
                    ToolTip = 'Analyze and optimize sales territories.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::RoutingPlanning,
                          "GeoAI Template Intent"::TerritoryPlanning,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }
            }

            group(AnalyticsScenarios)
            {
                Caption = 'Analytics & Insights';

                action(CoverageAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'Coverage Analysis...';
                    ToolTip = 'Evaluate heatmaps and coverage for anchored records.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::AnalyticsInsights,
                          "GeoAI Template Intent"::Coverage,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(ClusterAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'Cluster Analysis...';
                    ToolTip = 'Identify clusters and patterns for anchored records.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::AnalyticsInsights,
                          "GeoAI Template Intent"::Cluster,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }

                action(ExpansionOpportunities)
                {
                    ApplicationArea = All;
                    Caption = 'Expansion Opportunities...';
                    ToolTip = 'Find potential expansion locations.';

                    trigger OnAction()
                    begin
                        RunTemplateAction("GeoAI Template Category"::AnalyticsInsights,
                          "GeoAI Template Intent"::Expansion,
                          "GeoAI Target Entity"::SameAsAnchor);
                    end;
                }
            }
        }

        area(SystemActions)
        {
            systemaction(Generate)
            {
                ToolTip = 'Generate AI response based on your prompt.';
                Enabled = not HasRunOnce;

                trigger OnAction()
                begin
                    RunGenerate();
                end;
            }
            systemaction(Regenerate)
            {
                ToolTip = 'Regenerate the AI response with the same prompt.';
                Enabled = HasRunOnce;

                trigger OnAction()
                begin
                    RunGenerate();
                end;
            }

            systemaction(OK)
            {
                ToolTip = 'Accept the result and close the dialog.';
            }
            systemaction(Cancel)
            {
                ToolTip = 'Cancel and close the dialog without saving.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TemplateCodeToApply: Code[50];
    begin
        if PendingTemplateCode <> '' then begin
            TemplateCodeToApply := PendingTemplateCode;
            PendingTemplateCode := '';
        end else
            TemplateCodeToApply := CurrPage.PromptGuide.Page.GetSelectedTemplate();

        if (TemplateCodeToApply <> '') and (TemplateCodeToApply <> SelectedTemplateCode) then begin
            ApplyTemplate(TemplateCodeToApply);
            SelectedTemplateCode := TemplateCodeToApply;
        end;
    end;

    var
        EntityRecordID: RecordId;
        EntityType: Enum "GeoAI Entity Type";
        InputPrompt: Text;
        RadiusKm: Integer;
        MaxResults: Integer;
        ResponseText: Text;
        EntityContext: Text;
        ResultVisible: Boolean;
        SelectedTemplateCode: Code[50];
        EntityLatitude: Decimal;
        EntityLongitude: Decimal;
        EntityNo: Code[20];
        CurrentAnchorEntity: Enum "GeoAI Anchor Entity";
        CurrentScope: Enum "GeoAI Template Scope";
        SelectedAnchorEntity: Enum "GeoAI Anchor Entity";
        SelectedTargetEntity: Enum "GeoAI Target Entity";
        SelectedCategory: Enum "GeoAI Template Category";
        SelectedIntent: Enum "GeoAI Template Intent";
        SelectedScope: Enum "GeoAI Template Scope";
        SelectedScenario: Enum "GeoAI Scenario";
        PendingTemplateCode: Code[50];
        ShowRadiusInput: Boolean;
        ShowMaxResultsInput: Boolean;
        RawJsonText: Text;
        HasRunOnce: Boolean;
        HasTableData: Boolean;
        HasError: Boolean;
        ResultErrorMessage: Text[250];
        EmptyPromptErr: Label 'Please enter a prompt or select one from the guide.';
        CandidateContextJson: Text;
        TemplateSummaryFmtLbl: Label '%1 %2', Locked = true;
        NoTemplatesForActionLbl: Label 'No templates match this action for %1.', Comment = '%1 = Anchor entity caption';
        AiRequestFailedLbl: Label 'GeoAI request failed. Details: %1', Comment = '%1 = Provider error text shown to the user.';
        UnknownErrorDetailLbl: Label 'Unknown error.';
    // PlaceholderMsg kept for earlier demo; no longer used after real integration
    // PlaceholderMsg: Label 'Prompt received: "%1"\Context: %2\Radius: %3 km\Max Results: %4\Model Policy: %5', Comment = '%1 = Prompt text, %2 = Entity context, %3 = Radius, %4 = Max results, %5 = Cost mode';

    /// <summary>
    /// Initializes the prompt dialog with entity context.
    /// </summary>
    /// <param name="RecID">RecordID of the entity.</param>
    /// <param name="EntType">Entity type.</param>
    procedure Initialize(RecID: RecordId; EntType: Enum "GeoAI Entity Type")
    begin
        InitializeWithScope(RecID, EntType, "GeoAI Template Scope"::Self);
    end;

    /// <summary>
    /// Initializes the prompt dialog and queues a template to auto-apply when the page opens.
    /// </summary>
    /// <param name="RecID">RecordID of the entity.</param>
    /// <param name="EntType">Entity type.</param>
    /// <param name="ScopeContext">Scope context for the invocation.</param>
    /// <param name="TemplateCode">Template code to apply on open.</param>
    procedure InitializeWithTemplate(RecID: RecordId; EntType: Enum "GeoAI Entity Type";
        ScopeContext: Enum "GeoAI Template Scope"; TemplateCode: Code[50])
    begin
        InitializeWithScope(RecID, EntType, ScopeContext);
        PendingTemplateCode := TemplateCode;
    end;

    procedure InitializeWithScope(RecID: RecordId; EntType: Enum "GeoAI Entity Type"; ScopeContext: Enum "GeoAI Template Scope")
    var
        GeoAISetup: Record "GeoAI Setup";
        DefaultRadiusKm: Integer;
        DefaultMaxResults: Integer;
    begin
        DefaultRadiusKm := 100;
        DefaultMaxResults := 20;

        EntityRecordID := RecID;
        EntityType := EntType;
        CurrentAnchorEntity := MapAnchorEntity(EntityType);
        CurrentScope := ScopeContext;
        PendingTemplateCode := '';
        SelectedAnchorEntity := CurrentAnchorEntity;
        SelectedTargetEntity := MapAnchorToTarget(CurrentAnchorEntity);
        SelectedCategory := SelectedCategory::" ";
        SelectedIntent := SelectedIntent::Undefined;
        SelectedScope := ScopeContext;
        SelectedScenario := SelectedScenario::ProximitySearch;

        BuildEntityContextText();
        ValidateEntityGeocoding();

        // Read radius and max results from GeoAI Setup, fallback to defaults
        if GeoAISetup.Get() then begin
            if GeoAISetup."Candidate Search Radius" > 0 then
                RadiusKm := GeoAISetup."Candidate Search Radius"
            else
                RadiusKm := DefaultRadiusKm;

            if GeoAISetup."Max Candidates Sent To AI" > 0 then
                MaxResults := GeoAISetup."Max Candidates Sent To AI"
            else
                MaxResults := DefaultMaxResults;
        end else begin
            RadiusKm := DefaultRadiusKm;
            MaxResults := DefaultMaxResults;
        end;

        ResultVisible := true;
        RawJsonText := '';
        CandidateContextJson := '[]';
        ShowRadiusInput := false;
        ShowMaxResultsInput := false;
        ResetResultState();

        // Filter template guide by entity type
        CurrPage.PromptGuide.Page.FilterByEntityType(EntityType);
    end;

    local procedure ValidateEntityGeocoding()
    var
        EntityFactory: Codeunit "GeoAI Entity Factory";
        EntityProvider: Interface "IGeoAI Entity";
        NotGeocodedErr: Label 'This %1 is not geocoded yet. Please run "Geocode Address" first before using GeoAI features.', Comment = '%1 = Entity type';
    begin
        if not EntityFactory.IsEntityTypeSupported(EntityType) then
            exit;

        EntityProvider := EntityFactory.GetEntityProvider(EntityType);

        if not EntityProvider.ValidateGeocodingStatus(EntityRecordID) then
            Error(NotGeocodedErr, Format(EntityType));

        // Extract coordinates for proximity validation
        ExtractEntityCoordinates();
    end;

    local procedure ExtractEntityCoordinates()
    var
        EntityFactory: Codeunit "GeoAI Entity Factory";
        EntityProvider: Interface "IGeoAI Entity";
        LocationContext: JsonObject;
        LatToken: JsonToken;
        LonToken: JsonToken;
    begin
        EntityProvider := EntityFactory.GetEntityProvider(EntityType);
        LocationContext := EntityProvider.GetLocationContext(EntityRecordID);

        if LocationContext.Get('lat', LatToken) then
            EntityLatitude := LatToken.AsValue().AsDecimal();
        if LocationContext.Get('lon', LonToken) then
            EntityLongitude := LonToken.AsValue().AsDecimal();
    end;

    local procedure BuildEntityContextText()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        Contact: Record Contact;
        Employee: Record Employee;
        Resource: Record Resource;
        Job: Record Job;
        BankAccount: Record "Bank Account";
        CustomerLbl: Label 'Customer %1 - %2', Comment = '%1 = No., %2 = Name';
        VendorLbl: Label 'Vendor %1 - %2', Comment = '%1 = No., %2 = Name';
        LocationLbl: Label 'Location %1 - %2', Comment = '%1 = Code, %2 = Name';
        ContactLbl: Label 'Contact %1 - %2', Comment = '%1 = No., %2 = Name';
        EmployeeLbl: Label 'Employee %1 - %2 %3', Comment = '%1 = No., %2 = First Name, %3 = Last Name';
        ResourceLbl: Label 'Resource %1 - %2', Comment = '%1 = No., %2 = Name';
        JobLbl: Label 'Job %1 - %2', Comment = '%1 = No., %2 = Description';
        BankAccountLbl: Label 'Bank Account %1 - %2', Comment = '%1 = No., %2 = Name';
    begin
        EntityNo := '';
        case EntityType of
            EntityType::Customer:
                if Customer.Get(EntityRecordID) then begin
                    EntityNo := Customer."No.";
                    EntityContext := StrSubstNo(CustomerLbl, Customer."No.", Customer.Name);
                end;
            EntityType::Vendor:
                if Vendor.Get(EntityRecordID) then begin
                    EntityNo := Vendor."No.";
                    EntityContext := StrSubstNo(VendorLbl, Vendor."No.", Vendor.Name);
                end;
            EntityType::Location:
                if Location.Get(EntityRecordID) then begin
                    EntityNo := Location.Code;
                    EntityContext := StrSubstNo(LocationLbl, Location.Code, Location.Name);
                end;
            EntityType::Contact:
                if Contact.Get(EntityRecordID) then begin
                    EntityNo := Contact."No.";
                    EntityContext := StrSubstNo(ContactLbl, Contact."No.", Contact.Name);
                end;
            EntityType::Employee:
                if Employee.Get(EntityRecordID) then begin
                    EntityNo := Employee."No.";
                    EntityContext := StrSubstNo(EmployeeLbl, Employee."No.", Employee."First Name", Employee."Last Name");
                end;
            EntityType::Resource:
                if Resource.Get(EntityRecordID) then begin
                    EntityNo := Resource."No.";
                    EntityContext := StrSubstNo(ResourceLbl, Resource."No.", Resource.Name);
                end;
            EntityType::Job:
                if Job.Get(EntityRecordID) then begin
                    EntityNo := Job."No.";
                    EntityContext := StrSubstNo(JobLbl, Job."No.", Job.Description);
                end;
            EntityType::BankAccount:
                if BankAccount.Get(EntityRecordID) then begin
                    EntityNo := BankAccount."No.";
                    EntityContext := StrSubstNo(BankAccountLbl, BankAccount."No.", BankAccount.Name);
                end;
            else
                EntityContext := 'No context';
        end;
    end;

    local procedure RunGenerate()
    var
        AIClient: Codeunit "GeoAI Client";
        ResponseConstraints: Codeunit "GeoAI Response Constraints";
        Err: ErrorInfo;
        ResultJson: Text;
        SystemPrompt: Text;
        GenOkMsg: Label 'Response generated successfully.';
        ProviderErrorText: Text;
        HasData: Boolean;
    begin
        InputPrompt := DelChr(InputPrompt, '<>', ' ');
        if InputPrompt = '' then begin
            Err.Message := EmptyPromptErr;
            Err.DetailedMessage := 'Select a prompt from the guide or type your own question.';
            Error(Err);
        end;

        HasError := false;
        ResultErrorMessage := '';

        // GeoAI Prompt Page only supports Mode A (Entity-Grounded)
        // Validate that entity data is present
        if not ValidateNearbyCandidates() then
            CandidateContextJson := '[]';

        if CandidateContextJson = '' then
            CandidateContextJson := '[]';

        // Check if we have actual entity data
        HasData := ResponseConstraints.HasEntityDataInPayload(CandidateContextJson, EntityContext);

        // Deterministic fallback if Mode A but no data - BLOCK the call
        if not HasData then begin
            HandleRunFailure(ResponseConstraints.GetEntityRequiredFallbackMessage('Prompt'));
            exit;
        end;

        // Enrich entity context with address data
        if EntityRecordID.TableNo <> 0 then
            ResponseConstraints.EnrichEntityContextWithAddress(EntityRecordID, EntityType, EntityContext);

        // Build Mode A (Entity-Grounded) system prompt
        SystemPrompt := ResponseConstraints.BuildSystemPrompt(true, true);

        if not AIClient.RunPrompt(SystemPrompt, BuildUserText(), ResultJson) then begin
            ProviderErrorText := CopyStr(GetLastErrorText(), 1, MaxStrLen(ResultErrorMessage));
            HandleRunFailure(ProviderErrorText);
            exit;
        end;

        // The client returns assistant content text in ResultJson
        // Strip markdown code fences if present (defensive)
        RawJsonText := StripMarkdownCodeFences(ResultJson);
        ResponseText := ExtractAndFormatSummary(RawJsonText);

        ResultVisible := true;
        HasRunOnce := true;

        RefreshResultTablePart();
        CurrPage.Update(true);

        Message(GenOkMsg);
    end;

    local procedure HandleRunFailure(ErrorText: Text)
    var
        DetailText: Text[250];
    begin
        ResetResultState();
        DetailText := CopyStr(ErrorText, 1, MaxStrLen(ResultErrorMessage));
        if DetailText = '' then
            DetailText := UnknownErrorDetailLbl;

        HasRunOnce := true;
        HasError := true;
        ResultVisible := true;
        ResultErrorMessage := CopyStr(StrSubstNo(AiRequestFailedLbl, DetailText), 1, MaxStrLen(ResultErrorMessage));

        RefreshResultTablePart();
        CurrPage.Update(true);
    end;

    local procedure BuildUserText(): Text
    var
        Base: Text;
    begin
        // Include minimal structured context so the model can use it
        Base := StrSubstNo(UserTextFmtLbl, EntityContext, RadiusKm, MaxResults, CandidateContextJson, InputPrompt);
        exit(Base);
    end;

    /// <summary>
    /// Applies a selected template to the prompt.
    /// </summary>
    /// <param name="TemplateCode">Code of the template to apply.</param>
    procedure ApplyTemplate(TemplateCode: Code[50])
    var
        PromptTemplate: Record "GeoAI Prompt Template";
        TemplateText: Text;
    begin
        if not PromptTemplate.Get(TemplateCode) then
            exit;

        SelectedTemplateCode := TemplateCode;
        SelectedScenario := PromptTemplate."Scenario Code";
        SelectedAnchorEntity := PromptTemplate."Anchor Entity";
        SelectedTargetEntity := PromptTemplate."Target Entity";
        SelectedCategory := PromptTemplate.Category;
        SelectedIntent := PromptTemplate.Intent;
        SelectedScope := PromptTemplate.Scope;
        ApplyTemplateVariables(PromptTemplate);

        // Get template text and substitute variables
        TemplateText := PromptTemplate.GetTemplateText();

        // Apply default parameters from template
        if PromptTemplate."Default Radius (km)" > 0 then
            RadiusKm := PromptTemplate."Default Radius (km)";
        if PromptTemplate."Max Results" > 0 then
            MaxResults := PromptTemplate."Max Results";

        // Substitute placeholders
        TemplateText := TemplateText.Replace('{{SourceName}}', EntityContext);
        TemplateText := TemplateText.Replace('{{RadiusKm}}', Format(RadiusKm));
        TemplateText := TemplateText.Replace('{{MaxResults}}', Format(MaxResults));

        if PromptTemplate.Description <> '' then
            TemplateText := StrSubstNo(TemplateSummaryFmtLbl, EnsureSentenceEndsWithPeriod(PromptTemplate.Description), TemplateText);

        InputPrompt := TemplateText;
        CurrPage.Update(false);
    end;

    local procedure EnsureSentenceEndsWithPeriod(Description: Text[250]): Text
    var
        LastChar: Text[1];
    begin
        if Description = '' then
            exit('');

        LastChar := CopyStr(Description, StrLen(Description), 1);
        if (LastChar = '.') or (LastChar = '!') or (LastChar = '?') then
            exit(Description);

        exit(Description + '.');
    end;

    /// <summary>
    /// Opens the template picker filtered by the requested scenario and applies the selected template.
    /// </summary>
    /// <param name="Scenario">Scenario to filter templates by.</param>
    local procedure RunTemplateAction(Category: Enum "GeoAI Template Category"; Intent: Enum "GeoAI Template Intent"; PreferredTarget: Enum "GeoAI Target Entity")
    var
        PromptTemplate: Record "GeoAI Prompt Template";
        TemplateSelector: Codeunit "GeoAI Template Selector";
        TemplatePicker: Page "GeoAI Template Picker";
        AnchorEntity: Enum "GeoAI Anchor Entity";
        TargetOverride: Enum "GeoAI Target Entity";
        TemplateCount: Integer;
    begin
        AnchorEntity := CurrentAnchorEntity;
        TargetOverride := ResolveTargetPreference(AnchorEntity, Intent, PreferredTarget);

        TemplateCount := TemplateSelector.SelectByAction(AnchorEntity, TargetOverride, Category, Intent, CurrentScope, PromptTemplate);

        if TemplateCount = 0 then begin
            Message(NoTemplatesForActionLbl, Format(AnchorEntity));
            exit;
        end;

        if TemplateCount = 1 then begin
            if not PromptTemplate.FindFirst() then begin
                Message(NoTemplatesForActionLbl, Format(AnchorEntity));
                exit;
            end;

            ApplyTemplate(PromptTemplate.Code);
            exit;
        end;

        TemplatePicker.SetTableView(PromptTemplate);
        TemplatePicker.LookupMode(true);
        if TemplatePicker.RunModal() = ACTION::LookupOK then begin
            TemplatePicker.GetRecord(PromptTemplate);
            ApplyTemplate(PromptTemplate.Code);
        end;
    end;

    local procedure MapAnchorEntity(CurrentEntityType: Enum "GeoAI Entity Type"): Enum "GeoAI Anchor Entity"
    begin
        // OSS version only supports Customer and Vendor
        case CurrentEntityType of
            CurrentEntityType::Customer:
                exit("GeoAI Anchor Entity"::Customer);
            CurrentEntityType::Vendor:
                exit("GeoAI Anchor Entity"::Vendor);
        end;

        exit("GeoAI Anchor Entity"::Any);
    end;

    local procedure ResolveTargetPreference(AnchorEntity: Enum "GeoAI Anchor Entity"; Intent: Enum "GeoAI Template Intent"; PreferredTarget: Enum "GeoAI Target Entity"): Enum "GeoAI Target Entity"
    begin
        // OSS version: for FindNearest, Customer looks for Vendors
        if Intent <> Intent::FindNearest then
            exit(PreferredTarget);

        case AnchorEntity of
            "GeoAI Anchor Entity"::Customer:
                exit("GeoAI Target Entity"::Vendor);
            "GeoAI Anchor Entity"::Vendor:
                exit("GeoAI Target Entity"::Customer);
        end;

        exit(PreferredTarget);
    end;

    local procedure MapAnchorToTarget(AnchorEntity: Enum "GeoAI Anchor Entity"): Enum "GeoAI Target Entity"
    begin
        // OSS version only supports Customer and Vendor
        case AnchorEntity of
            "GeoAI Anchor Entity"::Customer:
                exit("GeoAI Target Entity"::Customer);
            "GeoAI Anchor Entity"::Vendor:
                exit("GeoAI Target Entity"::Vendor);
        end;

        exit("GeoAI Target Entity"::Any);
    end;

    local procedure ApplyTemplateVariables(var PromptTemplate: Record "GeoAI Prompt Template")
    var
        VariablesText: Text;
        VariablesJson: JsonObject;
        VariableToken: JsonToken;
    begin
        ShowRadiusInput := false;
        ShowMaxResultsInput := false;

        VariablesText := PromptTemplate.GetVariables();
        if VariablesText = '' then
            exit;

        if not VariablesJson.ReadFrom(VariablesText) then
            exit;

        if VariablesJson.Get('RadiusKm', VariableToken) then
            ShowRadiusInput := true;
        if VariablesJson.Get('MaxResults', VariableToken) then
            ShowMaxResultsInput := true;
    end;


    local procedure ResetResultState()
    begin
        RawJsonText := '';
        HasTableData := false;
        HasError := false;
        ResultErrorMessage := '';
    end;

    local procedure RefreshResultTablePart()
    var
        MapAvailable: Boolean;
        HasRows: Boolean;
    begin
        MapAvailable := false;

        HasRows := CurrPage.ResultTable.PAGE.LoadFromResponsePayload(RawJsonText, EntityType, MapAvailable);
        CurrPage.ResultTable.PAGE.SetRawJsonForExport(RawJsonText);
        if HasRows then
            HasTableData := true
        else begin
            CurrPage.ResultTable.PAGE.ClearItems();
            HasTableData := false;
        end;
    end;

    local procedure StripMarkdownCodeFences(JsonText: Text): Text
    var
        CleanedText: Text;
    begin
        if JsonText = '' then
            exit('');

        CleanedText := JsonText;

        // Remove ```json at start
        if CleanedText.StartsWith('```json') then
            CleanedText := DelStr(CleanedText, 1, 7);
        if CleanedText.StartsWith('```') then
            CleanedText := DelStr(CleanedText, 1, 3);

        // Remove ``` at end
        if CleanedText.EndsWith('```') then
            CleanedText := DelStr(CleanedText, StrLen(CleanedText) - 2, 3);

        // Trim whitespace
        CleanedText := DelChr(CleanedText, '<>', ' \r\n\t');

        exit(CleanedText);
    end;

    local procedure ExtractAndFormatSummary(JsonResponse: Text): Text
    var
        ResponseObj: JsonObject;
        AnswerToken: JsonToken;
        SummaryToken: JsonToken;
        SummaryText: Text;
    begin
        if JsonResponse = '' then
            exit('');

        // Try to parse as JSON and extract answer_markdown or summary field
        if ResponseObj.ReadFrom(JsonResponse) then begin
            // Try answer_markdown first (v2 schema)
            if ResponseObj.Get('answer_markdown', AnswerToken) then
                if AnswerToken.IsValue() then begin
                    SummaryText := AnswerToken.AsValue().AsText();
                    if SummaryText <> '' then
                        exit(FormatResponseForRichContent(SummaryText));
                end;

            // Fall back to summary (v1 schema)
            if ResponseObj.Get('summary', SummaryToken) then
                if SummaryToken.IsValue() then begin
                    SummaryText := SummaryToken.AsValue().AsText();
                    if SummaryText <> '' then
                        exit(FormatResponseForRichContent(SummaryText));
                end;
        end;

        // Fallback: if not valid JSON or no answer field found, return message
        exit('Response contains structured data. View Result Items table below.');
    end;

    local procedure FormatResponseForRichContent(RawResponse: Text): Text
    var
        FormattedText: Text;
        ActualLineBreak: Char;
    begin
        if RawResponse = '' then
            exit('');

        ActualLineBreak := 10; // Line Feed character
        FormattedText := RawResponse;

        // Convert escaped newlines (\n) to actual newlines for plain text display
        FormattedText := FormattedText.Replace('\n', Format(ActualLineBreak));
        FormattedText := FormattedText.Replace('\r\n', Format(ActualLineBreak));
        FormattedText := FormattedText.Replace('\r', Format(ActualLineBreak));

        // Remove excessive consecutive line breaks (more than 2)
        while StrPos(FormattedText, Format(ActualLineBreak) + Format(ActualLineBreak) + Format(ActualLineBreak)) > 0 do
            FormattedText := FormattedText.Replace(Format(ActualLineBreak) + Format(ActualLineBreak) + Format(ActualLineBreak),
                                                   Format(ActualLineBreak) + Format(ActualLineBreak));

        exit(FormattedText);
    end;

    /// <summary>
    /// Validates if there are geocoded candidates nearby and injects anchor entity as first item.
    /// </summary>
    local procedure ValidateNearbyCandidates(): Boolean
    var
        EntityFactory: Codeunit "GeoAI Entity Factory";
        EntityProvider: Interface "IGeoAI Entity";
        Candidates: JsonArray;
        EnhancedCandidates: JsonArray;
        AnchorObject: JsonObject;
        CandidateToken: JsonToken;
        CandidateId: Text;
        MaxNearby: Integer;
        NoCandidatesErr: Label 'No geocoded %1 found within %2 km of this entity. Consider increasing the search radius.', Comment = '%1 = Entity type, %2 = Radius';
    begin
        CandidateContextJson := '';

        EntityProvider := EntityFactory.GetEntityProvider(EntityType);

        // Leave room in the list for the anchor at index 0
        MaxNearby := MaxResults - 1;
        if MaxNearby < 1 then
            MaxNearby := 1;

        // Get nearby candidates (EXCLUDING anchor)
        Candidates := EntityProvider.GetNearbyCandidates(
            EntityLatitude,
            EntityLongitude,
            RadiusKm,
            MaxNearby);

        // If nothing is nearby we still don't want to show only the anchor
        if Candidates.Count() = 0 then begin
            Message(NoCandidatesErr, Format(EntityType), RadiusKm);
            exit(false);
        end;

        // Inject anchor entity as first element
        AnchorObject.Add('id', EntityNo);
        AnchorObject.Add('name', GetAnchorEntityName());
        AnchorObject.Add('description', 'Anchor entity');
        AnchorObject.Add('lat', EntityLatitude);
        AnchorObject.Add('lon', EntityLongitude);
        AnchorObject.Add('distanceKm', 0);
        AnchorObject.Add('etaMinutes', 0);
        AnchorObject.Add('score', 1);

        EnhancedCandidates.Add(AnchorObject.AsToken());

        // Copy nearby candidates, but do not exceed MaxResults
        foreach CandidateToken in Candidates do begin
            if EnhancedCandidates.Count() >= MaxResults then
                break;

            // Safety: if a provider ever starts returning the anchor itself, skip it
            if CandidateToken.IsObject() then
                if TryGetCandidateId(CandidateToken.AsObject(), CandidateId) then
                    if CandidateId = EntityNo then
                        continue;

            EnhancedCandidates.Add(CandidateToken);
        end;

        EnhancedCandidates.WriteTo(CandidateContextJson);
        exit(true);
    end;

    local procedure TryGetCandidateId(CandidateObj: JsonObject; var CandidateId: Text): Boolean
    var
        IdToken: JsonToken;
    begin
        if CandidateObj.Get('id', IdToken) then begin
            CandidateId := IdToken.AsValue().AsText();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetAnchorEntityName(): Text
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        Contact: Record Contact;
        Employee: Record Employee;
        Resource: Record Resource;
        Job: Record Job;
        BankAccount: Record "Bank Account";
    begin
        case EntityType of
            EntityType::Customer:
                if Customer.Get(EntityNo) then
                    exit(Customer.Name);
            EntityType::Vendor:
                if Vendor.Get(EntityNo) then
                    exit(Vendor.Name);
            EntityType::Location:
                if Location.Get(EntityNo) then
                    exit(Location.Name);
            EntityType::Contact:
                if Contact.Get(EntityNo) then
                    exit(Contact.Name);
            EntityType::Employee:
                if Employee.Get(EntityNo) then
                    exit(Employee."First Name" + ' ' + Employee."Last Name");
            EntityType::Resource:
                if Resource.Get(EntityNo) then
                    exit(Resource.Name);
            EntityType::Job:
                if Job.Get(EntityNo) then
                    exit(Job.Description);
            EntityType::BankAccount:
                if BankAccount.Get(EntityNo) then
                    exit(BankAccount.Name);
        end;

        // Fallback so you always have something
        exit(EntityNo);
    end;

    var
        UserTextFmtLbl: Label 'Context: %1\nRadiusKm: %2\nMaxResults: %3\nCandidateData: %4\n\nUser: %5', Locked = true;
}
