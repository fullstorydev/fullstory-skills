# Fullstory MCP Plugin

Ask your AI tool what your users actually did, or set up an agent that investigates sessions for you. Ask "where are users dropping off in checkout?" and the plugin builds the analysis, runs it, checks it and shows you the real sessions behind the number. Or give an agent a standing job, such as watching checkout every hour for flows that broke without logging an error, and it runs on its own and hands you a decision with the session attached.

## What is Fullstory?

Fullstory captures how people use your website and mobile apps: every click, page view, error and network request, recorded as session replays. Product, engineering and support teams use it to measure behavior, find where users struggle and see exactly what happened across sessions at great scale.

## What this plugin does

The plugin connects your AI client to the Fullstory MCP server and adds skills that teach the model how to run an analysis the way an experienced Fullstory analyst would. It looks for the segments, metrics and funnels your team already built before making new ones, checks that what it built matches the question, and pulls sessions to explain why a number moved. Your agent gets each session as structured data it can search, so it can find the exact moment something broke and open that frame, with the page structure behind it.

Every answer comes back with a Fullstory link, so a person can check the agent's work in one click. That's what makes it safe to set an agent up once and let it run. Each of these loops, inspired by real teams, runs on its own and hands you a decision:

- **Silent-failure watch:** "Every hour, find sessions with friction but no logged error. Page me on anything new, and queue the rest ranked by users affected."
- **Bug scoping:** "For each new ticket, open the customer's session, find the error behind the complaint, and count who else hit it."
- **Opportunity engine:** "Every Monday, compare people who finished checkout with people who left, and propose the fixes that would recover the most users, with replays attached."
- **Account health:** "Every week, score each account in my book on 30-day usage, flag drops, and draft talking points for the account deck."

Each loop pairs Fullstory with the tools your team already uses, such as Slack, Jira or your CRM. The MCP server answers requests but doesn't schedule them, so the schedule lives in your client, for example Claude Code's `/loop` or a cron job that runs a headless agent.

This plugin is built for analytics across many users.

## Install

**Claude**

- **Claude app:** Fullstory is a [Verified connector](https://claude.com/marketplace/connectors/fullstory) in the Claude directory. Add it from **Settings > Connectors** and sign in. The connector installs the tools only.
- **Claude app and Cowork, with skills:** to get the skills and the session-context agent too, add the marketplace from **Customize > + > Create plugin > Add marketplace** with `https://github.com/fullstorydev/fullstory-skills`, then sign in to Fullstory when prompted. On Team and Enterprise plans an Owner or Admin has to enable the plugin for the organization first.
- **Claude Code:** run `/plugin marketplace add fullstorydev/fullstory-skills`, then `/plugin install fullstory@fullstory`, then `/mcp` to sign in. If the install says the plugin isn't found, restart Claude Code and run it again. See the [Claude Code guide](https://developer.fullstory.com/mcp/client-setup/claude-code/).

**Cursor**

Run `/add-plugin fullstory` in an agent chat, or add **Fullstory** from the Cursor plugin marketplace and click **Authenticate**. See the [Cursor guide](https://developer.fullstory.com/mcp/client-setup/cursor/).

**Codex and ChatGPT**

Install **Fullstory** from **Explore > Plugins** in ChatGPT or the Codex desktop app and sign in. One install covers ChatGPT, the Codex app and Codex CLI. The CLI's own plugin search doesn't list Fullstory, so install from the app first, then open a new CLI chat. See the [Codex guide](https://developer.fullstory.com/mcp/client-setup/codex/).

**Other clients**

Any client that supports remote MCP servers can connect to `https://api.fullstory.com/mcp/fullstory` ([generic guide](https://developer.fullstory.com/mcp/client-setup/generic/)). If the client rejects the connection with "protected resource does not match expected," use your data center's URL instead: `https://api.na1.fullstory.com/mcp/fullstory` (US) or `https://api.eu1.fullstory.com/mcp/fullstory` (EU).

Everyone signs in as themselves with their Fullstory login (OAuth), so there are no keys to copy or store, and your agent sees only what your Fullstory account can see. For scheduled loops, headless jobs and shared gateways, you can [connect with an API key](https://developer.fullstory.com/mcp/authentication/#api-key) instead.

To confirm it worked, start a new chat and ask "What Fullstory tools are available?" If your client says it's connected but no Fullstory tools show up, MCP or StoryAI is turned off for your org. An admin can turn both back on under [**Settings > Account Management > StoryAI Features**](https://app.fullstory.com/ui/org/settings/genai-features).

## Tools

The server exposes more than 30 tools. These are the ones you'll see most:

| Tool | What it does |
|---|---|
| `discover_org_context` | Finds the IDs of your pages, elements and events so other tools can use them |
| `build_segment` / `build_metric` | Turns a plain-language description into a segment or metric |
| `compute_metric` | Runs a metric and returns a count, table or trend with a Fullstory link |
| `build_funnel` / `compute_funnel` | Measures step-by-step conversion through an ordered flow |
| `discover_groups` | Surfaces the top frustration signals, optionally compared to the prior period |
| `get_sessions` / `get_session_events` | Pulls matching sessions and reads what happened in each one |
| `review-open` / `review-zoom` | Opens a session as a searchable timeline and narrows to the moment that matters |
| `review-snapshot` | Shows what the user saw at a given moment, as a screenshot and the page structure behind it |

A few rules keep agents out of trouble. Look up existing segments and metrics with `get_segment` and `get_metric` before building new ones. Every `update_*` call returns a new ID and leaves the original alone, so carry the new ID forward. Always call `review-close` after `review-open`, including after an error, because open sessions hold server resources. The full list is in the [tools reference](https://developer.fullstory.com/mcp/tools-reference/).

## Skills

Fullstory tests and maintains a set of skills in this repo, and they load on their own when your question matches. In Claude Code you can also call them directly, for example `/fullstory:general-analysis`.

**general-analysis**: counts, rates, trends, funnels and before-and-after questions. It builds the segment and metric, checks the result, then pulls sessions to explain it.

> "Is checkout conversion down this month compared to last?"

You get the number against its baseline, a Fullstory link to the metric, and a few sessions that show why it moved.

**comparisons**: runs whenever you compare two groups, such as mobile vs desktop or new vs returning users. It picks the setup that gives a correct side-by-side for the attribute you're comparing on.

> "Compare add-to-cart rates for mobile and desktop users."

You get one side-by-side result for both groups, built so the two numbers are actually comparable.

**friction-analysis**: finds where users struggle on a page or flow, and whether a suspected problem is real. It confirms each signal, sizes it and pulls the replay that shows it.

> "Where are users struggling on the checkout page?"

You get the confirmed problems ranked by how many users each one affects, with a replay that shows what happened.

**session-review**: diagnoses a bug report or a single session. It maps the whole session first, then zooms to the exact moment it went wrong.

> "Here's a session link from a support ticket. What broke?"

You get a step-by-step account of what the user did, the moment it went wrong, and screenshots of what they saw.

**idea-generation**: finds improvement ideas your team hasn't already considered, sizes each one against a baseline and attaches replays as evidence.

> "What should we improve on the onboarding flow?"

You get 3 to 5 ranked proposals, each with how many users it affects and replay links you can share.

The **session-context** agent reads a session's full event log in its own context window, so long transcripts don't crowd out your main conversation. The other skills use it automatically.

## What it can and can't do

The plugin reads your Fullstory data and never changes captured sessions. When the model builds something, it comes back with a link to open it in Fullstory. Segments are saved under the name the model gives them. Metrics are saved without a name, so they don't show up in your library, and funnels stay unsaved until you save them in Fullstory. The MCP can't rename or delete anything it builds. It also can't change privacy rules or manage users.

Your privacy settings carry over. Masked and excluded data stays masked and excluded, the same as in the Fullstory app, and you see only what your Fullstory login can see. Fine-grained access control isn't supported yet. Each connection covers one Fullstory org, so if you manage several orgs you need a connection for each.

## Links

- [Get started with Fullstory MCP](https://www.fullstory.com/platform/mcp/get-started/)
- [Prompt library](https://www.fullstory.com/prompt-library/)
- [Fullstory MCP docs](https://developer.fullstory.com/mcp/introduction/)
- [Example workflows](https://developer.fullstory.com/mcp/workflows/investigate-frustrations/)
- [FAQ and troubleshooting](https://developer.fullstory.com/mcp/faq/)
- [Privacy policy](https://www.fullstory.com/legal/privacy-policy/)
- [Fullstory support](https://help.fullstory.com/)

## License

MIT
