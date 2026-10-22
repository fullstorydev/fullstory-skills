# Session Investigation

Sessions answer "why", not "how many." Reach for them when:
- The user explicitly asks to see sessions
- A quantitative result raises a causal question — "why are rage clicks spiking on this page?"
- A funnel shows a drop-off and you need to know what happened at that step
- A journey shows a branch nobody expected
- You need to confirm or kill a hypothesis about what's driving a number

## Read sessions in an isolated context

Never call `fullstory:get_session_events` directly in the main conversation. A session transcript is large, and a handful of them will crowd out everything else you're holding. Load each one in a child context instead — the Fullstory plugin ships a **`session-context`** agent for exactly this, and any subagent or task mechanism your environment offers works the same way.

Give the isolated context two things:
- The `session_id` (or `session_url`) from the session list, exactly as returned
- A task describing what you want to learn

It calls `fullstory:get_session_events`, answers the task, and returns just that. You synthesize across sessions in the main context, which stays small.

**More specific tasks get more useful answers.** When you have a hypothesis, tie the task to it:

| Instead of… | Write… |
|---|---|
| "Summarize this session" | "Did the user successfully submit the checkout form? If not, where did they stop and what did they interact with last?" |
| "What happened?" | "The user rage-clicked something on /checkout. What element did they click, and did anything visibly change on the page after?" |
| "Tell me about this session" | "Was there a JavaScript error in this session? If so, what was the message and what page was the user on?" |

## Where the sessions come from

| Starting point | Call |
|---|---|
| A metric | `fullstory:get_sessions(metric_id)` |
| A cohort | `fullstory:get_sessions(segment_id)` |
| A funnel step, or the people who dropped at it | `fullstory:get_funnel_sessions(funnel_id, completed_step=N[, did_not_complete=true])` |
| A journey branch | `fullstory:get_sessions_for_journey(journey_id[, nodes=[...]])` |

Each returns `matching_sessions` and `matching_users` alongside the capped list, so you can say "showing 5 of 1,284" rather than implying the list is everything.

## Workflow

1. Pull 3–5 sessions from the appropriate entry point above
2. Load each in an isolated context with its `session_id` and a task
3. Look for patterns across the answers: same page, same element, same error, same sequence
4. Synthesize: "Rage clicks on checkout are concentrated on the 'Apply Coupon' button — in 4 of 5 sessions users clicked it repeatedly with no visible response"
5. Present session URLs as evidence for the conclusion, not as homework for the user

Start with 3–5. If the pattern is clear, stop. If it isn't, pull more — isolated contexts mean extra sessions cost you nothing in the main window. Use judgment on when the evidence is enough.

## Watching what the user saw

When the question is visual — "did the error banner actually render?", "what did the cart look like when they abandoned?" — the event transcript won't answer it. That's the `session-review` skill's territory: `fullstory:session_open` → `fullstory:session_screenshot` / `fullstory:session_get_a11y_tree` / `fullstory:session_diff` → `fullstory:session_close`. Always close what you open, including when something errors partway through; the handle holds server-side state.
