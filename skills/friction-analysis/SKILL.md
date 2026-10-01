---
name: friction-analysis
description: Finds where users struggle on a page or flow and whether a suspected problem is real. Ranks Fullstory's frustration and error signals, separates real problems from buttons people are meant to click many times, measures how many users each problem affects, and uses session replays to show what happened. Use when someone asks where users are struggling, what is broken on a page or flow, for top pain points or a friction audit, why users give up at a step, whether a rage click is real, whether pages feel slow, whether people keep retrying, re-typing or going back and forth, whether a mobile app keeps crashing, or whether a problem from support tickets is widespread or affects only a few people.
---

# Friction Analysis

## Goal

Find where users struggle and report problems the team can act on. Every finding needs:

- **A confirmation.** Frustration signals find leads; a Step 3 check confirms one before it becomes a finding.
- **An explanation** of what happened, from replay.
- **A size:** how many users were affected, out of how many.

## Related Skills

- `general-analysis`: metrics, segments, and count or trend questions with nothing suspected broken.
- `comparisons`: structuring an A vs B comparison; decides which signals are worth comparing.
- `session-review`: full diagnosis of a single session.
- `idea-generation`: what to build next, not what is broken.
- For a Fullstory Opportunities list, call `fullstory:get_opportunities` and stop.

## Step 1: Match the Depth to the Question

| If the question is like | Do this |
|---|---|
| "Is this rage click real?" | Run the Step 3 checks on that one element, then give a short, direct answer. |
| "Where do users struggle in checkout?" | Sweep every signal on that page or flow and rank them. |
| "Which pages have the most frustration?" | Sweep, then run Step 3 on the top two or three pages before reporting their order: confirm each page's leading element is a real control, not a container, and read one replay per page. |

If someone reports a page stuck loading, always run Step 3c, even when no frustration signal fires on that page. For anything else, stop once a Step 3 check and a replay support the answer.

## Step 2: Find the Signals

**Run the sweep.** Call `fullstory:discover_groups` scoped to the area.

**Set the time range once, and reuse it on every later call.** `fullstory:discover_groups` defaults to the last 24 hours, not whatever you used last. Use 30 days. If a 30-day call times out, switch to 7 days and call those results provisional.

**Use `fullstory:discover_groups`, not `fullstory:build_metric`, for click friction on a page.** A URL-path filter can silently return a fraction of the real count, because it misses pages whose URLs don't contain the path you guessed, and it raises no error. Funnels, custom-event counts, and signals with no built-in equivalent still need `fullstory:build_metric` or `fullstory:build_funnel`; a noise-only sweep is the cue to build one.

### Add one or two signals the sweep misses

Do this before stats or replays. The sweep returns rage, dead and error clicks by element, page refresh, abandoned form and app crash by page, network error by path, and uncaught exception and console error by text. That set misses struggle that looks different in a form, a search tool or a mobile app. Pick the rows below that fit the area, build each with `fullstory:build_metric`, `fullstory:build_segment` or `fullstory:build_funnel`, with exact numbers: "at least 2 times within 60 seconds," not "a few times quickly."

| If the area is | Check |
|---|---|
| A form, sign-up or checkout | the same field changed at least 3 times within 60 seconds; submit clicked twice within two minutes with a network error; slow load |
| Search or a list | the search box changed several times (group by search text for what people look for); back and forth between results and a detail page |
| A slow or content-heavy page | page-speed signals (Core Web Vitals and load times); thrashed cursor; a long active stretch with no clicks (rule out bots first) |
| A mobile app | crashes, force restarts, pinch to zoom (text too small), low memory; the app backgrounded within about 30 seconds of an error |
| Any page with error messages | an error message on screen that no error event records: watch the message element and group by URL |

Rank hits against the sweep's own groups in Step 4.

### Invent a signal if none of the built-in signals measure what was asked

Some struggle has no Fullstory signal: booking duration, redone work, a step finished only on a second visit. Define it as an event sequence, build it, compare it to a baseline group, confirm it in one replay, and state the definition in the answer.

### Check who produced the signals

Check the top groups for three things that skew a count: one city dominating, the company's own staff (users whose email is on the company's domain), and automated traffic. Segment automated traffic on Suspicious Activity signals rather than OS or user agent.

If automated traffic is a small share of a group, say nothing about it. If it is large enough to change the number, recompute the group without it and give both figures, since it changes how big a problem is, not whether the flow is broken. Never stop at "it's bots."

### An empty result is not proof of health

Three causes for a zero:

1. **Not captured in this account.** A missing signal returns nothing, not an error; on mobile, zero crashes or force restarts often means they aren't captured. Say so.
2. **Too few users affected.** Fullstory hides groups below a minimum affected-user count, higher on busier sites.
3. **The page is healthy.**

Rule out the first two before calling a zero good news.

## Step 3: Check Each Signal

### 3a. Check what was clicked

**Rage clicks fire on rapid repeated clicks in one spot, and some controls are built for exactly that:** pagination arrows, quantity steppers, carousel dots. Whether the element is broken is the next check.

**A dead click only matters on something that looks clickable.** Open a session, call `fullstory:session_get_a11y_tree` at the time of the click, and read the role: a `button` or `link` that did nothing is a finding, plain text or a container is not. An element named for a whole screen or card absorbs every click inside it, so confirm in replay what was hit.

**Get the element's total clicks before calling a dead-click count high or low.** Thirteen out of 50 is a problem; thirteen out of 13,000 is not.

### 3b. Compare against a baseline

Measure the same behavior where it should be ordinary: if users who reloaded after a failed request do so at about the rate of users who reloaded after any request, the reloads are routine. Build a funnel to find where a flow stops.

**Run the signals against users who completed the flow, not only those who dropped out.** A completion rate shows people got through, not that it was easy. A signal at the same rate in both groups is not what causes drop-out; heavy rage clicking alongside healthy completion means people finish and it costs them. Pull completer replays that carry frustration signals.

### 3c. Look for failures that leave no click signal

A request that never returns, or one that fails into an empty state like "No results found," produces no dead click and no error click. Believe a report of a stuck page with clean signals and watch two or three sessions: a stalled page reads as repeated clicks, a long wait, then the user leaving.

**Watched elements can put a number on this.** A watched element fires `RENDERED` on entering the DOM and `VISIBLE` on entering the viewport, each with a duration (`element_render_duration`, `element_visible_duration`). Two readings matter:

- **Visible duration on a loading element** (spinner, skeleton, progress bar) measures a stalled request directly; no click signal catches that.
- **A large gap between rendered and visible counts** means the element is on the page and users aren't seeing it.

Scan watched element names for a state nobody wants: loading, spinner, skeleton, progress, error, warning, invalid, failed, retry, empty, no results, unavailable. No duration threshold is published, so compare against the same element on a working page. If the useful element isn't watched, say so in Step 5.

## Step 4: Measure and Explain

### Measure

Call `fullstory:get_opportunity_stats` with the group's ids, plus the sweep's scope and time range. A signal you built in Step 2 has no group ids, so size it with `fullstory:compute_metric` or `fullstory:compute_funnel` instead. `frustration_rate_change` and `error_rate_change` compare sessions that hit the problem to sessions on the same page that didn't; they contrast two groups, not a trend.

| frustration | error | Reads as |
|---|---|---|
| High | Flat or negative | The control confuses people. Design owns it. |
| High | High | Something is failing and frustration follows. Engineering owns it. |

Ignore `error_rate_change` on an error-type signal (network error, uncaught exception, console error): every affected session has an error by definition, inflating the number by construction. Read frustration only.

### Keep numbers comparable

Compare two time ranges ending today before calling a problem stopped. Name every denominator and match it to the question: `user_pct` is a share of your scope, `user_percentage_on_page` a share of that page's visitors. Never reuse a share computed for a different scope.

Before saying slowness drives people away, compare outcomes after slow loads against fast ones, such as reload or exit rate: same-page slow loads and reloads don't prove causation.

**Read a web vital against its neighbours,** not alone: against Google's band, and against the same vital on the pages either side of it in the flow. A slow page between two fast ones is a bottleneck worth fixing; a slow page between two equally slow ones is site-wide, and fixing it moves nothing. Bands: LCP good at or under 2.5s, poor over 4s; CLS good under 0.1, poor over 0.25; INP good at or under 200ms, poor over 500ms. INP replaced FID in March 2024; do not report FID.

### Explain with replay

Pull 2 to 3 sessions per finding with `fullstory:get_sessions_for_opportunity`, passing the same scope as the sweep so the replays come from the surface you measured, and copy each `session_url` exactly. For a signal you built in Step 2, use `fullstory:get_sessions` or `fullstory:get_funnel_sessions`.

**Never describe a session you cannot link.** If a sentence says what a user did, the `session_url` goes next to it. "Session available on request" means you did not open one, so cut the sentence.

Pull more than you need and replace any session that turns out to be a different problem, automated, or an unrelated exit. Never count one you dropped.

Events don't show the screen; for any claim about what a user saw, call `fullstory:session_open`, `fullstory:session_screenshot` at that moment, then `fullstory:session_close`. Two identical screenshots from different times mean the tool returned the wrong frame; fall back to event order and say so. Before recommending an error message, check whether one already appears.

### Check the group is big enough to report

Before a group becomes a finding, set its affected users against the page's total visitors over the same window. Four users on a page with 200 monthly visitors is noise no matter how large its frustration lift or how high it ranks. Ranking first in a scoped sweep only means nothing bigger turned up, and on a low-traffic surface the whole list can be noise.

Once a group clears that bar, rank by what happened to the user, not by count alone: open a session where the signal fired and watch the minute after it.

If nothing on the surface clears the bar, say the surface is quiet on friction signals and go measure how many people start the thing against how many finish it. That gap is a finding; a four-user dead click is not.

### Do not name a cause from one session

Two sessions have to show the same sequence before you name a cause. One session is a lead and you label it as one.

Describe only what the events record. A screenshot shows what was on screen, not why, so do not write that a control was disabled, that an overlay swallowed a click, or that a user clicked again and got nothing, unless separate events show it. Never attach behavior you did not observe to a named user or account.

## Step 5: Write the Answer

1. **Answer first:** where the flow breaks and why, in one or two sentences.
2. **Top three findings,** each with users affected and their share of the page's visitors, what replay showed, what rules out competing explanations, the fix, and what to log to confirm it worked.
3. **Full signal table** with users, share and events.
4. **Why nobody caught it:** name what the team measures that missed this, a broken metric or an aggregate that hides it.
5. **Also checked:** each extra or invented signal from Step 2 and what it showed. Fold into another section if that reads better.
6. **Leads,** one line each.

Skip tool notes and workarounds unless they change the answer.

## Tool Notes

- Pass `default_metric_id`, `group_id` and `group_id_fallback` together; dropping one silently matches the wrong group.
- `compare_to_previous` can report every group as new. Compare two explicit time ranges instead.
- `group_id_fallback: true` means the name is a CSS selector. Name the element from replay.
- Page load time reads 1ms when the page never finished loading, so filter with "at least".
- `/create/` links can't be opened by others; save the object or link the replay.
