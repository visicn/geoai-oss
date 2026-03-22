/// <summary>
/// Codeunit GeoAI Response Constraints (ID 70104).
/// Implements response constraints to prevent AI hallucination and enforce proper entity grounding.
/// Supports two modes: Entity-Grounded (strict BC data) and General GeoAI (open assistance).
/// </summary>
codeunit 70104 "GeoAI Response Constraints"
{
    /// <summary>
    /// Determines if the request is entity-grounded (Mode A) or general GeoAI (Mode B).
    /// Mode A requires BOTH EntityType selection AND actual entity/anchor data.
    /// EntityType selection alone is NOT sufficient for Mode A.
    /// </summary>
    /// <param name="EntityType">The selected entity type.</param>
    /// <param name="EntityRecordID">The record ID of the anchor entity.</param>
    /// <param name="EntityNo">The entity number.</param>
    /// <param name="CandidateContextJson">The candidate context JSON.</param>
    /// <returns>True if Mode A (Entity-Grounded), False if Mode B (General GeoAI).</returns>
    procedure IsEntityGrounded(EntityType: Enum "GeoAI Entity Type"; EntityRecordID: RecordId; EntityNo: Code[20]; CandidateContextJson: Text): Boolean
    begin
        if EntityType = EntityType::" " then
            exit(false);

        if Format(EntityRecordID) <> '' then
            exit(true);

        if EntityNo <> '' then
            exit(true);

        if (CandidateContextJson <> '') and (CandidateContextJson <> '[]') then
            exit(true);

        exit(false);
    end;

    /// <summary>
    /// Builds the appropriate system prompt based on mode and context.
    /// </summary>
    /// <param name="IsGrounded">True for Mode A (Entity-Grounded), False for Mode B (General).</param>
    /// <param name="HasEntityData">True if entity data is present in request payload.</param>
    /// <returns>The system prompt text.</returns>
    procedure BuildSystemPrompt(IsGrounded: Boolean; HasEntityData: Boolean): Text
    begin
        if IsGrounded then
            exit(BuildEntityGroundedSystemPrompt(HasEntityData))
        else
            exit(BuildGeneralGeoAISystemPrompt());
    end;

    /// <summary>
    /// Builds the system prompt for Mode A (Entity-Grounded/STRICT).
    /// </summary>
    local procedure BuildEntityGroundedSystemPrompt(HasEntityData: Boolean): Text
    var
        PromptBuilder: TextBuilder;
        NoDataFallbackMsg: Label 'No Business Central entity data was provided in this request. Please inform the user that they must select an entity type or provide entity information to receive Business Central data-based answers.';
    begin
        PromptBuilder.AppendLine('# Role');
        PromptBuilder.AppendLine('You are GeoAI for Microsoft Dynamics 365 Business Central.');
        PromptBuilder.AppendLine('You provide location intelligence and spatial analysis for Business Central entities.');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# CRITICAL RULES - Entity Grounding');
        PromptBuilder.AppendLine('1. You may ONLY reference Business Central entities that are explicitly provided in this request.');
        PromptBuilder.AppendLine('2. You must NOT reuse, recall, or reference entities from previous messages or responses.');
        PromptBuilder.AppendLine('3. You must NOT infer, guess, or invent entity data that was not explicitly provided.');
        PromptBuilder.AppendLine('4. You must NOT claim to have access to Business Central data unless entities are provided in the request.');
        PromptBuilder.AppendLine('5. If the entity list is empty or missing, you must respond with the following message ONLY:');
        PromptBuilder.AppendLine('   "' + NoDataFallbackMsg + '"');
        PromptBuilder.AppendLine('6. Ignore any entities mentioned in previous conversation history; only use entities in THIS request.');
        PromptBuilder.AppendLine('');

        if not HasEntityData then begin
            PromptBuilder.AppendLine('# WARNING - NO ENTITY DATA PROVIDED');
            PromptBuilder.AppendLine('The current request contains NO Business Central entity data.');
            PromptBuilder.AppendLine('You must respond with the no-data message specified above.');
            PromptBuilder.AppendLine('Do NOT attempt to answer the business question.');
            PromptBuilder.AppendLine('');
        end;

        PromptBuilder.AppendLine('# Address Context Handling');
        PromptBuilder.AppendLine('- Use address fields (Country, Region, City, Postal Code, Street) when provided');
        PromptBuilder.AppendLine('- Respect country boundaries - do NOT suggest entities from different countries unless explicitly requested');
        PromptBuilder.AppendLine('- Consider region/state for large countries to improve relevance');
        PromptBuilder.AppendLine('- Use postal code proximity when available');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# Output Requirements');
        PromptBuilder.AppendLine('Always respond with a single JSON object and nothing else (no text before or after the JSON, no ```json``` fences).');
        PromptBuilder.AppendLine('The JSON must follow exactly this schema:');
        PromptBuilder.AppendLine('{');
        PromptBuilder.AppendLine('  "version": "2",');
        PromptBuilder.AppendLine('  "answer_markdown": "user-friendly summary text",');
        PromptBuilder.AppendLine('  "items": [');
        PromptBuilder.AppendLine('    {');
        PromptBuilder.AppendLine('      "id": "string",');
        PromptBuilder.AppendLine('      "name": "string",');
        PromptBuilder.AppendLine('      "description": "string",');
        PromptBuilder.AppendLine('      "lat": number,');
        PromptBuilder.AppendLine('      "lon": number,');
        PromptBuilder.AppendLine('      "distanceKm": number,');
        PromptBuilder.AppendLine('      "etaMinutes": number,');
        PromptBuilder.AppendLine('      "score": number');
        PromptBuilder.AppendLine('    }');
        PromptBuilder.AppendLine('  ],');
        PromptBuilder.AppendLine('  "tables": [');
        PromptBuilder.AppendLine('    {');
        PromptBuilder.AppendLine('      "name": "string",');
        PromptBuilder.AppendLine('      "columns": ["array", "of", "strings"],');
        PromptBuilder.AppendLine('      "rows": [["array", "of", "values"]]');
        PromptBuilder.AppendLine('    }');
        PromptBuilder.AppendLine('  ],');
        PromptBuilder.AppendLine('  "routes": [');
        PromptBuilder.AppendLine('    {');
        PromptBuilder.AppendLine('      "fromId": "string",');
        PromptBuilder.AppendLine('      "toId": "string",');
        PromptBuilder.AppendLine('      "polyline": "string"');
        PromptBuilder.AppendLine('    }');
        PromptBuilder.AppendLine('  ],');
        PromptBuilder.AppendLine('  "hints": {');
        PromptBuilder.AppendLine('    "map": boolean,');
        PromptBuilder.AppendLine('    "table": boolean');
        PromptBuilder.AppendLine('  }');
        PromptBuilder.AppendLine('}');
        PromptBuilder.AppendLine('');
        PromptBuilder.AppendLine('# Formatting Guidelines');
        PromptBuilder.AppendLine('## For answer_markdown field ONLY:');
        PromptBuilder.AppendLine('- Use plain text with simple formatting');
        PromptBuilder.AppendLine('- Use newline characters (\n) for line breaks, NOT HTML tags like <br/>');
        PromptBuilder.AppendLine('- Do NOT use markdown bold (**text**), italic (*text*), or other markdown syntax');
        PromptBuilder.AppendLine('- Use simple numbered lists (1. 2. 3.) or bullet points (-)');
        PromptBuilder.AppendLine('');
        PromptBuilder.AppendLine('## For items array - REQUIRED fields:');
        PromptBuilder.AppendLine('- etaMinutes: Must be a number (estimate travel time in minutes based on distance)');
        PromptBuilder.AppendLine('- score: Must be a number between 0 and 1 (relevance score, use distance-based scoring)');
        PromptBuilder.AppendLine('- NEVER use null for etaMinutes or score - always provide numeric values');
        PromptBuilder.AppendLine('- Calculate etaMinutes approximately as: distanceKm * 1.2 minutes (average driving speed)');
        PromptBuilder.AppendLine('- Calculate score approximately as: 1 - (distanceKm / maxDistanceInSet) for relevance ranking');
        PromptBuilder.AppendLine('');
        PromptBuilder.AppendLine('Put the human-friendly explanation in answer_markdown and the structured data into items / tables / routes / hints.');
        PromptBuilder.AppendLine('Latitude and longitude must be numeric coordinates whenever they are available.');

        exit(PromptBuilder.ToText());
    end;

    /// <summary>
    /// Builds the system prompt for Mode B (General GeoAI/OPEN).
    /// </summary>
    local procedure BuildGeneralGeoAISystemPrompt(): Text
    var
        PromptBuilder: TextBuilder;
    begin
        PromptBuilder.AppendLine('# Role');
        PromptBuilder.AppendLine('You are GeoAI, a general geographic and spatial analysis assistant.');
        PromptBuilder.AppendLine('You provide conceptual guidance, explanations, and instructional answers about geographic concepts, routing, and location intelligence.');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# CRITICAL RULES - General Assistance Mode');
        PromptBuilder.AppendLine('1. You do NOT have access to Business Central data unless explicitly provided in the request.');
        PromptBuilder.AppendLine('2. You must NOT mention or reference specific customers, vendors, locations, or other BC entities.');
        PromptBuilder.AppendLine('3. You must NOT claim to have BC entity data or attempt to query BC databases.');
        PromptBuilder.AppendLine('4. You provide CONCEPTUAL and INSTRUCTIONAL answers only.');
        PromptBuilder.AppendLine('5. If the user asks for BC-specific data (e.g., "closest customer"), instruct them to:');
        PromptBuilder.AppendLine('   - Select an entity type from the filters');
        PromptBuilder.AppendLine('   - Provide an entity number or name');
        PromptBuilder.AppendLine('   - Use the entity-specific features');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# What You CAN Do');
        PromptBuilder.AppendLine('- Explain how distance calculations work (Haversine formula, great circle distance)');
        PromptBuilder.AppendLine('- Describe routing concepts (shortest path, optimization, waypoints)');
        PromptBuilder.AppendLine('- Provide guidance on ETA estimation factors (traffic, road types, speed limits)');
        PromptBuilder.AppendLine('- Explain geographic concepts (latitude/longitude, geohashing, proximity search)');
        PromptBuilder.AppendLine('- Answer "how-to" questions about spatial analysis in general terms');
        PromptBuilder.AppendLine('- Suggest best practices for location-based business processes');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# What You CANNOT Do');
        PromptBuilder.AppendLine('- Access or query Business Central customer/vendor/location data');
        PromptBuilder.AppendLine('- Provide specific entity recommendations without entity data');
        PromptBuilder.AppendLine('- Calculate actual distances between BC entities (no entity data available)');
        PromptBuilder.AppendLine('- Generate routing plans for BC entities (no entity data available)');
        PromptBuilder.AppendLine('');

        PromptBuilder.AppendLine('# Response Format');
        PromptBuilder.AppendLine('Respond in clear, conversational markdown format.');
        PromptBuilder.AppendLine('Focus on education, explanation, and guidance.');
        PromptBuilder.AppendLine('If the user needs BC data, politely redirect them to select an entity context.');

        exit(PromptBuilder.ToText());
    end;

    /// <summary>
    /// Validates if entity data is present in the request payload.
    /// </summary>
    /// <param name="CandidateContextJson">The candidate context JSON.</param>
    /// <param name="EntityContext">The entity context text.</param>
    /// <returns>True if entity data is present and non-empty.</returns>
    procedure HasEntityDataInPayload(CandidateContextJson: Text; EntityContext: Text): Boolean
    var
        CandidatesArray: JsonArray;
    begin
        if (EntityContext <> '') and (StrLen(EntityContext) > 10) then
            exit(true);

        if CandidateContextJson = '' then
            exit(false);

        if not CandidatesArray.ReadFrom(CandidateContextJson) then
            exit(false);

        if CandidatesArray.Count() = 0 then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Returns a deterministic fallback message when entity context is required but missing.
    /// </summary>
    /// <param name="Context">Context for the fallback (Chat or Prompt).</param>
    /// <returns>The fallback message text.</returns>
    procedure GetEntityRequiredFallbackMessage(Context: Text): Text
    var
        ChatFallbackMsg: Label 'To receive Business Central entity-based answers, please select an Entity Type from the Context & Filters section or provide an entity number/name.';
        PromptFallbackMsg: Label 'Unable to answer. No Business Central entity data was provided. This feature requires entity context to operate.';
    begin
        if Context = 'Chat' then
            exit(ChatFallbackMsg)
        else
            exit(PromptFallbackMsg);
    end;

    /// <summary>
    /// Enriches entity payload with full address context for better AI reasoning.
    /// </summary>
    /// <param name="EntityRecordID">The entity record ID.</param>
    /// <param name="EntityType">The entity type.</param>
    /// <param name="EntityContext">Input/Output: The entity context text to enrich.</param>
    procedure EnrichEntityContextWithAddress(EntityRecordID: RecordId; EntityType: Enum "GeoAI Entity Type"; var EntityContext: Text)
    var
        EntityFactory: Codeunit "GeoAI Entity Factory";
        EntityProvider: Interface "IGeoAI Entity";
        LocationJson: JsonObject;
        AddressToken: JsonToken;
        CountryToken: JsonToken;
        RegionToken: JsonToken;
        CityToken: JsonToken;
        PostCodeToken: JsonToken;
        AddressLine: Text;
        EnrichmentBuilder: TextBuilder;
    begin
        if not EntityFactory.IsEntityTypeSupported(EntityType) then
            exit;

        EntityProvider := EntityFactory.GetEntityProvider(EntityType);
        LocationJson := EntityProvider.GetLocationContext(EntityRecordID);

        EnrichmentBuilder.AppendLine('');
        EnrichmentBuilder.AppendLine('Address Details:');

        if LocationJson.Get('address', AddressToken) then begin
            AddressLine := AddressToken.AsValue().AsText();
            if AddressLine <> '' then
                EnrichmentBuilder.AppendLine('Street: ' + AddressLine);
        end;

        if LocationJson.Get('city', CityToken) then begin
            AddressLine := CityToken.AsValue().AsText();
            if AddressLine <> '' then
                EnrichmentBuilder.AppendLine('City: ' + AddressLine);
        end;

        if LocationJson.Get('postCode', PostCodeToken) then begin
            AddressLine := PostCodeToken.AsValue().AsText();
            if AddressLine <> '' then
                EnrichmentBuilder.AppendLine('Postal Code: ' + AddressLine);
        end;

        if LocationJson.Get('region', RegionToken) then begin
            AddressLine := RegionToken.AsValue().AsText();
            if AddressLine <> '' then
                EnrichmentBuilder.AppendLine('Region: ' + AddressLine);
        end;

        if LocationJson.Get('country', CountryToken) then begin
            AddressLine := CountryToken.AsValue().AsText();
            if AddressLine <> '' then
                EnrichmentBuilder.AppendLine('Country: ' + AddressLine);
        end;

        // Append to existing context
        EntityContext += EnrichmentBuilder.ToText();
    end;
}
