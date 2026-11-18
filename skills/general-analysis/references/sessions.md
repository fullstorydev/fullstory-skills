# Session Investigation

Sessions answer "why", not "how many." Reach for them when:
- The user explicitly asks to see sessions
- A quantitative result raises a causal question — "why are rage clicks spiking on this page?"
- A funnel shows a drop-off and you need to know what happened at that step
- A journey shows a branch nobody expected
- You need to confirm or kill a hypothesis about what's driving a number

## Review sessions in an isolated context

Don't review sessions directly in the main conversation. Session data is large, and a handful of sessions will crowd out everything else you're holding. Review each one in a child context instead. The Fullstory plugin ships a **`session-context`** agent for exactly this, and any subagent or task mechanism your environment offers works the same way.

Give the isolated context two things:
- The `session_url` from the session list, exactly as returned
- A task describing what you want to learn

It reviews the session with `fullstory:review-open`, `fullstory:review-zoom`, `fullstory:review-snapshot` and `fullstory:review-close`. It falls back to `fullstory:get_session_events` for plain console error text, or when the review tools are missing or fail. It answers the task and returns just that. You synthesize across sessions in the main context, which stays small.

**More specific tasks get more useful answers.** When you have a hypothesis, tie the task to it:

| Instead of… | Write… |
|---|---|
| "Summarize this session" | "Did the user successfully submit the checkout form? If not, where did they stop and what did they interact with last?" |
| "What happened?" | "The user rage-clicked something on /checkout. What element did they click, and did anything visibly change on the page after?" |
| "Tell me about this session" | "Was there a JavaScript error in this session? If so, what was the message and what page was the user on?" |

## Where the sessions come from

| Starting point | Call |
|---|---|
| A metric | `fullstory:get_sessions(metric_id)`, for a metric with at most one segment |
| A cohort | `fullstory:get_sessions(segment_id)`, one cohort at a time. Use this for each cohort of a metric that compares several. |
| A funnel step, or the people who dropped at it | `fullstory:get_funnel_sessions(funnel_id, completed_step=N[, did_not_complete=true])` |
| A journey branch | `fullstory:get_sessions_for_journey(journey_id[, nodes=[...]])` |

Each returns `matching_sessions` and `matching_users` alongside the capped list, so you can say "showing 5 of 1,284" rather than implying the list is everything.

## Workflow

1. Pull 3–5 sessions from the appropriate entry point above
2. Review each in an isolated context with its `session_url` and a task
3. Look for patterns across the answers: same page, same element, same error, same sequence
4. Synthesize: "Rage clicks on checkout are concentrated on the 'Apply Coupon' button — in 4 of 5 sessions users clicked it repeatedly with no visible response"
5. Present session URLs as evidence for the conclusion, not as homework for the user

Start with 3–5. If the pattern is clear, stop. If it isn't, pull more — isolated contexts mean extra sessions cost you nothing in the main window. Use judgment on when the evidence is enough.

## Watching what the user saw

When the question is visual, like "did the error banner actually render?" or "what did the cart look like when they abandoned?", say so in the task. The isolated context snapshots the screen at the moments that matter. If your environment has no subagent or task mechanism, review the session yourself with the `session-review` skill's tools:

| Goal | Tool |
|---|---|
| Open a session | `fullstory:review-open` |
| See what happened in a time window | `fullstory:review-zoom` |
| See the screen at a moment | `fullstory:review-snapshot` |
| See what changed on screen | `fullstory:review-snapshot` at two timestamps, compare the trees |
| Close | `fullstory:review-close` |

Always close what you open, including when something errors partway through; the handle holds server-side state.
