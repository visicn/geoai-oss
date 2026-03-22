/// <summary>
/// PermissionSet GeoAI OSS (ID 70105).
/// Grants full access to all GeoAI objects including tables, pages, and codeunits.
/// </summary>
/// 
permissionset 70105 "GeoAI OSS"
{
    Caption = 'GeoAI OSS';
    Assignable = true;
    Access = Public;

    Permissions =
        // Tables
        tabledata "GeoAI Setup" = RIMD,
        tabledata "GeoAI Prompt Template" = RIMD,
        tabledata "GeoAI Geocode Cache" = RIMD,
        tabledata "GeoAI Result Item" = RIMD,

        // Pages
        page "GeoAI Setup" = X,
        page "GeoAI Prompt Templates" = X,
        page "GeoAI Prompt Template" = X,
        page "GeoAI Text Editor" = X,
        page "GeoAI Prompt" = X,
        page "GeoAI Result Items" = X,
        page "GeoAI Prompt Guide" = X,
        page "GeoAI Template Picker" = X,

        // Codeunits
        codeunit "GeoAI Map URL Formatter" = X,
        codeunit "GeoAI Service (AOAI)" = X,
        codeunit "GeoAI Candidate Filter" = X,
        codeunit "GeoAI Entity Factory" = X,
        codeunit "Customer Geo Provider" = X,
        codeunit "Vendor Geo Provider" = X,
        codeunit "GeoAI Prompt Tmpl Setup" = X,
        codeunit "GeoLocation Mgmt" = X,
        codeunit "GeoAI HTTP Client" = X,
        codeunit "GeoAI Prompt Engine" = X,
        codeunit "GeoAI Client" = X,
        codeunit "GeoAI Auto Geocode Sub" = X,
        codeunit "GeoAI Cache Purge" = X,
        codeunit "GeoAI Template Selector" = X,
        codeunit "GeoAI Prompt Launcher" = X,
        codeunit "GeoAI Response Constraints" = X,
        codeunit "GeoAI Install" = X,
        codeunit "GeoAI Upgrade" = X;
}
