# Validating Results

Not every result needs validation. Validate when the result is zero, looks anomalous on its face, or the user expresses doubt. When a result looks normal and nothing is suspicious, present it confidently — always include the `metric_url` so the user can see the underlying data and verify for themselves.

## Zero results — always validate

Zero is never confidently correct without a cross-check. When `fullstory:compute_metric` returns zero:

1. Broaden scope: recompute the same event type without page/element filters. If the broader query returns data, the filter was wrong — tell the user what the data actually shows.
2. Expand time range: try `last_30_days` or `last_90_days`. If data appears in a longer window, the event exists but not in the requested period — report that.
3. Check overall traffic: compute a simple page-view metric with no filters to confirm the organization has data at all. If this is also zero, the org may have no data in the time range.

## Anomalous results — validate

If a result looks wrong on its face — a rate over 100%, a count that seems physically implausible, or a number that contradicts something already established in the conversation — investigate before presenting. Do not wait for the user to question it.

## Context already available — use it for free

If you already computed a related metric earlier in the conversation (e.g., total traffic), mention proportionality without making an extra call: "4,200 rage clicks out of 1.2M page views (0.35%)." Do not fetch a denominator just to sanity-check a normal-looking number that nobody questioned.

## Trends — check for discontinuities

If a trend shows a sharp drop to zero mid-period or a sudden spike that doesn't recover, investigate before drawing conclusions. Broaden the metric (remove filters, check overall traffic for the same period) to determine whether the discontinuity is specific to this event or affects all data. If overall traffic also drops, it may be a data collection issue. If overall traffic is healthy but this metric changed sharply, the change may be real — look at what else changed at that point (different pages, different devices via `top_n`) to understand what's driving it.

## When the user expresses skepticism

If the user says "that doesn't seem right," slice by dimension. Call `fullstory:update_metric` with the existing `metric_id` and a refinement like "change to top_n grouped by page" to see the distribution. This either confirms the number or reveals where the data is actually concentrated.

## Presenting validation

Do not narrate every check you ran. If the result passes validation, present it with confidence and context. Only surface the validation work when something was wrong and you corrected course or need the user's input.
