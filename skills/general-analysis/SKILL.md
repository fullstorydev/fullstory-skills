---
name: general-analysis
description: Fullstory analytics workflow — the default way to answer any question about user behavior. Use whenever someone asks how many, what percentage, which pages, whether something is trending, where users drop off, what users did before or after an action, or how two cohorts compare — and also when they describe a business question that needs numbers behind it without ever saying "metric", "funnel", or "segment". Covers building and computing metrics, segments, funnels, and journeys, verifying that what got built is what was actually asked for, and pulling sessions to explain why the numbers look the way they do. Not for reviewing one specific session, or for setting up capture and instrumentation.
---

# Fullstory Analytics

## When to use

Use this skill whenever answering the question takes a number out of Fullstory — a count, rate, percentage, breakdown, trend, drop-off, what users did before or after an action, or one cohort against another. That includes business questions that never name a primitive ("is checkout getting worse?", "which accounts are struggling?"). Pulling sessions is in scope when they're evidence for a number you computed.

## Skip when

- **One specific session.** A session URL, a named user, "what happened to this person" — that's the `session-review` skill.
- **Instrumentation and capture.** Defining events, custom properties, privacy rules, or installing the snippet. This skill reads data that already exists; it can't make Fullstory record something new.
- **Account and product configuration.** Users, permissions, integrations, data export setup.
- **No Fullstory data in the loop.** A number the user already has, or one that lives in another system.

Handing off isn't an exit. If a session review turns into "how often does this happen?", that part is this skill.

## The five primitives

Pick the primitive first; the tools follow from it.

- **Segment** — a cohort of users (the "who"). A filter, not a measurement. It narrows whose data everything else runs against.
- **Metric** — a measurement (the "what" and "how much"). Every count, rate, breakdown, and trend is a metric.
- **Funnel** — a strictly ordered sequence (the "where do they drop off"). Step counts, step-to-step conversion, and median time between steps.
- **Journey** — what happens around a single anchor event (the "what else do they do"). Unordered fan-out before or after one pivot, not a fixed sequence.
- **Session** — evidence (the "why"). Qualitative. Use sessions to explain a number, never to produce one.

Funnel vs. journey is the distinction people get wrong most often. A funnel asks "of the users who did A, how many went on to do B then C?" — you already know the steps. A journey asks "users did A; what did they do next?" — you don't know the steps and want the data to tell you.

## Build → Confirm → Compute

Every `build_*` and `update_*` tool is a language model translating a sentence into a structured definition. That translation is non-deterministic and it is the single largest source of wrong answers in this workflow — not because it fails loudly, but because it succeeds *plausibly*. A metric that filtered on the wrong URL still returns a clean, believable number. Nothing in the result signals the mistake.

So treat the returned definition as the contract, and read it before you trust anything computed from it:

1. **Build.** Call the builder. Capture both the ID and the returned definition/description.
2. **Confirm.** Read what actually got built and compare it against what was asked. See "Confirming the build" below — this beat is what makes the answer trustworthy.
3. **Compute.** Run the compute tool, then present the number with its URL.

Two rules that hold across every tool here:

- **IDs come from tool responses, never from memory or construction.** A `metric_id`, `segment_id`, `funnel_id`, `journey_id`, `device_id`, or `session_id` should always trace back to a response you actually received. Fabricated IDs look real and fail in confusing ways.
- **`fullstory:update_metric`, `fullstory:update_funnel`, `fullstory:update_journey`, and `fullstory:update_segment` return a NEW id and leave the source object untouched.** Carry the new id forward. Computing the old id after an update is a silent no-op that looks like the refinement did nothing.

## Step 0: Classify intent, and confirm scope if it's missing

| What they're asking | Route to |
|---|---|
| "how many", "what's the count/rate/percentage" | `single_number` metric |
| "which pages", "top N", "by browser", "breakdown by" | `top_n` metric |
| "over time", "by day", "is it getting worse" | `trend` metric |
| "mobile vs desktop", "A vs B", "compare" | the `comparisons` skill |
| "where do users drop off", "conversion through X → Y → Z", "how long does it take to complete" | funnel → `references/funnels.md` |
| "what do users do after X", "what led to Y", "where do they go next" | journey → `references/journeys.md` |
| "show me sessions", "let me watch some examples" | `fullstory:get_sessions` with `metric_id` or `segment_id` |
| "why is this happening" | compute first, then `references/sessions.md` |

**Scope is part of the question.** A request like "how's checkout doing?" or "where are users struggling?" has no defined boundary, and every boundary you pick silently produces a different answer. When the scope genuinely isn't recoverable from the conversation, ask once, concretely — which pages or flows matter, which users count, what time window — and offer a reasonable default so the user can just say "yes". Don't interrogate: if the request names its own scope, or the default is obvious, build and move on.

## Step 1: Search before building

Users often don't know what already exists in their Fullstory account. Search first even when the question sounds ad-hoc — an object the customer's team built and uses encodes how *they* define conversion or struggle, which is usually better than a fresh guess.

- Metrics and segments: `fullstory:get_metric(regex=...)`, `fullstory:get_segment(regex=...)`
- Funnels and journeys: `fullstory:get_funnel(regex=...)`, `fullstory:get_journey(regex=...)`

Start broad, then narrow (for "rage clicks on checkout", try `checkout` before `checkout.*rage`). Results carry a rendered description of the filters, steps, or pivot — judge relevance from that, not from the name, which is often auto-generated and misleading.

If nothing matches, say so and confirm before building. If things come back but none fit the question, say what you found and why it doesn't fit, then confirm.

**Ranking duplicates:** when 2+ plausible metric or segment candidates come back, call `fullstory:get_view_counts` on their IDs (up to 10, most name-similar first) to rank by popularity. If one has roughly 5x the views of the next, treat it as canonical and say you're using the most-used version. If the top few are comparable, present them with what each one measures and ask. If all are near zero, flag them as likely stale and offer to build fresh. `fullstory:get_view_counts` only accepts `object_type` of `segment` or `metric` — for funnels and journeys, rank by `last_updated_at` and `created_by` from the search result instead.

## Step 2: Build

Metrics are the common case and are covered here; funnels and journeys have their own reference files.

Call `fullstory:build_metric` with a descriptive `query` and the `output_type` from Step 0.

- **Pass the user's phrasing through.** Rates ("bounce rate", "conversion rate", "error rate") must stay as rate phrasing — simplifying "error rate" to "error count" drops the denominator and produces a different, wrong number. Same for comparison phrasing ("vs last week", "week over week"): pass it verbatim and you get one metric covering both windows, rather than two metrics you have to reconcile by hand.
- **Get the unit of measurement right** before building — it's the most common source of misleading results. If the question is about "customers", "accounts", or "organizations", clarify whether that means individual users or users grouped by an account property, and build accordingly.
- **Exclusions need a segment.** `fullstory:build_metric` cannot express "excluding users who…" or "users who did NOT do X" — the filter tree has no negation. Call `fullstory:build_segment` with the negation phrasing verbatim, then pass the returned `segment_id` to `fullstory:build_metric(segment_id=...)`. Putting the exclusion in the query text gets it silently dropped or misread as a positive filter.
- **Simple user-property filters don't need a segment.** "unique users on app.example.com where email does not contain @example.com" goes straight into the query. Reach for a segment when you need segment semantics: a behavioral cohort ("users who did X"), a saved/named cohort, or several cohorts to compare.
- **Scoping to a cohort at build time:** `fullstory:build_metric` accepts `segment_id` directly. For a metric that already exists, attach with `fullstory:update_metric(metric_id, segment_id)` first and compute the returned id. `fullstory:compute_metric` does **not** take a `segment_id`.

Segments: call `fullstory:build_segment` and reference by `segment_id` afterward. Reuse a `segment_id` across questions in the same conversation rather than rebuilding it.

More on metric behavior — dimensions, revenue, time ranges, and the six `fullstory:update_metric` modes — is in `references/metrics.md`.

## Step 3: Confirming the build

Before computing, check that what was built is what was asked. The failure mode to catch is a definition that is *reasonable but not what the user meant* — it will produce a number that looks fine and is wrong.

Read the returned definition (or the `metric_description` / `funnel_description` / `journey_description`) and check the handful of things the translator has to guess at:

- **Page vs. URL.** "which pages" defaults to raw URL paths, not named pages. A filter on a named page and a filter on a URL substring are different populations.
- **Event set.** Did it filter on the event type you meant — clicks vs. rage clicks vs. page views vs. a defined event with a similar name?
- **Value casing and exact strings.** Custom property values, element names, and event names are matched as given.
- **Aggregation.** Event count vs. unique sessions vs. unique users. These are three different numbers for the same filter.
- **Time range.** Defaults to `last_30_days` for metrics, segments, and funnels; `last_7_days` for journeys.
- **Output shape and grouping.** `top_n` without a grouping dimension isn't a breakdown.
- **Scope.** If you attached a segment, confirm it's on the object you're about to compute — not on the pre-update id.

When something is off, refine with the `update_*` tool rather than rebuilding from scratch: a refinement is a targeted edit, a rebuild re-rolls every decision the translator already got right. Then re-read the result.

Don't narrate this check. It's a read, not a report — mention it only when it caught something.

## Step 4: Compute and present

`fullstory:compute_metric(metric_id)`. `time_range` / `start_date` + `end_date` override the saved window for that call only, without modifying the metric.

Present in plain language with context:
- Numbers: "12,340 dead clicks over the last 30 days"
- Tables: highlight the top rows; include percentages when a total is available
- Trends: call out direction, magnitude, and inflection points

Always surface the object URL (`metric_url`, `funnel_url`, `journey_url`, `segment_url`) so the user can verify in the Fullstory UI. Surface it as soon as a build or update returns it — don't wait for the compute.

Metrics and funnels you build are unsaved drafts (their URLs contain `/create/`), and the MCP has no tool to save them. Call them unsaved when you link them, never "saved", so the user knows to save them in Fullstory if they want to keep them. Segments you build are saved under the name you give them.

## References

Load these when the situation calls for it:

- `references/metrics.md` — metric behavior in depth: `fullstory:update_metric` modes, dimension gotchas, revenue, time ranges
- `references/funnels.md` — ordered conversion flows, drop-off, and time-to-complete
- `references/journeys.md` — what users do before or after one anchor event
- `references/validation.md` — when a result is zero, anomalous, implausible, or the user is skeptical
- `references/sessions.md` — investigating sessions to explain a number

## Guidelines

- Default `time_range` is `last_30_days` (`last_7_days` for journeys). Ask before using a different window unless the user specified one.
- An invalid `time_range` is a hard error, not a silent fallback. Use the enum values, or pass `start_date` + `end_date` together as ISO 8601 (dates or full timestamps) for anything else — "this week", "yesterday", and "since the release" need concrete dates.
- Reuse `segment_id`, `metric_id`, `funnel_id`, and `journey_id` within a conversation. Don't rebuild what the user has already established.
- To reshape an existing metric (a count they now want as a trend), use `fullstory:update_metric` with the existing `metric_id` and the new `output_type`. Fall back to `fullstory:build_metric` only for a fundamentally different question or a ratio metric.
- If `fullstory:build_multi_metric` is available in this session, prefer it over `fullstory:build_metric` — it handles several measures and formulas in one object, and can build anything `fullstory:build_metric` can.
- Every number you report should come from a compute or read tool. Don't derive a figure by arithmetic on results that measure different populations, and don't estimate one.
