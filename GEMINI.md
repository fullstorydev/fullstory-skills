# Fullstory

This extension connects **Gemini CLI** to the Fullstory MCP server.

## Access

- MCP is on by default for every Fullstory org. If no Fullstory tools show up, MCP or StoryAI is turned off for your org, and an admin can turn both back on in Settings. See [Fullstory MCP](https://www.fullstory.com/platform/mcp/).
- Authentication is **OAuth**. On first MCP use, the client should open a browser to authorize with Fullstory. See [Authentication](https://developer.fullstory.com/mcp/authentication/).

## Bundled capabilities

- **Skills** (under `skills/`): `general-analysis`, `comparisons`, `friction-analysis`, `session-review` and `idea-generation`. Use them for quantitative analytics, A vs B comparisons, finding where users struggle, diagnosing a single session, and sizing improvement ideas.
- **Sub-agent** (`agents/session-context.md`): load a single session’s event transcript in isolation when investigating session details.

Tool names in Gemini CLI follow `mcp_<server-alias>_<toolName>` (for example, `mcp_Fullstory_get_session_events` when the MCP server key is `Fullstory`).

For product workflows and examples, see [Fullstory MCP documentation](https://developer.fullstory.com/mcp/).
