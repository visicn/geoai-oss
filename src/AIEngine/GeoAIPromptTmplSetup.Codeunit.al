/// <summary>
/// Codeunit GeoAI Prompt Template Setup (ID 70040).
/// Initializes and maintains the 18 standard GeoAI prompt templates.
/// Organized by entity type (2) and category (9 templates per entity).
/// Categories: Proximity and Search (3), Routing and Planning (3), Analytics and Insights (3).
/// </summary>
codeunit 70040 "GeoAI Prompt Tmpl Setup"
{
    /// <summary>
    /// Initializes all 18 standard templates (9 per entity × 2 entities).
    /// Safe to call multiple times - only creates missing templates.
    /// </summary>
    procedure InitializeTemplates()
    begin
        InitializeCustomerTemplates();
        InitializeVendorTemplates();
    end;

    local procedure InitializeCustomerTemplates()
    var
        EntityType: Enum "GeoAI Entity Type";
    begin
        EntityType := EntityType::Customer;

        CreateTemplate('CUST-NEARBY', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Nearby Customers',
            'Locate customers within a specified radius of a location',
            'You are a sales territory analyst. Help identify customers near a specific location for territory planning.',
            'Find customers within {{RadiusKm}} km of {{SourceName}}. Return results sorted by distance.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-CLOSEST', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Closest Customer',
            'Identify the single closest customer to a location',
            'You are a logistics coordinator. Help identify the nearest customer to optimize delivery routes.',
            'Find the closest customer to {{SourceName}}. Return only the nearest match with distance.',
            '{"MaxResults":"int"}');

        CreateTemplate('CUST-REGION', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Customers in Region',
            'List all customers within a geographic region',
            'You are a regional sales manager. Help identify all customers in your territory.',
            'List all customers in the region around {{SourceName}} within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-NEARBY', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::FindNearby, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-CLOSEST', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::Vendor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::FindNearest, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-REGION', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::SearchInRegion, "GeoAI Template Scope"::Region);

        CreateTemplate('CUST-NEARBY-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Nearby Customers (Extended)',
            'Locate nearby customers with grouping and relevance explanation',
            'You are a sales territory analyst. Help identify customers near a specific location and explain their relevance.',
            'Find customers within {{RadiusKm}} km of {{SourceName}}. Group results by proximity and explain relevance for each.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-CLOSEST-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Closest Customer (Extended)',
            'Identify closest customer with detailed distance analysis',
            'You are a logistics coordinator. Help identify the nearest customer and provide detailed distance insights.',
            'Find the closest customer to {{SourceName}}. Include travel time estimates and suggest visit scheduling.',
            '{"MaxResults":"int"}');

        CreateTemplate('CUST-REGION-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Customers in Region (Extended)',
            'List regional customers with territory insights',
            'You are a regional sales manager. Help identify all customers in your territory with strategic insights.',
            'List all customers in the region around {{SourceName}} within {{RadiusKm}} km. Suggest territory optimization.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-NEARBY-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::SearchInRegion, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-CLOSEST-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::Vendor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::ScheduleVisits, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-REGION-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::TerritoryPlanning, "GeoAI Template Scope"::Region);

        CreateTemplate('CUST-ROUTE', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Plan Customer Visit Route',
            'Optimize a route to visit multiple customers',
            'You are a field service planner. Help create efficient routes for customer visits.',
            'Plan an efficient route starting from {{SourceName}} to visit nearby customers within {{RadiusKm}} km. Optimize for shortest total distance.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-COVERAGE', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Analyze Territory Coverage',
            'Identify gaps in customer coverage within a territory',
            'You are a territory analyst. Help identify underserved areas.',
            'Analyze customer distribution around {{SourceName}} within {{RadiusKm}} km. Identify coverage gaps.',
            '{"RadiusKm":"int"}');

        CreateTemplate('CUST-CLUSTER', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Find Customer Clusters',
            'Identify geographic clusters of customers',
            'You are a sales operations analyst. Help identify customer concentrations for territory design.',
            'Identify clusters of customers near {{SourceName}}. Group customers within {{RadiusKm}} km into geographic clusters.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-ROUTE', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::PlanRoute, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-COVERAGE', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Coverage, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('CUST-CLUSTER', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Cluster, "GeoAI Template Scope"::Region);

        CreateTemplate('CUST-ROUTE-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Plan Customer Visit Route (Extended)',
            'Optimize route with visit scheduling suggestions',
            'You are a field service planner. Help create efficient routes with scheduling recommendations.',
            'Plan an efficient route starting from {{SourceName}} to visit nearby customers within {{RadiusKm}} km. Suggest visit times and priorities.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-COVERAGE-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Analyze Territory Coverage (Extended)',
            'Identify coverage gaps with expansion recommendations',
            'You are a territory analyst. Help identify underserved areas and suggest expansion strategies.',
            'Analyze customer distribution around {{SourceName}} within {{RadiusKm}} km. Identify coverage gaps and recommend actions.',
            '{"RadiusKm":"int"}');

        CreateTemplate('CUST-CLUSTER-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Find Customer Clusters (Extended)',
            'Identify clusters with territory assignment suggestions',
            'You are a sales operations analyst. Help identify customer concentrations and suggest territory boundaries.',
            'Identify clusters of customers near {{SourceName}}. Group customers within {{RadiusKm}} km and suggest territory assignments.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-ROUTE-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::ScheduleVisits, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-COVERAGE-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Expansion, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('CUST-CLUSTER-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::TerritoryPlanning, "GeoAI Template Scope"::Region);

        CreateTemplate('CUST-DENSITY', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Customer Density Analysis',
            'Analyze customer concentration in an area',
            'You are a market analyst. Help understand customer distribution patterns.',
            'Analyze customer density around {{SourceName}} within {{RadiusKm}} km. Provide insights on concentration patterns.',
            '{"RadiusKm":"int"}');

        CreateTemplate('CUST-OPPORTUNITY', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Identify Sales Opportunities',
            'Find customers for cross-selling or expansion',
            'You are a sales strategist. Help identify opportunities based on proximity.',
            'Identify sales opportunities among customers near {{SourceName}}. Consider customers within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-COMPETE', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Competitive Analysis',
            'Analyze customer proximity to competitors or vendors',
            'You are a competitive intelligence analyst. Help understand market positioning.',
            'Analyze customers near {{SourceName}} in relation to nearby vendors or competitors within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-DENSITY', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Coverage, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('CUST-OPPORTUNITY', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Expansion, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-COMPETE', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::Vendor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Coverage, "GeoAI Template Scope"::Region);

        CreateTemplate('CUST-DENSITY-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Customer Density Analysis (Extended)',
            'Analyze density with cluster identification',
            'You are a market analyst. Help understand customer distribution patterns and identify clusters.',
            'Analyze customer density around {{SourceName}} within {{RadiusKm}} km. Identify clusters and suggest focus areas.',
            '{"RadiusKm":"int"}');

        CreateTemplate('CUST-OPPORTUNITY-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Identify Sales Opportunities (Extended)',
            'Find opportunities with actionable recommendations',
            'You are a sales strategist. Help identify opportunities and suggest specific actions.',
            'Identify sales opportunities among customers near {{SourceName}} within {{RadiusKm}} km. Provide actionable recommendations.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('CUST-COMPETE-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Competitive Analysis (Extended)',
            'Analyze competitive positioning with strategic insights',
            'You are a competitive intelligence analyst. Help understand market positioning and suggest strategies.',
            'Analyze customers near {{SourceName}} in relation to nearby vendors within {{RadiusKm}} km. Suggest competitive strategies.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('CUST-DENSITY-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Cluster, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('CUST-OPPORTUNITY-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::FindNearby, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('CUST-COMPETE-ALT', "GeoAI Anchor Entity"::Customer, "GeoAI Target Entity"::Vendor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Expansion, "GeoAI Template Scope"::Region);
    end;

    local procedure InitializeVendorTemplates()
    var
        EntityType: Enum "GeoAI Entity Type";
    begin
        EntityType := EntityType::Vendor;

        CreateTemplate('VEND-NEARBY', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Nearby Vendors',
            'Locate vendors within a specified radius',
            'You are a procurement specialist. Help identify vendors near a specific location.',
            'Find vendors within {{RadiusKm}} km of {{SourceName}}. Return results sorted by distance.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-CLOSEST', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Closest Vendor',
            'Identify the nearest vendor to a location',
            'You are a supply chain coordinator. Help identify the nearest vendor for urgent procurement.',
            'Find the closest vendor to {{SourceName}}. Return only the nearest match with distance.',
            '{"MaxResults":"int"}');

        CreateTemplate('VEND-REGION', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Vendors in Region',
            'List all vendors within a geographic region',
            'You are a supplier relationship manager. Help identify all vendors in a region.',
            'List all vendors in the region around {{SourceName}} within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-NEARBY', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::FindNearby, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-CLOSEST', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::Customer,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::FindNearest, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-REGION', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::SearchInRegion, "GeoAI Template Scope"::Region);

        CreateTemplate('VEND-NEARBY-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Nearby Vendors (Extended)',
            'Locate nearby vendors with capability assessment',
            'You are a procurement specialist. Help identify vendors near a specific location and assess their capabilities.',
            'Find vendors within {{RadiusKm}} km of {{SourceName}}. Group by proximity and explain relevance for procurement.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-CLOSEST-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Find Closest Vendor (Extended)',
            'Identify closest vendor with delivery time estimates',
            'You are a supply chain coordinator. Help identify the nearest vendor with delivery insights.',
            'Find the closest vendor to {{SourceName}}. Include estimated delivery times and suggest scheduling.',
            '{"MaxResults":"int"}');

        CreateTemplate('VEND-REGION-ALT', EntityType, "GeoAI Scenario"::ProximitySearch,
            'Vendors in Region (Extended)',
            'List regional vendors with sourcing recommendations',
            'You are a supplier relationship manager. Help identify all vendors in a region with sourcing insights.',
            'List all vendors in the region around {{SourceName}} within {{RadiusKm}} km. Suggest sourcing strategies.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-NEARBY-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::SearchInRegion, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-CLOSEST-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::Customer,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::ScheduleVisits, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-REGION-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::ProximitySearch, "GeoAI Template Intent"::TerritoryPlanning, "GeoAI Template Scope"::Region);

        CreateTemplate('VEND-ROUTE', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Plan Vendor Visit Route',
            'Optimize a route to visit multiple vendors',
            'You are a procurement manager. Help plan efficient vendor site visits.',
            'Plan an efficient route starting from {{SourceName}} to visit nearby vendors within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-NETWORK', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Analyze Supplier Network',
            'Evaluate supplier geographic distribution',
            'You are a supply chain strategist. Help analyze supplier network coverage.',
            'Analyze vendor distribution around {{SourceName}} within {{RadiusKm}} km. Evaluate network coverage.',
            '{"RadiusKm":"int"}');

        CreateTemplate('VEND-CLUSTER', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Find Vendor Clusters',
            'Identify geographic clusters of vendors',
            'You are a sourcing analyst. Help identify vendor concentrations.',
            'Identify clusters of vendors near {{SourceName}}. Group vendors within {{RadiusKm}} km.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-ROUTE', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::PlanRoute, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-NETWORK', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Coverage, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('VEND-CLUSTER', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Cluster, "GeoAI Template Scope"::Region);

        CreateTemplate('VEND-ROUTE-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Plan Vendor Visit Route (Extended)',
            'Optimize route with visit scheduling suggestions',
            'You are a procurement manager. Help plan efficient vendor site visits with scheduling.',
            'Plan an efficient route starting from {{SourceName}} to visit nearby vendors within {{RadiusKm}} km. Suggest visit priorities.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-NETWORK-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Analyze Supplier Network (Extended)',
            'Evaluate network with expansion recommendations',
            'You are a supply chain strategist. Help analyze supplier network and suggest improvements.',
            'Analyze vendor distribution around {{SourceName}} within {{RadiusKm}} km. Recommend network expansion areas.',
            '{"RadiusKm":"int"}');

        CreateTemplate('VEND-CLUSTER-ALT', EntityType, "GeoAI Scenario"::RoutingPlanning,
            'Find Vendor Clusters (Extended)',
            'Identify clusters with sourcing zone suggestions',
            'You are a sourcing analyst. Help identify vendor concentrations and suggest sourcing zones.',
            'Identify clusters of vendors near {{SourceName}}. Group vendors within {{RadiusKm}} km and suggest sourcing zones.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-ROUTE-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::ScheduleVisits, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-NETWORK-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::Expansion, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('VEND-CLUSTER-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::RoutingPlanning, "GeoAI Template Intent"::TerritoryPlanning, "GeoAI Template Scope"::Region);

        CreateTemplate('VEND-RISK', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Supply Chain Risk Analysis',
            'Analyze vendor concentration risks',
            'You are a supply chain risk analyst. Help identify geographic concentration risks.',
            'Analyze vendor concentration around {{SourceName}} within {{RadiusKm}} km. Identify potential risks.',
            '{"RadiusKm":"int"}');

        CreateTemplate('VEND-ALTERNATE', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Find Alternative Suppliers',
            'Identify backup vendors in an area',
            'You are a continuity planner. Help identify alternative vendors for business continuity.',
            'Identify alternative vendors near {{SourceName}} within {{RadiusKm}} km for supply redundancy.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-OPTIMIZE', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Optimize Vendor Selection',
            'Recommend optimal vendors based on proximity',
            'You are a procurement optimization specialist. Help select optimal vendors.',
            'Recommend optimal vendors near {{SourceName}} within {{RadiusKm}} km based on proximity and coverage.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-RISK', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Coverage, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('VEND-ALTERNATE', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::FindNearby, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-OPTIMIZE', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Expansion, "GeoAI Template Scope"::Self);

        CreateTemplate('VEND-RISK-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Supply Chain Risk Analysis (Extended)',
            'Analyze risks with mitigation recommendations',
            'You are a supply chain risk analyst. Help identify risks and suggest mitigation strategies.',
            'Analyze vendor concentration around {{SourceName}} within {{RadiusKm}} km. Identify risks and recommend mitigations.',
            '{"RadiusKm":"int"}');

        CreateTemplate('VEND-ALTERNATE-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Find Alternative Suppliers (Extended)',
            'Identify alternatives with capability comparison',
            'You are a continuity planner. Help identify alternative vendors and compare capabilities.',
            'Identify alternative vendors near {{SourceName}} within {{RadiusKm}} km. Compare capabilities for redundancy planning.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        CreateTemplate('VEND-OPTIMIZE-ALT', EntityType, "GeoAI Scenario"::AnalyticsInsights,
            'Optimize Vendor Selection (Extended)',
            'Recommend vendors with clustering insights',
            'You are a procurement optimization specialist. Help select vendors and identify clusters.',
            'Recommend optimal vendors near {{SourceName}} within {{RadiusKm}} km. Identify vendor clusters for strategic sourcing.',
            '{"RadiusKm":"int","MaxResults":"int"}');

        ApplyTemplateTaxonomy('VEND-RISK-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Cluster, "GeoAI Template Scope"::Region);
        ApplyTemplateTaxonomy('VEND-ALTERNATE-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::SearchInRegion, "GeoAI Template Scope"::Self);
        ApplyTemplateTaxonomy('VEND-OPTIMIZE-ALT', "GeoAI Anchor Entity"::Vendor, "GeoAI Target Entity"::SameAsAnchor,
            "GeoAI Template Category"::AnalyticsInsights, "GeoAI Template Intent"::Cluster, "GeoAI Template Scope"::Self);
    end;

    local procedure CreateTemplate(Code: Code[50]; EntityType: Enum "GeoAI Entity Type"; Scenario: Enum "GeoAI Scenario"; Title: Text[100]; Description: Text[250]; SystemText: Text; TemplateText: Text; VariablesJson: Text)
    var
        PromptTemplate: Record "GeoAI Prompt Template";
    begin
        if PromptTemplate.Get(Code) then
            exit;

        PromptTemplate.Init();
        PromptTemplate.Code := Code;
        PromptTemplate."Entity Type" := EntityType;
        PromptTemplate."Scenario Code" := Scenario;
        PromptTemplate.Title := Title;
        PromptTemplate.Description := Description;
        PromptTemplate.SetSystemText(SystemText);
        PromptTemplate.SetTemplateText(TemplateText);
        PromptTemplate.SetVariables(VariablesJson);
        PromptTemplate.Enabled := true;
        PromptTemplate.Version := '1.0';
        PromptTemplate."Default Radius (km)" := 100;
        PromptTemplate."Max Results" := 20;
        PromptTemplate.Insert(true);
    end;

    local procedure ApplyTemplateTaxonomy(TemplateCode: Code[50]; AnchorEntity: Enum "GeoAI Anchor Entity"; TargetEntity: Enum "GeoAI Target Entity"; Category: Enum "GeoAI Template Category"; Intent: Enum "GeoAI Template Intent"; Scope: Enum "GeoAI Template Scope")
    var
        PromptTemplate: Record "GeoAI Prompt Template";
    begin
        if not PromptTemplate.Get(TemplateCode) then
            exit;

        PromptTemplate."Anchor Entity" := AnchorEntity;
        PromptTemplate."Target Entity" := TargetEntity;
        PromptTemplate.Category := Category;
        PromptTemplate.Intent := Intent;
        PromptTemplate.Scope := Scope;
        PromptTemplate.Modify(true);
    end;
}
