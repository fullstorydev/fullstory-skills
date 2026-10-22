# Journeys

A journey anchors on one event — the **pivot** — and shows what users did around it. With `direction="start"` it expands the steps that *followed* the pivot ("what do users do after visiting pricing?"); with `direction="end"` the steps that *preceded* it ("what led users to submit the signup form?").

Use a journey when the steps are the unknown. When you already know the sequence and want conversion through it, that's a funnel (`references/funnels.md`).

## Workflow

```
fullstory:build_journey  →  fullstory:compute_journey  →  (verify the pivot)  →  fullstory:get_sessions_for_journey
```

### Build

`fullstory:build_journey(query=...)` with the anchor event in plain language: "what do users do after visiting the pricing page". Pass the query as-is — the tool resolves the pivot internally, and a pre-resolved page or event id is not accepted as input, so there's no point calling `fullstory:discover_org_context` first.

- `direction` — `start` or `end`. If omitted it's inferred from the query, defaulting to `start`. Phrasings like "what led to…" or "how do users get to…" mean `end`; set it explicitly rather than relying on the inference when the query is ambiguous.
- `time_range` — defaults to **`last_7_days`**, not the 30 days most other tools default to. Journeys fan out combinatorially, so short windows are the sensible default — but say which window you used, because a 7-day journey and a 30-day metric side by side will not reconcile.
- `segment_id` — scopes the journey to a cohort. Required for exclusions, which the query cannot express: build the exclusion with `fullstory:build_segment` first.

### Always verify the resolved pivot

The pivot is chosen by a language model from your description, and it is the one thing the entire journey hangs on. A journey anchored on the wrong event still returns a full, plausible tree — every downstream percentage is confidently wrong, and nothing in the output flags it.

So before interpreting anything, read `pivots[].label` in the `fullstory:compute_journey` result (or `journey_description` from `fullstory:get_journey`). Labels are resolved to human-readable names — "Viewed /pricing", "Clicked Sign Up" — never raw ids, so this check is quick. If the pivot is wrong, rebuild with a more specific query rather than reinterpreting the tree around it. It's also worth naming the pivot in your answer ("Of the 4,300 users who viewed /pricing…") — it makes the anchor visible to the user, who is the one person who can tell you it's wrong.

### Compute

`fullstory:compute_journey(journey_id)` returns:

- `pivots` — the anchor node(s), with `count` and `share`
- `total_users` — users or sessions matching the pivot; the denominator for everything else
- `steps` — one entry per step outward from the pivot (step 1 = immediately after/before it), each with `nodes` ordered most-common-first. Each node's `share` is relative to the **previous step's total**, not to `total_users` — a retention-style share, so don't multiply it back out as if it were an absolute percentage.
- `popular_paths` — the most common end-to-end paths, most-completed first

Override for this compute only, without touching the saved journey: `time_range` / `start_date` + `end_date`, `direction`, `steps` (fan-out depth, default 4, max 10), and `per_step_limit` (distinct events per step before the rest roll into an "Other" bucket, default 5). Raising `per_step_limit` is the fix when "Other" is swallowing most of a step; raising `steps` is how you follow a path further out.

**Known bug — `popular_paths[].count` is unreliable for `direction="end"` journeys.** The count is read from the last node of each path, which is correct walking forward from the pivot but not walking backward to it. On an end-direction journey, use `completion_rate` and the `steps` tree for magnitude, and treat the path *ordering* as directional rather than the raw counts. Say so if a user asks about those numbers specifically. Start-direction journeys are unaffected.

### Refine

`fullstory:update_journey` changes the time window, direction, attached `segment_id`, and diagram settings (`collapse_repeated`, `in_same_session`, `complete_sessions`, `view_event_types`). It returns a **new** `journey_id`; compute that one.

It **cannot change the pivot** — that needs a rebuild with `fullstory:build_journey`. `view_event_types` (`visited_page`, `click`, `seen`, `custom`, `defined_event`) is a replacement, not an addition: pass the full set you want.

For a one-off "what does this look like over 30 days instead?", prefer the `time_range` override on `fullstory:compute_journey` — no new object, no id to track.

### Sessions

`fullstory:get_sessions_for_journey(journey_id)` returns everyone who passed through the pivot. To narrow to one branch, pass `nodes` — `step` + `node_id` pairs taken from the `fullstory:compute_journey` result, where `step` counts outward from the pivot and must be **≥ 2** (step 1 is the pivot itself). The deepest step you name sets the query depth.

This is how you answer "what's actually going on with that surprising branch?": find the unexpected node in the tree, pull its sessions, then investigate with `references/sessions.md`.

## Presenting journey results

A journey tree is large and mostly uninteresting. Report the two or three branches that carry real volume or that contradict what the user expected, with the pivot named and the window stated. Surface `journey_url` so they can explore the rest themselves.
