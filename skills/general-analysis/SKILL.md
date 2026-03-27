---
name: general-analysis
description: Fullstory analytics workflow. Use when answering a question that requires measuring user behavior — counts, rates, trends, breakdowns, or cohort comparisons. Builds segments and metrics, computes results, then investigates sessions to explain what the numbers mean.
---

# Fullstory Analytics

## Mental Model

Internalize these three concepts before choosing tools:

- **Segment** = a cohort of users (the "who"). A segment is a filter, not a measurement. It narrows which users' data a metric runs against.
- **Metric** = the measurement (the "what" and "how much"). Every quantitative answer is a metric. Even "how many users visited /checkout" is a metric (count of page views), optionally filtered by a segment.
- **Session** = evidence (the "why"). Sessions are qualitative. Use them to understand *why* a number looks the way it does — not to answer the quantitative question itself.

## Step 0: Classify Intent

Before calling any tool, determine what the user is asking for:

- "how many", "what's the count", "what percentage", "what's the rate" → quantitative answer → `single_number` metric
- "which pages", "top N", "by browser", "breakdown by" → breakdown → `top_n` metric
- "over time", "by day", "is it getting worse", "trend" → trend → `trend` metric
- "mobile vs desktop", "compare", "A vs B" → comparison → invoke the `comparisons` skill
- "show me sessions", "let me watch", "examples of" → session exploration → `get_sessions` with `metric_id`
- "sessions from power users", "show me what enterprise users do" → cohort browsing → `build_segment` then `get_sessions` with `segment_id`

If the intent is ambiguous, ask the user before proceeding. Getting the intent wrong wastes a build+compute cycle.

## Step 1: Resolve or Build

### Always search before building

Users often don't know what metrics or segments already exist in their Fullstory account. Always search first, even when the question sounds ad-hoc. Use `get_metric(regex="...")` or `get_segment(regex="...")`, starting broad and narrowing if needed (e.g., "how many rage clicks on checkout?" → start with `checkout`, then try `checkout.*rage` if the first search returns too many results).

Results include a short description of the segment's filters and events, so use that — not just the name — to judge relevance:
- If 1–5 results come back and their filters/events match the user's intent, show them with links and ask: "I found these — does one match what you're looking for, or should I build a new one?"
- If results come back but their filters/events don't match the question, tell the user what you found and that none seem to match, then confirm they'd like you to build a new one.
- If no results match, tell the user nothing was found and confirm before building.

### Building new

**Metrics:** Before building, make sure the unit of measurement is correct — getting this wrong is the most common source of misleading results. If the question is about "customers", "accounts", or "organizations", clarify whether the user wants to count individual users or group users by a customer/account/organization property. If it's the latter, look for user properties that match and build the metric to count by that property. Similarly, watch for ambiguity between pages and URLs — "which pages" usually means page titles or paths, not full URLs with query parameters.

Call `build_metric` with a descriptive query and the correct `output_type` derived from intent classification:

- Quantitative answer → `single_number`
- Breakdown → `top_n`
- Trend → `trend`

For `top_n`, make sure the grouping dimension is expressed in the query (e.g., "top pages by rage click count"). The metric builder will not invent a dimension on its own.

**Segments:** Call `build_segment`. Always reference by `segment_id` in subsequent steps. If the same cohort is needed for multiple questions in the conversation, reuse the existing `segment_id` — do not rebuild.

## Step 2: Compute

Call `compute_metric` with:
- `metric_definition` from build or get
- `segment_id` if the question is scoped to a cohort
- `time_range` — default is `last_30_days`; ask the user if they want a different window

Present results in plain language with context:
- Numbers: "12,340 dead clicks over the last 30 days"
- Tables: highlight the top entries; include percentages if a total is available
- Trends: call out direction, magnitude, and any inflection points

Always surface `metric_url` so the user can verify in the Fullstory UI.

## References

Load these when the situation calls for it:

- `references/validation.md` — when results are zero, anomalous, or the user expresses skepticism
- `references/sessions.md` — when investigating sessions to understand why a metric looks the way it does

## Tool Names

| Tool | Claude Code name |
|---|---|
| `build_metric` | `mcp__fullstory-mcp__build_metric` |
| `build_segment` | `mcp__fullstory-mcp__build_segment` |
| `compute_metric` | `mcp__fullstory-mcp__compute_metric` |
| `get_sessions` | `mcp__fullstory-mcp__get_sessions` |
| `get_session_events` | `mcp__fullstory-mcp__get_session_events` |

## Guidelines

- Default `time_range` is `last_30_days`. Ask before using a different window unless the user specified one.
- When building a segment for use in a later step, always reference by `segment_id`.
- Reuse `segment_id` and `metric_id` within a conversation. Do not rebuild objects the user has already established.
- If the user asks for a different shape of an existing metric (e.g., they have a count but now want a trend), rebuild with `build_metric` using the same event description and the new `output_type`. Do not try to mutate an existing definition.
- When presenting table results, include both the dimension value and the count. If a total is available, show percentages.
- Always surface `metric_url` in your response so the user can verify in the Fullstory UI.
