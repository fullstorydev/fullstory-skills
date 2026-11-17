# Metric Behavior

Details that change the answer. The main workflow is in `SKILL.md`; load this when refining a metric, grouping by a dimension, or working with revenue or non-standard time windows.

## Refining with `fullstory:update_metric`

`fullstory:update_metric` has six modes. They compose — any mix in one call is applied in order: refinement, then segment, then time range, then granularity, then compare-to-past. Every mode returns a **new** `metric_id`; the source metric is untouched, so compute the id that came back.

| Mode | Pass | Notes |
|---|---|---|
| Refinement | `refinement` (+ optional `output_type`) | Natural-language edit: "change aggregation to unique users", "add a Chrome-only filter", "remove the URL constraint". Does **not** support ratio metrics — rebuild those with `fullstory:build_metric`. |
| Segment attachment | `segment_ids` | Replaces the attached segments with this list, in order. Omit it to keep them. Several segments need a trend with no group-by. `output_type` is ignored in this mode. |
| Time range only | `time_range`, or `start_date` + `end_date` | Copies the filter tree, aggregation, dimensions, and attached segment verbatim and changes only the window. The language model is not invoked, so nothing can drift. |
| Trend granularity | `trend_granularity` (`minute`, `hourly`, `daily`, `weekly`, `monthly`) | Only valid on a trend metric; errors otherwise. Convert first with `refinement` + `output_type=trend`. |
| Compare to past | `compare_to_past` (bool) | Adds the prior-period overlay so one compute returns both windows. Use this rather than rebuilding — a rebuild re-translates the query and can lose filters. |
| Combined | any mix | Refinement runs first, so a segment or time range you pass alongside it lands on the refined result. |

**Prefer a narrow mode over a refinement.** Time-range-only, granularity, and compare-to-past skip the language model entirely, so they cannot silently alter your filters. A `refinement` re-runs the translator over the whole definition — appropriate when the filter logic genuinely needs to change, wasteful and slightly risky when it doesn't.

For a one-off "same metric, different window", the `time_range` override on `fullstory:compute_metric` is better still: it changes nothing saved and creates no new id.

## Comparing segments on one metric

A trend metric can hold several segments and compare how they change over time on one chart. Pass every segment in `segment_ids`, to `fullstory:build_metric` or `fullstory:update_metric`. One `fullstory:compute_metric` call then returns a `segments` list: one entry per segment, in order, each labeled and carrying its own numbers. Compare the entries.

- For totals, use one metric per segment instead. A trend's daily numbers do not add up to a total of unique users.
- For example sessions, use one segment at a time. `fullstory:get_sessions` refuses a metric that holds several segments, because it would only match users in all of them.

- Several segments need a trend. `fullstory:build_metric` builds a trend when `output_type` is left out. An explicit `single_number` or `top_n` with several segments is rejected, because those hold one segment.
- A metric with a group-by holds one segment. Drop the grouping, or compare with a dimension instead.
- The limit is 5 segments for most orgs.
- `segment_id` (one id) still works but is deprecated. Use `segment_ids`. A result that carries `warnings` says so.
- `fullstory:get_metric` lists the segments a metric uses, with each one's scope.

## Dimensions and grouping

`top_n` needs the grouping dimension expressed in the query — "top **pages** by rage click count", "errors **by browser**". The builder will not invent one, and a `top_n` metric with no dimension isn't a breakdown.

**"Pages" means raw URL paths.** "which pages", "top pages", "most visited pages", "by path" all group by `url_path` — the raw path string, covering all traffic. Only an explicit "by page **name**" or "named pages" groups by Fullstory's human-readable named pages, which cover only the pages the org has defined.

This matters twice over. The output looks different than users often expect: `/products/8812`, `/products/9034`, and `/products/9917` are three rows, not one "Product Detail" row. And the two groupings answer different questions — named pages roll a family of URLs into one business concept, raw paths do not. When a user asks for "top pages" and the result is a long tail of near-identical paths, that's the signal to offer the named-page grouping instead.

Mobile and app dimensions (app version, device model, device vendor, screen resolution, app OS version, SDK version) work the same way when the org has them: "by app version", "grouped by device model".

## Revenue

"total revenue", "sum revenue", "average order value", "AOV", and "total sales" all mean the org's **configured Revenue Event** — a specific event and amount property set up by the customer. `fullstory:build_metric` resolves it internally; pass the phrasing straight through.

A user property that merely has "revenue" in its name — `AnnualRevenue`, say — is an account attribute, not transaction revenue, and is the wrong answer. If the org has configured no Revenue Event, the builder will say so; relay that plainly and ask which event and property holds revenue rather than substituting something revenue-shaped.

## Time ranges

Presets: `today`, `yesterday`, `last_24_hours`, `last_7_days`, `last_30_days`, `last_90_days`, `last_year`, `this_month`. Default is `last_30_days` everywhere except journeys (`last_7_days`).

- **An unrecognized `time_range` is a hard error.** There is no silent fallback to 30 days, so an invented preset like `last_14_days` or `this_quarter` fails the call outright rather than quietly answering a different question.
- **Anything outside the enum goes in `start_date` + `end_date`**, both required together — passing one alone is also an error. Accepts bare ISO dates (`2025-01-01`, expanded to cover the full day) or full ISO 8601 timestamps (`2025-01-01T09:00:00Z`) when you need sub-day precision.
- **Relative phrases need resolving.** "this week", "since the launch", "Q3" have no preset. Convert them to concrete dates against today's date and pass them as a custom range.
- `start_date` + `end_date` take precedence over `time_range` wherever both are accepted.

## Escape hatches

`fullstory:compute_metric` accepts `metric_definition` instead of `metric_id` — pass exactly one, never both. It's for computing a definition you've adjusted by hand after `fullstory:build_metric` returned something almost right, and the response still returns a `metric_id` for the saved result so you can follow up. The schema is experimental; for anything the user will reuse or reference later, stay on the `metric_id` path.

If `fullstory:build_multi_metric` is available, it supersedes `fullstory:build_metric`: up to 5 measures plus up to 3 formulas combining them, in one object. Individual measures follow the same phrasing rules, except that a measure may not itself be a rate or ratio — express that as a formula over two measures.
