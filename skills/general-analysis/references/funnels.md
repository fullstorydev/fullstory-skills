# Funnels

A funnel measures a **strictly ordered** sequence: step 2 only counts for users who already did step 1, in that order. Reach for one when the user asks where people drop off, how a multi-step flow converts, or how long a flow takes. If the steps aren't known in advance, that's a journey (`references/journeys.md`), not a funnel.

By default all steps must happen **within the same session**. Cross-session flows ("signed up, then purchased within 7 days") need `in_same_session=false`.

## Workflow

```
fullstory:build_funnel  →  (confirm)  →  fullstory:compute_funnel  →  fullstory:get_funnel_sessions
```

### Build

`fullstory:build_funnel(query=...)` with the ordered steps described in plain language: "visited the pricing page, then clicked Sign Up, then submitted the form". Useful parameters:

- `aggregation` — `unique_users` (default) or `unique_sessions`. This changes what the step counts mean, so set it when the question is about sessions.
- `within_seconds` — the whole funnel must complete in this many seconds ("within 5 minutes" → 300). Pass `0` to strip a window the query implied; omit to keep it.
- `in_same_session=false` — for flows that span sessions.
- `time_range` — defaults to `last_30_days`.
- `segment_ids` — bakes cohorts into the definition, at most 4 unless the org's limit has been raised. Prefer scoping at compute time instead (see below); the exception is an **exclusion** ("excluding users who already subscribed"), which `fullstory:build_funnel` cannot express in the query at all — build the exclusion with `fullstory:build_segment` first and pass its id here or to `fullstory:compute_funnel`. `segment_id` (one id) still works but is deprecated.

### Confirm before computing

Read `funnel_definition` / the funnel description and check the step order, the event each step resolved to, and the aggregation. A funnel whose steps got reordered or whose "clicked Checkout" resolved to a page view still returns a clean conversion curve.

### Compute

`fullstory:compute_funnel(funnel_id)` computes the funnel for the segments saved on it, or for everyone when it has none, and returns per-step:

- `user_count` — users or sessions reaching that step
- `conversion_from_previous` and `conversion_from_first` — percentages (0–100); both omitted for step 1, which is the entry point and has only a count
- `median_time_to_complete_from_previous_ms` / `median_time_to_complete_from_first_ms` — **milliseconds**; omitted for step 1 and wherever there's no data. Convert to human units when presenting ("median 4m 12s from cart to purchase").

Three optional arguments do a lot of work:

- **`segment_ids`** — compute for these populations instead of the saved ones, at most 4 unless the org's limit has been raised. A call over the org's limit fails before any work and the error states the limit, so retry with that many or fewer. This is the right way to answer "how does this funnel convert for enterprise users?", because the same saved funnel can be computed against several cohorts without rebuilding, which also keeps the comparison honest — identical steps, different population. With several segments the result holds `segments` instead of `steps`: one labeled entry per segment, each with its own steps. Each segment is computed on its own, so the numbers compare cohorts rather than intersect them.
- **`compare_to`** (`previous_day` / `previous_week` / `previous_month` / `previous_quarter` / `previous_year`) — each step gains a `previous` object with the same fields over the earlier window.
- **`dimension`** — `{property: "browser"}` and each step gains a `groups` array with per-group counts and conversion. Use `apply_to_steps: [0]` to break down only the entry step. Custom-var dimensions (`page_var`, `elem_var`, `user_var`, `event_var`) also need `field_name`.

`compare_to` and `dimension` take one segment at most. With several segments, sent or saved on the funnel, they are refused: pass the one cohort you want in `segment_ids`.

The funnel's **saved** time range is always used — `fullstory:compute_funnel` has no time-range override. To change the window, use `fullstory:update_funnel(funnel_id, time_range=...)`, which is cheaper and safer than rebuilding because it copies the steps verbatim instead of re-translating them.

### Refine

`fullstory:update_funnel` changes the time window, aggregation, `within_seconds`, `in_same_session`, the saved segments (`segment_ids`, which replaces them, with the same limit as `fullstory:compute_funnel`), and/or the steps themselves (via a natural-language `refinement` like "add a step for clicking Checkout after the cart page"). It returns a **new** `funnel_id` and leaves the original alone — compute the new id, not the old one. A funnel always keeps at least 2 steps.

### Sessions

`fullstory:get_funnel_sessions(funnel_id, completed_step=N)` — `completed_step` is **required and 0-indexed**. For users who completed the whole funnel, read `num_steps` from `fullstory:get_funnel` and pass `num_steps - 1`. Add `did_not_complete=true` to get the drop-offs at that step instead, which is usually the more interesting set: those are the sessions that explain the conversion gap. Hand them to `references/sessions.md` for the actual investigation.

## Presenting funnel results

Lead with where the drop-off is, not with a recitation of every step. "1,240 users reached checkout; 38% completed payment, and the biggest drop is cart → checkout at 54%" is the answer. Include the median time-to-complete when the question was about speed or friction, and always surface `funnel_url`.

## Fullstory-managed funnels

`fullstory:get_managed_funnels` lists funnels Fullstory maintains for the org. Their ids feed StoryAI opportunity tools and `fullstory:discover_groups(funnel_id=...)` for frustrations among dropouts — they are a different family from the funnels `fullstory:build_funnel` creates and are not interchangeable with `fullstory:compute_funnel`.
