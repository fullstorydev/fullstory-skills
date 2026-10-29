---
name: session-review
description: Use when diagnosing user-reported issues, investigating bugs, analyzing user behavior, or validating UI correctness using Fullstory session recordings.
---

# Session Review

Review Fullstory sessions to understand what happened — whether diagnosing a customer-reported bug or validating UI changes during development.

## When to Use

- User reports a bug and provides a session URL
- Investigating an error or unexpected behavior
- Understanding user flow through the application
- Debugging issues that are hard to reproduce
- Validating UI changes locally after testing

## MCP Tools

| Goal | Tool |
|------|------|
| Open a session | `fullstory:review-open` |
| See what happened in a time window | `fullstory:review-zoom` |
| See the screen at a moment | `fullstory:review-snapshot` |
| See what changed on screen | `fullstory:review-snapshot` at two timestamps, compare the trees |
| Close | `fullstory:review-close` |

## Workflow

### 1. Open the Session
```
fullstory:review-open(session_url="https://app.fullstory.com/ui/<org-id>/session/<device-id>:<session-id>")
```
Returns: a map of the session, an event slice, and a `client_id`.

Pass the whole URL as `session_url`. Here `session_id` means only the session part and must come with `device_id`. Other ways to open: `trace_id`, `trace_url`, `email_address`, `user_uid`.

### 2. Identify Key Moments
Scan the returned events for:
- **Page navigations** — entry points into different views
- **Click events** — user interactions with buttons, links, forms
- **Error events** — console errors, network failures, renderer errors
- **Rage clicks / mouse thrash** — signs of UX friction
- **Custom events** — application-specific telemetry

To read more of one stretch, narrow by time:
```
fullstory:review-zoom(client_id="<id>", t0_ms=<start_ms>, t1_ms=<end_ms>)
```

### 3. Visual Inspection
At each key moment, use `fullstory:review-snapshot` to see what the user saw. It finds the page from the timestamp, so you never pass a page id:
```
fullstory:review-snapshot(client_id="<id>", timestamp=<ms>)
```
It returns a screenshot and the component tree. Use the tree when you need element structure (roles, labels, hierarchy).

Check for:
- Layout correctness (elements positioned properly)
- Content rendering (text, images, icons present)
- Responsive behavior (no overflow, proper sizing)
- Empty/loading states handled

### 4. Compare States
For before/after analysis, take a snapshot at each timestamp and compare the two trees:
```
fullstory:review-snapshot(client_id="<id>", timestamp=<before_ms>)
fullstory:review-snapshot(client_id="<id>", timestamp=<after_ms>)
```
Whole trees are large. To keep the comparison cheap, focus on one element with `component_id` from an earlier snapshot, or ask for the interactive elements only with `lens="interactive"`.

### 5. Report Findings
Summarize what was observed:
- What the user saw at each key moment
- Any errors, visual regressions, or unexpected behavior
- Root cause analysis if diagnosing a bug
- Confirmation of correctness if validating changes

### 6. Cleanup
Always close the session:
```
fullstory:review-close(client_id="<id>")
```

## Example

When a user reports "the checkout button didn't work" and provides a session URL:

1. Call `fullstory:review-open` with `session_url`
2. Find the checkout-related events (note the timestamps)
3. Use `fullstory:review-snapshot` to see the UI state just before the button click
4. Take a second snapshot just after the click and compare the trees to see what changed (or didn't)
5. Report findings: what the user saw, any errors, why the action may have failed
6. Call `fullstory:review-close` to clean up

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting to close session | Always call `fullstory:review-close` — even on errors |
| Random timestamp access | Use sequential increasing timestamps for faster access |
| Passing the session URL as `session_id` to `fullstory:review-open` | Use `session_url` for a URL. `session_id` is only the session part and needs `device_id` |
| Taking whole-page snapshots to compare states | Focus with `component_id` or `lens="interactive"` |
| Not checking for error events | Scan the events for errors before visual inspection |

