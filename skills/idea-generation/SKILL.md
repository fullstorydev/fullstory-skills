---
name: idea-generation
description: Finds product improvement ideas a team has not already considered. Searches the metrics, segments and funnels the team already built, builds the ones that are missing, measures how many users each idea affects against a baseline, and pulls session replays as evidence. Returns 3 to 5 ranked proposals, each with what is new about it, a user count with its baseline, and replay links. Use when someone asks what to build next, how to improve a product area or flow, what the team is missing, for data-backed product ideas or proposals, or what changed after a release. If the user only wants the list of Fullstory Opportunities, call the Opportunities tools directly instead. For counts, rates and trends use general-analysis, for A vs B mechanics use comparisons, and for one session use session-review.
---

# Idea Generation

## Goal

Produce 3 to 5 product proposals that the team has not already considered. Every proposal must pass three tests:

- **New.** It is not already on a dashboard, in the backlog, shipped, in progress, or returned by `fullstory:get_opportunities`. The obvious findings, such as the biggest funnel drop-off or the most rage-clicked element, are usually already known. Proposing them again does not help the team.
- **Fixable by the audience.** The team receiving the proposal can fix it with a product change: UI, copy, flow, defaults, or a feature. A problem that only a backend team, an infrastructure team, or a third party can fix does not qualify. Step 1e explains how to decide who the audience is.
- **Measurable.** You can state how many users it affects, as a count and as a share of a named total, next to the same number for a baseline group.

A finding that fails any test is an observation, not a proposal. Put observations in Emerging Signals (Step 5) or drop them.

## Related Skills

- `general-analysis`: how to build and compute metrics and segments.
- `comparisons`: how to structure an A vs B comparison. This skill decides what is worth comparing.
- `session-review`: deep diagnosis of a single session.
- If the user only wants to see their Fullstory Opportunities, call `fullstory:get_opportunities` directly and stop. This skill treats that list as things the team already knows, not as the answer.

## Workflow

1. Frame the question and fix the definitions.
2. Find leads. Start with existing metrics, segments and funnels, because reading them is cheap. Most of the run happens here.
3. Measure each lead against a baseline.
4. Pull session replays, only for the leads you plan to present.
5. Filter, rank and write the proposals.

## Step 1: Frame the Question

### 1a. State the question in one sentence

Many requests contain more than one question. "Improve retention" can mean "do these users convert at a lower rate?" or "what makes users come back?" Each needs different analysis. Pick the reading that best matches the user's words, state it in one sentence, and name the reading you did not pick.

Also name the **area** you are studying: the pages, screens or feature the question is about, such as "the checkout flow" or "the search results page". The rest of this skill calls it the area.

### 1b. Retention questions need a return-visit lead

Fixing problems in a flow helps subsequent users complete the flow the first time. It does not give them a reason to come back to the product. If the question is about repeat use or retention, at least one lead must be about what brings users back:

1. List what the product does to prompt users to come back, instead of relying on them to remember. This depends on the product. A store might have saved searches, price-drop or back-in-stock alerts, wishlists and reminder emails. A software tool might have scheduled reports, alerts and shared links. A content site might have follows and subscriptions.
2. Measure what share of users used at least one of them.
3. Compare users who returned with users who did not. Check whether the users who returned used one of them more often.

Look for this directly. A missing reason to return does not show up in frustration or error signals, because nothing breaks.

### 1c. Ask the user at most two questions

Send one message and skip any question the request already answers:

1. Which flow or product area should I look at, and over what time range? If the user leaves this to you, pick the product areas with the most traffic, use the last 30 days, and state what you picked.
2. What does the team already know here? This includes dashboards they watch, backlog items, recent releases, and work in progress. Say that you will not propose any of it back.

The second question matters most, because anything the team already knows cannot count as new. If the user does not know or does not answer, build the known list yourself in Step 2 from the existing objects and from `fullstory:get_opportunities`, and list what you excluded in the output.

Do not ask for permission to start or for how much to cover. Decide the scope yourself, run it, and report what you covered.

### 1d. Fix five definitions before computing anything

Write these down before the first compute call, and repeat them in the caveats section of the output so a reader can check them. Do not change them after you have a number.

```
POPULATION   The users you are studying, as the exact filter that selects them.
OUTCOME      The single event or page view that counts as success.
TIME RANGE   One date range, used for every number in the run.
DENOMINATOR  Every rate or percentage is a share of some total. Name that total.
BASELINE     The comparison group, and why it is a fair comparison.
```

If these change during a run, two runs of the same question can use different baselines and reach opposite conclusions, and nothing in the output shows that the math changed.

These definitions apply to the question from Step 1a. If a lead needs a different population or outcome, write that lead's definitions down before you compute it.

The three most common mistakes:

- **Outcome.** Starting something, finishing it, and coming back to do it again are different events. For example, adding an item to a shortlist, submitting a lead form, and returning to submit another are three outcomes. Name the one you mean.
- **Baseline.** Compare against other users of the same area, not against every user of the site or app. Everyone is a different population.
- **Unit.** A per-page-view rate and a per-user rate are different numbers. State which one each rate uses.

### 1e. Decide who will act on the proposals

Infer from the request who will receive the proposals, for example a design team, the product team for one area, or leadership. State your assumption. Do not ask. Keep only problems that audience can fix.

Backend failures are a special case. The failure itself is out of scope for a product team. How the interface behaves when the backend fails is in scope, and it is often the best finding. If a request fails and the UI shows no error, keeps accepting input, or loses the user's work, that is a product fix. Only drop it if a perfectly reliable backend would leave nothing for the product team to change.

## Step 2: Find Leads

### 2a. Check whether captured data already identifies the population

Before building a new segment, check whether data you already capture separates the users you care about: a URL path or query parameter, a page, a device type, a referrer, or a custom user or event property. If one does, filter on it. That is the simplest way to define the population.

Do not conclude that the population cannot be isolated without checking. If nothing in the data separates it, say so at the top of the output, because your findings then cover everyone who used the area. For example, if you were asked about first-time shoppers and cannot tell them apart from repeat shoppers, your findings describe all shoppers, and you cannot say they apply to first-time shoppers in particular.

### 2b. Search the objects the team already built

Before building anything, search the metrics, segments and funnels the team already made, with `fullstory:get_metric`, `fullstory:get_segment` and `fullstory:get_funnel`. Search with several terms from the area, such as page names, feature names and event names, not one guess. What the team already built tells you what they already watch, which Step 1c needs.

`fullstory:get_managed_funnels` lists a different family: funnels Fullstory maintains for the account. Their ids work with `fullstory:discover_groups` and the Opportunities tools, not with `fullstory:compute_funnel` or `fullstory:get_funnel_sessions`.

Keep an object only if it answers your question. A metric filtered to the wrong population, or a funnel missing a step you need, is not a match.

### 2c. Build what is missing

If nothing from the search answers the question, build it:

- `fullstory:build_funnel` for a sequence of steps nobody has measured.
- `fullstory:build_journey` for the paths into and out of a key step.
- `fullstory:build_metric` for an event nobody counts.
- `fullstory:build_segment` for a group of users nobody has defined.

Decide what you need to see, then build exactly that. Do not build a near copy of an object the search already found.

### 2d. List steps with no measurement

Go through the flow one step at a time and list every step that has no metric, segment or funnel on it. Nobody has proposed anything about these steps because nobody could see them, so they often produce the best leads. If the question covers a product area rather than one flow, do this for the two or three flows in that area with the most traffic.

### 2e. Compute and look for these patterns

| Pattern | How to find it |
|---|---|
| A number that changed | Compare against the prior period, or break it down by a dimension. A metric that broke its trend, or differs sharply between groups, is the strongest kind of lead. |
| Paths that split | `fullstory:compute_journey` returns the pivot step, the branching at each step with each event's share of the previous step, and `popular_paths`. Users reaching the same outcome by very different routes is a lead. If the branch you care about is grouped into "Other", raise `steps` (default 4, max 10) and `per_step_limit` (default 5). |
| No reason to return | See Step 1b. Check what exists in the area to bring users back, and what share of users used it. |
| An object nobody opens | `fullstory:get_view_counts` takes up to 10 ids of type `metric` or `segment` and a `days` window (default 30, max 90). An object the team built and stopped opening is either a solved problem or an abandoned question. An abandoned question is a lead. |

### 2f. Sweep for problems nobody built an object for

`fullstory:discover_groups` returns the top frustration and error groups. Its `scope` object accepts `page_ids`, `domains`, `app_names` and `url_paths`, which can be combined. It also accepts a `segment_id` or a `funnel_id`, but not both. Set the time range explicitly: it defaults to the last 24 hours.

### 2g. Check which tools you have

`fullstory:get_opportunities`, `fullstory:get_opportunity`, `fullstory:get_pages` and `fullstory:get_managed_funnels` are not available in every Fullstory account. When they are unavailable they do not appear in your tool list at all. You will not get an error or an empty result. Check your tool list before planning around them.

- If `fullstory:get_managed_funnels` is missing, you lose only the Fullstory-maintained funnels. The team's own funnels are still found with `fullstory:get_funnel`.
- `fullstory:discover_groups`, `fullstory:get_opportunity_stats` and `fullstory:get_sessions_for_opportunity` are always available. They compute from recorded data at call time. When the other four tools are missing, you lose the pre-ranked Opportunities list and the page and funnel lists, and these three tools plus the metric and segment search are your whole lead sweep.
- If `fullstory:get_opportunities` is present but returns nothing, the account has no stored Opportunities. That is different from the tool being missing, and it also means your known list is weaker. Say which case applies.

### 2h. Validate any segment defined by exclusion

A segment like "did not convert" often includes users who did convert. For example, a "did not book" segment that excludes users who clicked Book Now still contains users who booked from their favorites page instead. Before using a segment like this:

1. Pull 8 to 10 sessions from the segment with `fullstory:get_sessions` and read them.
2. Check whether the user reached the outcome anyway by any route.
3. If more than about 10% did, fix the definition.

Define "converted" by what every successful user reaches, such as the confirmation page or thank-you message, in every language and variant. If that is not captured, use the event closest to it, such as an order or lead-submitted event, and name the one you used. Avoid defining it by one button or link, because users who succeed another way never click it.

A scope filter narrows where you look, such as a page, a device or a date range. You may loosen a scope filter to get more volume, and you must say so in the caveats. Do not loosen the filter that defines the population. That changes the question, so ask the user first.

### 2i. Drop leads that fail the three tests

Remove leads that are not new, not fixable by the audience, or not measurable. Compare the rest against the known list from Step 1c and against `fullstory:get_opportunities` results. Anything `fullstory:get_opportunities` returned is already known to the team. Use it to confirm or size a lead, not as a new proposal.

## Step 3: Measure Each Lead

For a lead from `fullstory:discover_groups`, pass its `default_metric_id`, `group_id` and `group_id_fallback` to `fullstory:get_opportunity_stats`, with the same scope and the same time range. It returns `users_affected`, `session_count`, `user_percentage`, and breakdowns by page, device and domain.

- To say what share of users a problem affects, use `user_percentage_on_page`: the share of people who visited that page. `user_percentage` is the share of everyone in the account, so it makes a problem on a small page look tiny.
- For the baseline, use `frustration_rate_change` and `error_rate_change`. They already compare users who hit the problem with users on the same page who did not, so you do not need to build a second group.

For a lead from a funnel or metric, measure it with `fullstory:compute_funnel` or `fullstory:compute_metric`. `fullstory:compute_funnel` takes a funnel from `fullstory:build_funnel` or `fullstory:get_funnel`, not one from `fullstory:get_managed_funnels`.

Every number in the output must include its denominator and time range, so a reader can reproduce it.

Before trusting any number:

- **Check whether automated traffic is in each lead.** Test scripts, monitoring tools and scrapers show up as sessions from data-center locations, many sessions repeating the same steps, sessions that last hours with almost no clicks, and Fullstory's automation flags. `fullstory:get_opportunities` accepts `exclude_bots`, and its results mark bot-driven items with `is_bot`. The metric, funnel and stats tools have no bot filter, so report automated traffic instead of claiming you removed it.
  - For each lead, check whether automated sessions make up a meaningful part of its count or of the replays you read. If they do, say so in that proposal's Size line, with a rough share.
  - If a lead's evidence comes mostly from automated sessions, keep it, say so in its Size line, and rank it below leads backed by real users.
- **Check activity before trusting a missing signal.** A group that averages a few clicks per session cannot produce many rage clicks, dead clicks or error clicks, so zero of them does not mean nothing is wrong. A silent failure looks exactly like this. Report the average interaction count next to any claim that depends on a signal being absent.

## Step 4: Pull Session Replays

After Step 3, pick the leads you expect to present, at most five plus one or two spares, and pull replays only for those. Replays explain why a measured number looks the way it does. They are not how you find leads. Every proposal must include a replay link, so a lead you do not pull replays for cannot become a proposal.

- Pull 3 to 5 sessions per lead with the tool that matches where the lead came from:
  - `fullstory:get_sessions_for_opportunity` for a lead from `fullstory:discover_groups`. Set the time range: it defaults to the last 24 hours.
  - `fullstory:get_funnel_sessions` for a funnel lead. Pass the 0-indexed step in `completed_step`, and `did_not_complete: true` to get the users who dropped off there.
  - `fullstory:get_sessions_for_journey` for a journey lead. To get sessions that took a specific path, pass `nodes` as `step` and `node_id` pairs from `fullstory:compute_journey`, and add 1 to each step number: `fullstory:compute_journey` counts the first event after the pivot as step 1, while `fullstory:get_sessions_for_journey` counts the pivot itself as step 1.
  - `fullstory:get_sessions` for a lead from a metric or segment.
- Copy every `session_url` exactly as returned. Never write one by hand.

Before reading, list the controls in the area where repeated clicking is normal, such as steppers, image carousels, sliders and pagination. Otherwise you will report normal use as a bug.

For each session, record the same fields so you can count the results:

- What the user was trying to do.
- The path, with timestamps.
- Whether the session **confirms** the pattern, **contradicts** it, or shows a **different cause**.
- Any workaround the user invented.
- Anything that no event would capture.
- One concrete change that would have helped.

The tally decides whether a lead survives, and it goes into the proposal, for example "4 of the 5 sessions I read show this." Contradicting sessions are a valid result. An agent told to look for a problem will usually find one. If every session confirms the pattern, check whether you picked or read the sessions looking only for confirmation.

If the replays show a different cause than the number suggested, report the cause the replays show, and measure it again before ranking. If the replays show no problem, drop the lead.

## Step 5: Filter, Rank and Write

### 5a. Run four checks on every candidate

- **Already known.** Drop anything on the Step 1c list or returned by `fullstory:get_opportunities`. If it already shipped as a fix and the problem is still happening, call it a regression.
- **Evidence.** Every proposal needs at least one replay link from this run, and two independent sources in total. A computed metric, segment or funnel is one source. The replays you read in Step 4, an Opportunity, or a support theme or earlier analysis the user shared is another. In most runs the two sources are a computed object plus the replays. A pattern with only one source goes in Emerging Signals.
- **Baseline.** Every number needs a comparison next to it. If there is none, compute a fair baseline before ranking. Then rule out these causes: a partial time range read as a trend, seasonality, a launch or rollout effect, bots, and a sample too small to trust.
- **New.** Write one line on what this proposal tells the team that their metrics, dashboards and backlog do not. If you cannot, it is an observation. Cut it or move it to Emerging Signals.

Put the count of candidates dropped by each check in the caveats, not in the body.

### 5b. Rank by judgment and explain the order

Rank by how many users it affects, whether it is getting worse, and how hard it looks to change. State the reasoning.

Prior-period comparisons often return zero for every group on sparse data. That means the prior window is empty, not that the problem collapsed. When that happens, drop the change numbers, rank on the share of the area's users affected and on how badly it affects each user (for example, lost work ranks above a short delay), and say you did this.

Do not compute a combined priority score. Multiplying a real user count by an estimated effort weight creates false precision and hides the judgment.

The headline number needs the most care. It must have its denominator, definition and baseline, and it must appear in the body, not only in a summary.

### 5c. Write each proposal in this format

```
[Title, 10 words or fewer, naming the change, not the problem]
- What: the change in one sentence, specific enough to hand to the person who would build it
- Why it's new: what this tells the team that their metrics, dashboards and backlog do not
- Size: users affected in the time range, as a count and a share of a named total, AND the baseline.
  If automated traffic is a meaningful part of the count, say roughly how much
- Cause: what is happening, in one or two sentences
- Moves: the one measurable behavior the change should shift, and in which direction.
  If you cannot name one, tag it DECORATION and rank it last
- Next: what the reader should do: validate something specific, hand it to engineering,
  or escalate it, with a rough effort (small, medium or large)
- Watch: 2 to 3 replay links as `[label @mm:ss](session_url)`, each with one line
  on what the reader will see
```

### 5d. Structure the output for the reader

The reader will do one of three things with a proposal: investigate it further, hand it to the team that would build it, or present it to their manager. It is finished when they can do all three without rebuilding your work.

- Organize the output around the proposals, not around the steps you ran. Do not narrate the search, the measurement, or the checks.
- Do not list the objects you built.
- Give each recommendation once. Do not repeat it in a summary and again in the body.
- Put anything about how the work was done (what you searched, dropped, read or built) in a short caveats section at the end, or leave it out.

Present the top 3 to 5 proposals, then Emerging Signals as one line each.

Segments you build are saved under the name you give them. Metrics you build are saved without a name, and funnels come back as unsaved drafts. The MCP has no tool to save or delete them, so when you link to a metric or funnel, say it is unsaved so the reader can save it in Fullstory if they want to keep it. Do not link to objects the proposals do not use.

## Tool Notes

These behaviors are verified. Missing them has broken past runs.

| Topic | Behavior |
|---|---|
| `fullstory:discover_groups` result | Returns `default_metric_id`, `group_id` and `group_id_fallback`. Pass all three to later calls. Dropping the `group_id_fallback` boolean silently matches the wrong group. |
| Same scope everywhere | `fullstory:get_opportunity_stats` and `fullstory:get_sessions_for_opportunity` both take `scope`. Pass the same scope you gave `fullstory:discover_groups`, or the numbers describe every user in the account. |
| Percentages that disagree | `user_pct` from `fullstory:discover_groups` is a share of the scope you queried. `user_percentage_on_page` is a share of that page's traffic. State which one each number is. |
| `fullstory:get_opportunities` percentages | `user_percentage` and `event_percentage` are filled in only when you pass a segment, and return zero otherwise. Even then they are shares of every user in the account. Never report "0% affected" from them. |
| Short default windows | `fullstory:discover_groups`, `fullstory:get_opportunity_stats` and `fullstory:get_sessions_for_opportunity` all default to the last 24 hours. Pass `relative_time_range` (for example `30d`) or `start_time` and `end_time` on every call so all numbers use the Step 1d time range. `fullstory:build_journey` defaults to the last 7 days, so pass `time_range` there too. |
| `fullstory:get_sessions_for_opportunity` limit | `limit` defaults to 10 (max 50). |
| `dropout_at_step` | Used with `funnel_id`, inside `scope`. The default, 0, means the last step (users who dropped out entirely), not the first step. |
| `compare_to_previous` | A `fullstory:discover_groups` option that compares against the prior window of the same length. `comparison_mode` is `worsening` (default) or `improving`. Confirm the prior window returns non-zero values before trusting any change. |
| `metric_ids` | Limits `fullstory:discover_groups` to specific signals out of the nine standard ones. Use it when errors crowd out click signals in the area. |
| Instance ids | In `fullstory:get_opportunity`, the returned `insight_instance_id` is a different id from the `instance_id` you used to look it up. |
