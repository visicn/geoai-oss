/// <summary>
/// Page GeoAI Text Editor (ID 70120).
/// Simple text editor dialog for viewing/editing large text fields.
/// </summary>
page 70120 "GeoAI Text Editor"
{
    PageType = StandardDialog;
    Caption = 'Text Editor';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(TextContent; TextContent)
            {
                ApplicationArea = All;
                Caption = 'Content';
                ToolTip = 'The text content to view or edit.';
                MultiLine = true;
                ShowCaption = false;
                Editable = not IsReadOnly;
            }
        }
    }

    var
        TextContent: Text;
        IsReadOnly: Boolean;

    /// <summary>
    /// Sets the text content to display in the editor.
    /// </summary>
    /// <param name="Value">The text value to display.</param>
    procedure SetText(Value: Text)
    begin
        TextContent := Value;
    end;

    /// <summary>
    /// Gets the text content from the editor.
    /// </summary>
    /// <returns>The current text value.</returns>
    procedure GetText(): Text
    begin
        exit(TextContent);
    end;

    /// <summary>
    /// Sets whether the editor should be read-only.
    /// </summary>
    /// <param name="ReadOnly">True to make the editor read-only, false to allow editing.</param>
    procedure SetReadOnly(ReadOnly: Boolean)
    begin
        IsReadOnly := ReadOnly;
    end;
}
