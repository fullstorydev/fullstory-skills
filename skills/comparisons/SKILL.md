---
name: comparisons
description: How to structure A vs B comparisons in Fullstory — when to use dimensionality (event/session properties) vs separate segments (user-level properties), and why the distinction matters for correctness.
user-invocable: false
---

# Comparisons

When the user asks to compare A vs B, the right mechanism depends on what the comparison axis is. Use the decision table below to classify it — the user doesn't need to know this distinction exists.

## Event/session properties → dimensionality

If the comparison axis describes the context of an individual event at the moment it fired — not the user who triggered it — use dimensionality. Common examples: device type, browser, OS, page URL, element. But the rule is the principle, not the list: if the property travels with the event, not the user, it belongs here. Express it as a single `top_n` metric with the comparison axis as the grouping dimension.

Example: "rage clicks on mobile vs desktop" → `fullstory:build_metric(query="rage clicks by device type", output_type="top_n")`. The result table shows mobile and desktop as separate rows.

To refine an established comparison metric (e.g., "add a Chrome-only filter"), pass its `metric_id` to `fullstory:update_metric` with a refinement instruction rather than rebuilding.

**Do not use segments for event properties.** Building a "mobile users" segment and a "desktop users" segment would assign all of a user's rage clicks to whichever device they ever used — even clicks that happened on the other device.

## User-level properties → separate segments

Properties that describe a user rather than an event should use segments. The key mechanism: Fullstory resolves user properties to the user's **last known value** for that key. This canonical value is what segment queries match against — so you're asking "what bucket is this user in now?", not "what was their value at the moment of each event?".

Built-in user properties that work this way: `signed_up` (signed-up status), `first_seen` / `last_seen` (dates), `total_sessions` (engagement depth), and any custom user properties (`user_var_string`, `user_var_int`, etc.) set via `setUserProperties` — e.g. plan type or account ID. Build one metric and one segment per cohort, then compute each cohort in sequence: attach the segment via `fullstory:update_metric(metric_id, segment_id)`, call `fullstory:compute_metric(metric_id)`, store the result, then repeat with the next segment. Present the results side by side. Do not pass `segment_id` directly to `fullstory:compute_metric`.

Example: "do enterprise users experience more errors than free users?" → build two segments (enterprise, free), build one metric (errors), compute twice.

To refine a cohort after it's been built (e.g., "also exclude trial users from the free segment"), use `fullstory:update_segment` with the existing `segment_definition` rather than rebuilding with `fullstory:build_segment`.

Using `top_n` dimensionality for user properties is valid if you specifically want point-in-time values — each event is attributed to the user property value at the moment it fired. If a user changed plan tier mid-period, their events will be split across both values. For most comparisons you want the canonical (current) value, which is why segments are the default choice.

## Decision table

| Comparison axis | Type | Mechanism |
|----------------|------|-----------|
| Device type, browser, OS | Event property | Dimensionality |
| Page URL, element | Event property | Dimensionality |
| `signed_up`, `first_seen`, `last_seen` | User property | Segments |
| `total_sessions` | User property | Segments |
| `user_var_*` (custom user properties) | User property | Segments |

If you can't tell whether a property is event-level or user-level, default to dimensionality — it's more precise and uses fewer API calls.

## Why the wrong choice produces wrong results

**Segments for event properties (the temporal scope problem):** A segment matches users by their canonical properties, then includes all of that user's events. Alice uses both mobile and desktop during a 30-day window. She rage-clicks 5 times — all on desktop. With a "mobile users" segment, Alice qualifies (she used mobile once), so all 5 desktop rage clicks inflate the mobile count. With a device-type dimension, each rage click is tagged with the device it actually fired on — all 5 go to desktop, zero to mobile.

**Dimensionality for user properties (the split-value problem):** Bob was on the free plan for two weeks, then upgraded to enterprise. Using `top_n` grouped by plan tier, his events split — two weeks of errors under "free", two weeks under "enterprise". If the question was "do enterprise users see more errors?", Bob's pre-upgrade errors are excluded from the enterprise count. With segments, Bob's canonical value is "enterprise" (last known), so all his events count toward the enterprise cohort.
