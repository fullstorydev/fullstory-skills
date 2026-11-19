# Dashboards

A dashboard is an ordered list of cards. Each metric or funnel card points at a metric or funnel id, so a dashboard is the team's own list of what they watch. Read it before building anything new for the same question.

## Read a dashboard

1. Find it: `fullstory:get_dashboard(regex=...)`. Accounts often hold hundreds of dashboards, so search with the product area or a word from the name, and add `owned=true` when the user means their own.
2. List its cards: `fullstory:get_dashboard(id=...)` returns each card's `position`, `type`, `name`, and `object_id`.
3. Compute: `fullstory:compute_dashboard(dashboard_id, positions=[...])` returns every chosen card's numbers in one call. Without `positions` it computes the first 5 cards (up to 15 with `limit`, then page with `offset`); check `total_cards` so you do not report half a dashboard as the whole.

Pick positions from the card names that answer the question. Note cards carry section headings and context; heatmap cards return only a link.

## Card segments and the filter override

Many cards carry their own segment, such as "Anonymous Top Clicks" scoped to anonymous users. `fullstory:get_metric(id=object_id)` shows a metric card's `segments`.

`filters.segment_ids` on `fullstory:compute_dashboard` (or a dashboard's saved filter) **replaces** each card's own segment for that compute. It does not intersect with it. Two cards that differ only by segment return identical numbers under a segment filter, and a card scoped to anonymous users now counts everyone in the filter segment.

So:

- Use a segment filter only on cards whose metric has no segment of its own, or when you want every card to describe the filter population.
- To cut a segmented card by a second population, keep the card's own segment and add the second population as a filter on the events, for example with `fullstory:build_metric(query, segment_ids=[card segment])` and the device or page in the query. Passing both segments in `segment_ids` compares the two cohorts instead of intersecting them, and is rejected on grouped cards.
- When two cards return identical values under a filter, treat that as this override, not a finding.

A time-only filter (a `time_range` preset, or `start_date` with an optional `end_date`) is safe: it changes the window on every card and leaves segments alone. Use it to compare two windows by computing the same positions twice.

## Card values

- Metric cards return `single`, `table`, or `trend` values; funnel cards return per-step `user_count` and conversion, the same as `fullstory:compute_funnel`.
- A trend card with a group-by returns one block of dates per group with no group label. When you need the group names, say the card returned unlabeled series and report the values without attributing them to groups.
- A rate card with a zero denominator fails the whole call with `unsupported value: NaN`. Recompute without that position and report the card as having no data in the window.
- One card failing for any other reason reports an error on that card only; the rest still compute.

## Build a dashboard

When the user asks for a dashboard or for something they will keep watching, build each metric or funnel first with the usual build, confirm, compute flow, then call `fullstory:build_dashboard(name, cards=[...])`. Cards hold existing ids only; the dashboard does not change their definitions.

- Unnamed (built) metric ids are snapshots; saved library ids stay live and reflect later edits to that metric.
- Use a note card to say what the dashboard is for and what each section measures.
- The result is an unsaved draft (its URL contains `/create/`). Say so when you link it; the user saves it in Fullstory to keep it.
- `fullstory:update_dashboard` returns a new unsaved copy and never edits the source. `cards` replaces the whole list; `segment_mapping` swaps segments on every card, for example to point an experiment dashboard at the next variant.
