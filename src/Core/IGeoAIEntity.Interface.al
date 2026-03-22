/// <summary>
/// Interface IGeoAI Entity (ID 70060).
/// Abstraction for entities that support GeoAI operations.
/// Enables unified prompt handling across Customer, Vendor, Contact, Employee, Resource, Job, Location, and BankAccount.
/// </summary>
interface "IGeoAI Entity"
{
    /// <summary>
    /// Gets location context for a specific record.
    /// </summary>
    /// <param name="RecId">Record ID of the entity.</param>
    /// <returns>JsonObject with id, name, lat, lon, country, geohash, address.</returns>
    procedure GetLocationContext(RecId: RecordId): JsonObject;

    /// <summary>
    /// Gets nearby candidates within radius, sorted by distance.
    /// Candidates are prefiltered using bounding box and geocode status.
    /// Returns deterministic results with distances pre-computed using Haversine formula.
    /// </summary>
    /// <param name="AnchorLat">Anchor latitude for proximity search.</param>
    /// <param name="AnchorLon">Anchor longitude for proximity search.</param>
    /// <param name="RadiusKm">Search radius in kilometers.</param>
    /// <param name="MaxResults">Maximum results to return (cap: 200).</param>
    /// <returns>JsonArray of candidates with id, name, lat, lon, distanceKm.</returns>
    procedure GetNearbyCandidates(AnchorLat: Decimal; AnchorLon: Decimal; RadiusKm: Decimal; MaxResults: Integer): JsonArray;

    /// <summary>
    /// Gets the entity type enum value.
    /// </summary>
    /// <returns>Entity type enum for this provider.</returns>
    procedure GetEntityType(): Enum "GeoAI Entity Type";

    /// <summary>
    /// Validates if entity record has valid geocoding data.
    /// Checks if geocode status is Success and coordinates are non-zero.
    /// </summary>
    /// <param name="RecId">Record ID to validate.</param>
    /// <returns>True if entity has valid geocoding, false otherwise.</returns>
    procedure ValidateGeocodingStatus(RecId: RecordId): Boolean;
}
