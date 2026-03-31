# Fullstory MCP Plugin

Connect Claude to [Fullstory](https://www.fullstory.com) to query behavioral analytics, session data, and customer experience insights directly from your AI workflows.

**Only available to [Fullstory MCP beta program participants](https://www.fullstory.com/blog/fullstory-mcp/).**

## What is Fullstory?

Fullstory captures and analyzes digital experience data — session replays, user journeys, rage clicks, errors, and more — to help teams understand how customers interact with their products.

## What this plugin does

This plugin exposes the Fullstory MCP server to Claude, allowing you to:

- Query session and event data
- Analyze user behavior and funnel metrics
- Retrieve customer experience insights
- Explore behavioral analytics programmatically

Available tools are auto-discoverable once the server is connected. See the [Fullstory API docs](https://developer.fullstory.com) for details on what data is accessible.

## Prerequisites

- **A fullstory account that is part of the [Fullstory MCP beta program](https://www.fullstory.com/blog/fullstory-mcp/)**
- [Claude Code](https://claude.com/product/claude-code) or [Cursor](https://www.cursor.com)
- A Fullstory account with API access
- A Fullstory API key (generate one in your Fullstory account settings)

## Setup

### 1. Get your API key

Log in to Fullstory, navigate to **Settings → Integrations → API Keys**, and create a new key.

### 2. Set the environment variable

```bash
export FULLSTORY_API_KEY=your_api_key_here
```

For persistent configuration, add this to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.) or your project's `.env` file.

### 3. Add to Claude Code

Add the following to your project's `.mcp.json` (already included if you installed via the marketplace):

```json
{
  "mcpServers": {
    "Fullstory": {
      "type": "http",
      "url": "https://api.fullstory.com/mcp/fullstory",
      "headers": {
        "Authorization": "Bearer ${FULLSTORY_API_KEY}"
      }
    }
  }
}
```

Then restart Claude Code. The Fullstory tools will appear automatically.

## Configuration

| Variable            | Required | Description            |
| ------------------- | -------- | ---------------------- |
| `FULLSTORY_API_KEY` | Yes      | Your Fullstory API key |

## Available Tools

Tools are auto-discoverable from the Fullstory MCP server once connected. Use Claude to list available tools or refer to the [Fullstory Developer Documentation](https://developer.Fullstory.com) for the full API reference.

## Support

- [Fullstory Developer Docs](https://developer.Fullstory.com)
- [Fullstory Support](https://help.Fullstory.com)
- [Fullstory Homepage](https://www.Fullstory.com)
