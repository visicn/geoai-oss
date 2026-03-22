/// <summary>
/// Interface IGeoAI Service (ID 70050).
/// Abstraction for AI service providers (SaaS Azure OpenAI vs Private Gateway).
/// Enables swappable implementations without changing business logic.
/// </summary>
interface "IGeoAI Service"
{
    /// <summary>
    /// Executes an AI prompt and returns the result.
    /// </summary>
    /// <param name="SystemText">System instructions for the AI.</param>
    /// <param name="UserText">User prompt for the AI.</param>
    /// <param name="MaxTokens">Maximum output tokens allowed.</param>
    /// <param name="Temperature">Temperature (0-1) for response variability.</param>
    /// <param name="ResultJson">Output: AI result in JSON format.</param>
    /// <returns>True if successful, false otherwise.</returns>
    procedure ExecutePrompt(SystemText: Text; UserText: Text; MaxTokens: Integer; Temperature: Decimal; var ResultJson: Text): Boolean;

    /// <summary>
    /// Estimates tokens for a given text and model deployment.
    /// </summary>
    /// <param name="TextToEstimate">Text to estimate tokens for.</param>
    /// <param name="ModelDeployment">Target model deployment name.</param>
    /// <returns>Estimated token count.</returns>
    procedure EstimateTokens(TextToEstimate: Text; ModelDeployment: Text): Integer;

    /// <summary>
    /// Gets available model deployments.
    /// </summary>
    /// <returns>List of deployment names available in current configuration.</returns>
    procedure GetDeployments(): List of [Text];
}
