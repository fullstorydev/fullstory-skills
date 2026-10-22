#!/bin/sh
# Limits the session-context agent to get_session_events. Clients prefix MCP
# tool names differently (plugin name, user-chosen server name, per-install
# UUID), so match on the tool name's suffix instead of a fixed tools list.
# Allows everything when the input has no agent_type, so other callers and
# clients that don't send it are unaffected.

input=$(cat)

# Extract the agent_type value properly (first occurrence only) to avoid
# matching session-context appearing elsewhere in the payload (e.g., in tool inputs).
agent_type=$(printf '%s' "$input" | grep -o '"agent_type" *: *"[^"]*"' | head -n1 | sed 's/.*: *"\([^"]*\)".*/\1/')

case "$agent_type" in
  *session-context) ;;
  *) exit 0 ;;
esac

# Extract tool_name value properly (first occurrence only).
tool=$(printf '%s' "$input" | grep -o '"tool_name" *: *"[^"]*"' | head -n1 | sed 's/.*: *"\([^"]*\)".*/\1/')

case "$tool" in
  *get_session_events) ;;
  mcp__* | Bash | Write | Edit | NotebookEdit | WebFetch | WebSearch | Agent)
    printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"session-context may only call get_session_events"}}'
    ;;
esac

exit 0
