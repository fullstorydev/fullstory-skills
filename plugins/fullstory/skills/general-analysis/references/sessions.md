# Session Investigation

Sessions answer "why", not "how many." Use them when:
- The user explicitly asks to see sessions
- A quantitative result raises a causal question — e.g., "why are rage clicks spiking on this page?"
- The user wants to understand the user experience behind a number
- You need to confirm or refine a hypothesis about what's driving a metric

## Read sessions in an isolated context

Never call `get_session_events` directly in the main conversation. Session transcripts are large and will bloat the context window. Instead, load each session in an isolated context — use a subagent, Task tool, or whatever mechanism your environment provides for spawning a child context with its own window. See `agents/session-context.md`.

Pass three things to the isolated context:
- `device_id` and `session_id` from the `get_sessions` result
- A task describing what you want to learn from the session

The isolated context should call `get_session_events`, answer the task, and return what it found. You synthesize across sessions in the main context.

**More specific tasks get more useful answers.** When you have a hypothesis, tie the task to it:

| Instead of… | Write… |
|---|---|
| "Summarize this session" | "Did the user successfully submit the checkout form? If not, where did they stop and what did they interact with last?" |
| "What happened?" | "The user rage-clicked something on /checkout. What element did they click, and did anything visibly change on the page after?" |
| "Tell me about this session" | "Was there a JavaScript error in this session? If so, what was the message and what page was the user on?" |

## Workflow

1. Call `get_sessions` with `metric_id` (or `segment_id` for cohort browsing) to get 3–5 sessions
2. For each session, load it in an isolated context with `device_id`, `session_id`, and a task
3. Look for patterns across the responses: same page, same element, same error, same flow sequence
4. Synthesize a conclusion: "Rage clicks on checkout are concentrated on the 'Apply Coupon' button — in 4 of 5 sessions, users clicked it repeatedly with no visible response"
5. Present session URLs as evidence supporting the conclusion, not as homework

Start with 3–5 sessions. If the pattern is clear, stop. If not, pull more — isolated contexts mean additional sessions don't cost main context space. Use your judgment on when you have enough evidence.

## Tool Names

| Tool | Claude Code name |
|---|---|
| `get_sessions` | `mcp__fullstory-mcp__get_sessions` |
| `get_session_events` | `mcp__fullstory-mcp__get_session_events` |
