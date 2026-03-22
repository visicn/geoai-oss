/// <summary>
/// Codeunit GeoAI Map URL Formatter (ID 70020).
/// Formats coordinates into map URLs based on the configured map provider.
/// </summary>
codeunit 70020 "GeoAI Map URL Formatter"
{
    /// <summary>
    /// Opens a map in the browser for the given coordinates using the configured provider.
    /// </summary>
    /// <param name="Latitude">Latitude coordinate.</param>
    /// <param name="Longitude">Longitude coordinate.</param>
    procedure OpenMapForCoordinates(Latitude: Decimal; Longitude: Decimal)
    var
        MapUrl: Text;
        NoCoordinatesMsg: Label 'No coordinates available. Please geocode the address first.';
    begin
        if (Latitude = 0) and (Longitude = 0) then begin
            Message(NoCoordinatesMsg);
            exit;
        end;

        MapUrl := FormatCoordinatesForMap(Latitude, Longitude);
        Hyperlink(MapUrl);
    end;

    /// <summary>
    /// Formats coordinates into a map URL based on the configured provider.
    /// </summary>
    /// <param name="Latitude">Latitude coordinate.</param>
    /// <param name="Longitude">Longitude coordinate.</param>
    /// <returns>Map URL string.</returns>
    procedure FormatCoordinatesForMap(Latitude: Decimal; Longitude: Decimal): Text
    var
        Setup: Record "GeoAI Setup";
        Provider: Enum "GeoAI Map Provider";
    begin
        Setup := Setup.GetInstance();
        Provider := Setup."Map Provider";

        case Provider of
            Provider::Google:
                exit(FormatGoogleMapsUrl(Latitude, Longitude));
            Provider::Azure:
                exit(FormatAzureMapsUrl(Latitude, Longitude));
            else
                exit(FormatGoogleMapsUrl(Latitude, Longitude));
        end;
    end;

    local procedure FormatGoogleMapsUrl(Latitude: Decimal; Longitude: Decimal): Text
    var
        Setup: Record "GeoAI Setup";
        BaseUrl: Text;
        MapUrl: Text;
        DefaultGoogleMapsUrlLbl: Label 'https://www.google.com/maps?q=%1,%2', Comment = '%1 = Latitude, %2 = Longitude', Locked = true;
    begin
        Setup := Setup.GetInstance();

        if Setup."Map View URL" <> '' then begin
            BaseUrl := Setup."Map View URL";
            BaseUrl := BaseUrl.TrimEnd('/').TrimEnd('?');
            MapUrl := BaseUrl + '?q=' + Format(Latitude, 0, 9) + ',' + Format(Longitude, 0, 9);
            exit(MapUrl);
        end;

        exit(StrSubstNo(DefaultGoogleMapsUrlLbl,
            Format(Latitude, 0, 9),
            Format(Longitude, 0, 9)));
    end;

    local procedure FormatAzureMapsUrl(Latitude: Decimal; Longitude: Decimal): Text
    var
        Setup: Record "GeoAI Setup";
        BaseUrl: Text;
        MapUrl: Text;
        DefaultAzureMapsUrlLbl: Label 'https://www.bing.com/maps?cp=%1~%2&lvl=16', Comment = '%1 = Latitude, %2 = Longitude', Locked = true;
    begin
        Setup := Setup.GetInstance();

        if Setup."Map View URL" <> '' then begin
            BaseUrl := Setup."Map View URL";
            BaseUrl := BaseUrl.TrimEnd('/').TrimEnd('?');
            MapUrl := BaseUrl + '?cp=' + Format(Latitude, 0, 9) + '~' + Format(Longitude, 0, 9) + '&lvl=16';
            exit(MapUrl);
        end;

        // Azure Maps uses Bing Maps for the web interface
        exit(StrSubstNo(DefaultAzureMapsUrlLbl,
            Format(Latitude, 0, 9),
            Format(Longitude, 0, 9)));
    end;
}
