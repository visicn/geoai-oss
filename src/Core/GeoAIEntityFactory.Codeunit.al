/// <summary>
/// Codeunit GeoAI Entity Factory (ID 70031).
/// Factory pattern for creating entity-specific GeoAI providers.
/// Routes entity operations to appropriate implementation based on Entity Type enum.
/// OSS version supports Customer and Vendor entities only.
/// </summary>
codeunit 70031 "GeoAI Entity Factory"
{
    /// <summary>
    /// Gets the appropriate entity provider implementation for the given entity type.
    /// </summary>
    /// <param name="EntityType">The entity type enum value.</param>
    /// <returns>IGeoAIEntity interface implementation.</returns>
    /// <error>Error if entity type is not supported or blank.</error>
    procedure GetEntityProvider(EntityType: Enum "GeoAI Entity Type"): Interface "IGeoAI Entity"
    var
        UnsupportedEntityErr: Label 'Entity type %1 is not supported for GeoAI operations in the OSS version. Only Customer and Vendor are supported.', Comment = '%1 = Entity Type';
    begin
        case EntityType of
            EntityType::Customer:
                exit(GetCustomerProvider());
            EntityType::Vendor:
                exit(GetVendorProvider());
            else
                Error(UnsupportedEntityErr, EntityType);
        end;
    end;

    /// <summary>
    /// Validates if the entity type is supported for GeoAI operations.
    /// </summary>
    /// <param name="EntityType">The entity type to check.</param>
    /// <returns>True if supported, false otherwise.</returns>
    procedure IsEntityTypeSupported(EntityType: Enum "GeoAI Entity Type"): Boolean
    begin
        exit(EntityType in [
          EntityType::Customer,
          EntityType::Vendor
        ]);
    end;

    local procedure GetCustomerProvider(): Interface "IGeoAI Entity"
    var
        Provider: Codeunit "Customer Geo Provider";
    begin
        exit(Provider);
    end;

    local procedure GetVendorProvider(): Interface "IGeoAI Entity"
    var
        Provider: Codeunit "Vendor Geo Provider";
    begin
        exit(Provider);
    end;
}
