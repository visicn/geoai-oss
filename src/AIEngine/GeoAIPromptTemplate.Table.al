/// <summary>
/// Table GeoAI Prompt Template (ID 70001).
/// Stores prompt templates for GeoAI scenarios including system text, template text, tools, and output schema.
/// </summary>
table 70001 "GeoAI Prompt Template"
{
    Caption = 'GeoAI Prompt Template';
    DataPerCompany = true;
    DataClassification = CustomerContent;
    LookupPageId = "GeoAI Prompt Templates";
    DrillDownPageId = "GeoAI Prompt Templates";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Entity Type"; Enum "GeoAI Entity Type")
        {
            Caption = 'Entity Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                UnsupportedEntityTypeErr: Label 'OSS version only supports Customer and Vendor entity types.';
            begin
                if not ("Entity Type" in ["Entity Type"::" ", "Entity Type"::Customer, "Entity Type"::Vendor]) then
                    Error(UnsupportedEntityTypeErr);
            end;
        }
        field(3; "Scenario Code"; Enum "GeoAI Scenario")
        {
            Caption = 'Scenario';
            DataClassification = CustomerContent;
        }
        field(10; Title; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "System Text"; Blob)
        {
            Caption = 'System Text';
            DataClassification = CustomerContent;
        }
        field(21; "Template Text"; Blob)
        {
            Caption = 'Template Text';
            DataClassification = CustomerContent;
        }
        field(30; "Tools Json"; Blob)
        {
            Caption = 'Tools Json';
            DataClassification = CustomerContent;
        }
        field(31; "Output Schema"; Blob)
        {
            Caption = 'Output Schema';
            DataClassification = CustomerContent;
        }
        field(32; Variables; Blob)
        {
            Caption = 'Variables';
            DataClassification = CustomerContent;
        }
        field(40; Version; Code[20])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            InitValue = '1.0';
        }
        field(50; "Max Results"; Integer)
        {
            Caption = 'Max Results';
            DataClassification = CustomerContent;
            MinValue = 1;
            InitValue = 10;
        }
        field(51; "Default Radius (km)"; Decimal)
        {
            Caption = 'Default Radius (km)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            InitValue = 50;
        }
        field(61; "Confidence Override"; Decimal)
        {
            Caption = 'Confidence Threshold Override';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(70; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(71; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Anchor Entity"; Enum "GeoAI Anchor Entity")
        {
            Caption = 'Anchor Entity';
            DataClassification = CustomerContent;
            InitValue = Any;

            trigger OnValidate()
            var
                UnsupportedAnchorErr: Label 'OSS version only supports Any, Customer, and Vendor anchor entities.';
            begin
                if not ("Anchor Entity" in ["Anchor Entity"::Any, "Anchor Entity"::Customer, "Anchor Entity"::Vendor]) then
                    Error(UnsupportedAnchorErr);
            end;
        }
        field(81; "Target Entity"; Enum "GeoAI Target Entity")
        {
            Caption = 'Target Entity';
            DataClassification = CustomerContent;
            InitValue = Any;

            trigger OnValidate()
            var
                UnsupportedTargetErr: Label 'OSS version only supports Any, Same as Anchor, Customer, and Vendor target entities.';
            begin
                if not ("Target Entity" in ["Target Entity"::Any, "Target Entity"::SameAsAnchor, "Target Entity"::Customer, "Target Entity"::Vendor]) then
                    Error(UnsupportedTargetErr);
            end;
        }
        field(82; Category; Enum "GeoAI Template Category")
        {
            Caption = 'Category';
            DataClassification = CustomerContent;
        }
        field(83; Intent; Enum "GeoAI Template Intent")
        {
            Caption = 'Intent';
            DataClassification = CustomerContent;
            InitValue = Undefined;
        }
        field(84; Scope; Enum "GeoAI Template Scope")
        {
            Caption = 'Scope';
            DataClassification = CustomerContent;
            InitValue = Self;

            trigger OnValidate()
            var
                UnsupportedScopeErr: Label 'OSS version only supports Self, Selection, and Region scopes.';
            begin
                if not (Scope in [Scope::Self, Scope::Selection, Scope::Region]) then
                    Error(UnsupportedScopeErr);
            end;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(EntityScenario; "Entity Type", "Scenario Code")
        {
        }
    }

    trigger OnInsert()
    begin
        "Last Modified DateTime" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime();
    end;

    /// <summary>
    /// Gets the system text from the blob field.
    /// </summary>
    /// <returns>The system text as a string.</returns>
    procedure GetSystemText(): Text
    var
        InStream: InStream;
        SystemText: Text;
    begin
        CalcFields("System Text");
        if not "System Text".HasValue() then
            exit('');

        "System Text".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(SystemText);
        exit(SystemText);
    end;

    /// <summary>
    /// Sets the system text in the blob field.
    /// </summary>
    /// <param name="SystemText">The system text to store.</param>
    procedure SetSystemText(SystemText: Text)
    var
        OutStream: OutStream;
    begin
        Clear("System Text");
        "System Text".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(SystemText);
    end;

    /// <summary>
    /// Gets the template text from the blob field.
    /// </summary>
    /// <returns>The template text as a string.</returns>
    procedure GetTemplateText(): Text
    var
        InStream: InStream;
        TemplateText: Text;
    begin
        CalcFields("Template Text");
        if not "Template Text".HasValue() then
            exit('');

        "Template Text".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(TemplateText);
        exit(TemplateText);
    end;

    /// <summary>
    /// Sets the template text in the blob field.
    /// </summary>
    /// <param name="TemplateText">The template text to store.</param>
    procedure SetTemplateText(TemplateText: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Template Text");
        "Template Text".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(TemplateText);
    end;

    /// <summary>
    /// Gets the tools JSON from the blob field.
    /// </summary>
    /// <returns>The tools JSON as a string.</returns>
    procedure GetToolsJson(): Text
    var
        InStream: InStream;
        ToolsJson: Text;
    begin
        CalcFields("Tools Json");
        if not "Tools Json".HasValue() then
            exit('');

        "Tools Json".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(ToolsJson);
        exit(ToolsJson);
    end;

    /// <summary>
    /// Sets the tools JSON in the blob field.
    /// </summary>
    /// <param name="ToolsJson">The tools JSON to store.</param>
    procedure SetToolsJson(ToolsJson: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Tools Json");
        "Tools Json".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(ToolsJson);
    end;

    /// <summary>
    /// Gets the output schema from the blob field.
    /// </summary>
    /// <returns>The output schema as a string.</returns>
    procedure GetOutputSchema(): Text
    var
        InStream: InStream;
        OutputSchema: Text;
    begin
        CalcFields("Output Schema");
        if not "Output Schema".HasValue() then
            exit('');

        "Output Schema".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(OutputSchema);
        exit(OutputSchema);
    end;

    /// <summary>
    /// Sets the output schema in the blob field.
    /// </summary>
    /// <param name="OutputSchema">The output schema to store.</param>
    procedure SetOutputSchema(OutputSchema: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Output Schema");
        "Output Schema".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(OutputSchema);
    end;

    /// <summary>
    /// Gets the variables JSON from the blob field.
    /// </summary>
    /// <returns>The variables JSON as a string.</returns>
    procedure GetVariables(): Text
    var
        InStream: InStream;
        VariablesText: Text;
    begin
        CalcFields(Variables);
        if not Variables.HasValue() then
            exit('');

        Variables.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(VariablesText);
        exit(VariablesText);
    end;

    /// <summary>
    /// Sets the variables JSON in the blob field.
    /// </summary>
    /// <param name="VariablesJson">The variables JSON to store.</param>
    procedure SetVariables(VariablesJson: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Variables);
        Variables.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(VariablesJson);
    end;
}
