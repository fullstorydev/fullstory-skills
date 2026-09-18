---
name: idea-generation
description: Finds the high-impact product proposals a team has not already had, by searching the analytics objects they already built, building the ones that turn out to be missing, sizing what turns up, then pulling session replays for the finalists. Returns ranked proposals, each with what is new about it, a number against a baseline, and replay links the reader can show someone else. Use when someone asks "what should we build next", "where should we improve", "find opportunities", "what are we missing", "turn this into proposals", "what changed since the release", or wants a recurring opportunity report for a flow. Consumes settled analysis from sister Fullstory MCP skills rather than re-deriving it. For measurement use general-analysis, for comparison mechanics use comparisons, and for one session use session-review.
---

# Idea Generation

## Mental Model

The obvious proposals are already on someone's radar. The biggest drop-off step, the top rage-click element, the noisiest error page — the team has seen those and usually already decided about them, so proposing them back costs credibility. This skill finds the proposals nobody has had yet, in three phases:

- **Find leads — cheap and broad.** Objects are the efficient layer: one call reads a definition the team already agreed on, a second computes it, and building a new one costs about the same. Most of a run happens here.
- **Size each lead — narrow to what is worth arguing about.** A lead becomes a candidate once you know how many users it touches and what that number looks like next to a fair comparison.
- **Support the finalists — expensive, so spend it last.** Replays explain a mechanism you have already sized. A size with no mechanism is a metric the team already has; a mechanism with no size is an anecdote.

A lead has to be **interesting, actionable and sizeable** — not already on their radar, changeable by the reader, and countable. Anything failing one of the three is an observation.

**Work with the sister skills rather than redoing them.** Counts, rates and trends are `general-analysis`. Comparison mechanics are `comparisons`; this skill decides what is worth comparing. A deep single-session diagnosis is `session-review`.

## Phase 1: Frame

**Name the question you are answering, in one line, before anything else.** Most asks contain several. "Improve retention" can mean *do these users convert worse*, or *does anything bring them back*, and those need different leads and produce different proposals. Pick the reading that matches what the user said, say which you picked, and note the one you set aside.

**A retention question is not a first-experience question.** Defects in a flow answer activation and onboarding, and fixing every one of them still gives nobody a reason to come back. If the ask is about repeat use, one lead has to be about re-entry: what pulls a user back on its own schedule, how many have it, and what the returners set up that the others never did.

**Ask at most two things, in one message, in your own words, and skip whatever the request already answered:**

> Which flow or product area should I look at, and over what window?
>
> And what do you already know here — anything on a dashboard, in the backlog, shipped recently, or in flight? I won't propose any of it back to you.

The second question is what makes this skill work: everything the team already knows is the baseline you have to beat. If they cannot produce it, build the list from Phase 2 and confirm it before ranking. Do not ask permission to run — pick the coverage the question deserves, run it, and report what you swept.

**Pin these five before computing anything, and do not move them once a number exists:**

```
POPULATION  — who is in the cohort, by the exact filter that selects them
OUTCOME     — the single event or page that counts as the thing happening
WINDOW      — the date range, identical for every number in the run
DENOMINATOR — the number is a share of what, named explicitly
BASELINE    — who you compare against, and why they are comparable
```

Without this, one question asked twice produces two different rates against two different baselines, one run concluding the cohort underperforms and the other that it outperforms, with no wrong query anywhere and nothing in the output a reader could use to tell. Watch the three places it goes wrong: **the outcome** (completing an action, saving it, and coming back to repeat it are different events, so name the one you mean), **the baseline population** (the same surface and the whole org are different populations, and only the first is a fair comparison), and **the unit** (per-view and per-user are different numbers).

**Note who acts on this and filter to what they can change.** A backend outage is not a design team's proposal even when it is the biggest number on the page. Infer the audience rather than asking.

## Phase 2: Find Leads

**Check what already distinguishes the cohort before building anything to select it.** Captured traffic usually separates the group you care about on its own — a URL path or parameter, a page, a device, a referrer, a custom variable. Where it does, that is the cheapest cohort in the run. Never conclude a cohort cannot be isolated before checking, and when nothing distinguishes it, say so up front, because any mechanism you then find is real for the surface and unproven for the group.

**Then search what the team already watches.** `fullstory:get_metric` and `fullstory:get_segment` take a name `regex`, return `total_matched`, and page with `limit` (default 10, max 25) and `offset`; `fullstory:get_managed_funnels` lists the funnels. Search the flow's vocabulary, not one guessed term. Do not pass `owned: true` — it scopes to your own objects, not the team's.

Judge what comes back on whether it answers the question, not on whether it exists. A metric scoped wrong or a funnel missing your step is not a match. **Where nothing strong exists, build it** — `fullstory:build_funnel` across the uncovered steps, `fullstory:build_journey` around the pivot, `fullstory:build_metric` on the unmeasured event, `fullstory:build_segment` for the cohort nobody has drawn. Ask what you would need to see and make exactly that. Do not build a near-duplicate of something the search already found.

**Walk the flow for steps with no object on them at all.** An unmeasured step is where nobody has proposed anything, because nobody could see it. This is often the highest-yield part of a run.

Then compute and look for one of these:

| Lead | How to spot it |
|---|---|
| **A number that moved** | Compute against a prior period or by dimension. A metric that broke trend, or diverges sharply between slices, is the strongest lead there is. |
| **A path that splits** | `fullstory:compute_journey` returns the pivot, per-step branching with each event's share of the previous step, and `popular_paths`. Users reaching one outcome by very different routes is a lead. Raise `steps` (default 4, max 10) and `per_step_limit` (default 5, rest roll into "Other") when the interesting branch is being swallowed. |
| **Nothing brings them back** | What would return a user on their own schedule — a notification, a saved view someone else reads, a digest, a shared link — and how many have one. A surface with no return mechanism cannot retain anyone however good the first visit is, and that absence never appears as friction. |
| **A stale or ignored object** | `fullstory:get_view_counts` takes up to 10 ids and a `days` window (default 30, max 90), `metric` and `segment` only. An object the team built and stopped opening is a solved problem or an abandoned question; the second is a lead. |

**Last, sweep for signals nobody built an object for.** `fullstory:discover_groups` returns the top frustration and error groups and takes a `scope` object where `page_ids`, `domains`, `app_names` and `url_paths` are plural and combinable, while `segment_id` and `funnel_id` are mutually exclusive with each other.

**Qualify before sizing.** Drop anything failing interesting, actionable or sizeable, then check it against the already-known list and against `fullstory:get_opportunities` — what Fullstory has already ranked is on the team's radar by definition, so it confirms and sizes rather than becoming a proposal.

**Some of these tools may not be available in your org, and the signal is absence, not an error.** `fullstory:get_opportunities`, `fullstory:get_opportunity`, `fullstory:get_pages` and `fullstory:get_managed_funnels` are not present for every org. Where they are unavailable they are filtered out of the tool list entirely, so you never see them rather than get an error or an empty result. Check what you actually have before planning around them, and note that this costs you `get_managed_funnels`, which the object search above leans on — fall back to `fullstory:get_metric` and `fullstory:get_segment` by regex plus the funnels the user names. `fullstory:discover_groups`, `fullstory:get_opportunity_stats` and `fullstory:get_sessions_for_opportunity` are always present; they compute from recorded data at call time and work wherever there is traffic, so when the others are missing these are the whole lead layer and the run loses only the pre-ranked list.

**An empty result is a different thing from a missing tool.** If `get_opportunities` is present and returns nothing, that is an org with nothing stored rather than an org that does not have the tool, which also silently weakens the already-known check above. Say which case you were in.

**If a cohort is defined by exclusion, validate it.** "Did not convert" leaks, because products usually offer several routes to one outcome and the segment excludes one. Sample 8 to 10 sessions and check whether the outcome happened anyway by any route; above roughly 10%, fix the definition. Exclude the confirmation the user actually *sees*, in every locale and variant, rather than one named event or element. Relaxing a scope filter for volume is fine and gets logged; relaxing the filter that *defines* the cohort changes the question and goes to the user.

## Phase 3: Size, Then Support

`fullstory:get_opportunity_stats` computes fresh statistics from a `discover_groups` tuple: `users_affected`, `session_count`, `user_percentage`, and page, device and domain breakdowns. Prefer `user_percentage_on_page` — the share of users *on that page* — over `user_percentage`, which flatters a problem on a low-traffic page. `frustration_rate_change` and `error_rate_change` compare affected users against unaffected ones, which is a contrast needing no second cohort. For a lead from a funnel or metric, size it with `fullstory:compute_funnel` or `fullstory:compute_metric` instead.

**Every number carries its denominator and window into the output.** A number nobody can re-derive is not evidence, and one a second run would contradict is worse than none.

**Then pull replays, for the leads you intend to present and nothing else.** Replay explains a mechanism you have already sized; it is not how you find one. But every proposal ships with a replay link, so a lead you will not spend replays on is a lead you will not propose. Three to five per finalist is usually enough to see a mechanism repeat. Use `fullstory:get_sessions_for_opportunity` or `fullstory:get_sessions`, keep every `session_url` verbatim, and never hand-construct one.

Read each session against the same short list of questions so the returns can be tallied rather than re-read: what the user was trying to do, the timestamped path, **whether this session confirms the pattern, contradicts it, or shows a different cause**, any workaround they invented, anything no event would capture, and one concrete change. Two things keep that pass honest. **A negative is a real answer** — asked to find friction an agent will find some, so a run where every session confirms has measured the instruction rather than the product. And **name the interactions where repetition is normal** before you start, such as steppers, carousel dots, sliders and pagination, or the run reports design as breakage.

**Check the activity level before reading anything into an absent signal.** A cohort averaging a handful of clicks per session cannot produce rage clicks, dead clicks or error clicks, so zero of them is arithmetic rather than reassurance, and a silent failure produces exactly this shape. Report the interaction count alongside any claim that rests on a signal being absent.

**Exclude automated traffic before computing anything.** Monitoring tabs, synthetic checks and scrapers sit on a page for hours without acting and will dominate a small cohort's averages and dwell times. Check what the long sessions actually are before a handful of them carries a finding.

**A backend failure is out of scope, but what the interface does when it fails is in scope and is often the finding.** If a request fails and the UI shows nothing, keeps accepting input, or silently loses the user's work, that is a product fix even though the trigger is not. Only skip it when a perfectly reliable backend would leave nothing to change.

If a finalist's replays show a different mechanism than the number implied, that is the finding. Re-size it before ranking.

## Phase 4: Rank and Deliver

Four checks, run by reading your own list. Report the drop counts in caveats, not the body.

- **Already known.** Match every candidate against the Phase 1 list and everything `get_opportunities` surfaced, and drop any hit. If it shipped and is still happening, name it a regression.
- **Evidence.** Every proposal carries at least one replay link from this run, never recalled or constructed. A full proposal needs two independent sources — a computed object is one, an Opportunity or replays or a support theme or a prior run is another. Single-source patterns go to **Emerging Signals**, not the bin.
- **Comparison.** A number with nothing beside it is not a finding. If nothing sits beside it yet, go compute a fair baseline before ranking it. Then rule out a partial window read as a trend, seasonality, a launch or ramp effect, bots, and too small a sample.
- **Novelty.** Write the one-line *why it's new*: what this says that their metrics, dashboards and backlog do not. If the answer is nothing, it is an observation, so cut it or drop it to one line in Emerging Signals.

**Order by judgment and say why.** How many users it touches, whether it is getting worse, and how hard it looks to change. When you cannot tell whether it is worsening — a prior-period comparison is often unavailable on sparse data and frequently returns zero for every group, which is an empty window and not a collapse — drop the deltas, rank on share-of-surface and per-user consequence, and name the fallback you used. **Do not compute a composite score.** Multiplying a real user count by an invented effort weight produces false precision and hides the judgment instead of showing it.

**Apply all of this hardest to the headline figure.** Whatever number leads the document needs its denominator, its definition and its comparison more than anything below it, and needs to appear in the body rather than only in the summary.

```
[Title, <= 10 words, names the change, not the problem]
- What: the change in one sentence, specific enough to hand to someone who would build it
- Why it's new: what this says that their metrics, dashboards and backlog do not
- Size: users affected per period AND the baseline beside it
- Mechanism: what is actually happening, in one or two sentences
- Moves: the one measurable behavior, with a direction. If you cannot name one,
  tag it DECORATION and rank it last
- Next: what the reader does with this — validate something specific, hand it to
  eng, or take it upward — with the rough size of the change
- Watch: 2-3 replay links as `[label @mm:ss](session_url)`, each with one line of
  what the reader will see
```

**Write for where the proposal is going.** The reader will look into it further, hand it to the people who would build it, or put it in front of someone they report to. It is finished when it survives all three without them reconstructing it.

**The shape of the artifact is not the shape of the run.** These phases are how you found the answer; they are not headings. Do not walk the reader through searching, sizing and gating, do not list the objects you built, and do not give the same recommendation in a summary and again in a body. Organise around what they have to decide. Everything about how the work was done — what you swept, dropped, read or created — goes in a short caveats note or nowhere.

Present the top 3 to 5, then Emerging Signals in one line each. Fifteen ranked items is a research backlog. Save and name any object you link to; clean up the rest silently. If the team has a tracker, write there newest-first, merging a repeat finding into its existing entry rather than filing it twice.

## Tool Notes

Verified behaviours that cost a run when missed.

| | |
|---|---|
| `discover_groups` tuple | Returns `(default_metric_id, group_id, group_id_fallback)`. Carry all three; dropping the fallback boolean silently mismatches the group. |
| Scope consistency | `get_opportunity_stats` and `get_sessions_for_opportunity` both take `scope`. Pass the one you gave `discover_groups`, or the stats describe the whole org. |
| Percentages do not match | `discover_groups.user_pct` is a share of the scope you queried; `user_percentage_on_page` is a share of the page's traffic. Say which denominator each number uses. |
| Which tools are always there | `get_opportunities`, `get_opportunity`, `get_pages` and `get_managed_funnels` are not present for every org, and where they are absent they are hidden from the tool list rather than erroring. `discover_groups`, `get_opportunity_stats` and `get_sessions_for_opportunity` are always available. |
| `get_opportunities` percentages | `user_percentage` and `event_percentage` populate only on the segment-scoped path, returning zero elsewhere, and even then they are org-wide shares. Never report "0% affected". |
| `get_sessions_for_opportunity` defaults | `limit` 10 (max 50), window 24 hours. Set both to match the run. |
| `dropout_at_step` | Lives in `scope`. 0 is the default and means the LAST step, a full dropout, not the first. |
| `compare_to_previous` | `comparison_mode` picks `worsening` (default) or `improving`. Check the prior window returns non-zero before trusting any delta. |
| `metric_ids` | Narrows `discover_groups` to specific signals out of the nine standard ones, which stops an error-heavy surface crowding out interaction signals. |
| Instance ids | A record's `insight_instance_id` is a different identifier than the `instance_id` you looked it up with. |
| Drafts | Objects built through the MCP return unsaved `/create/` URLs, so save and name anything you link to. |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Answering before naming which question you are answering | Most asks contain several. Pick one, say which, note what you set aside. |
| Answering a retention question with a list of first-run defects | Fixing the first visit gives nobody a reason to return. Sweep for what brings users back. |
| Computing before the five definitions are pinned | This is how one question asked twice reaches opposite conclusions. |
| Going straight to replays | Objects are cheap and broad, replay is expensive and narrow. Replays are for the finalists. |
| Concluding a cohort cannot be isolated without checking what already separates it | A path, parameter or property already in captured data is the cheapest cohort available. |
| Proposing the biggest drop-off step or the top rage-click element | That is the radar. Say what is new about it, or cut it. |
| Settling for an object that nearly fits, rebuilding one that does, or sweeping only what exists | Search first, use a real match, build what the search did not turn up — including on the steps nobody measured. |
| Ranking by raw frequency, or by a composite score | Volume is what the dashboard already sorts by. State size, direction and effort separately. |
| Mixing per-view with per-user, or baselining against the whole org | Name the unit on every rate. The fair baseline differs only in the thing you are studying. |
| A proposal with no replay link | The number says how big it is; the replay is what lets the reader show someone else. |
| Trusting a "did not convert" segment | Validate it before building on it. Exclude the confirmation the user sees, in every locale. |
| Putting the sweep inventory or your scratch objects in the deliverable | Accounting goes in a caveats note. The body is the proposals. |
| Reading zero frustration signals as "nothing is wrong" | On a low-activity cohort that is guaranteed by arithmetic. Report the interaction count next to the claim. |
| Letting a monitoring tab or scraper into a small cohort | It will own the dwell times. Check the long sessions before trusting an average. |
| A headline figure with no denominator, definition or comparison | The lead number needs these most, and needs to appear in the body, not only the summary. |
| Assuming the Opportunity tools are there | Four of them are absent in some orgs, `get_managed_funnels` among them, and they vanish from the tool list rather than erroring. Check what you have before planning the sweep around it. |
| Surfacing refreshes and scroll depth as findings | Apply the interesting-actionable-sizeable bar and cut what a user would not call a problem. |
