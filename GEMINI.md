# Fullstory

This extension connects **Gemini CLI** to the Fullstory MCP server.

## Access

- Fullstory MCP is in **private beta**; your account must be enrolled. See [Fullstory MCP](https://www.fullstory.com/platform/mcp/).
- Authentication is **OAuth**. On first MCP use, the client should open a browser to authorize with Fullstory. See [Authentication](https://developer.fullstory.com/mcp/authentication/).

## Bundled capabilities

- **Skills** (under `skills/`): `general-analysis` and `comparisons` — use them for quantitative analytics and A vs B comparisons.
- **Sub-agent** (`agents/session-context.md`): load a single session’s event transcript in isolation when investigating session details.

Tool names in Gemini CLI follow `mcp_<server-alias>_<toolName>` (for example, `mcp_Fullstory_get_session_events` when the MCP server key is `Fullstory`).

For product workflows and examples, see [Fullstory MCP documentation](https://developer.fullstory.com/mcp/).