#!/usr/bin/env bash
# df2tm SessionStart hook.
# Seeds state on first run, then prints a lean operating directive plus any
# concepts due for review as additionalContext. MUST always exit 0 with valid JSON.

set -u

STATE_DIR="${DF2TM_STATE_DIR:-$HOME/.claude/df2tm}"
MODEL="$STATE_DIR/learner-model.md"
TPL_DIR="${CLAUDE_PLUGIN_ROOT:-.}/templates"
TODAY="$(date +%F)"

# --- First-run seeding (best effort; never fail the session) ---
if [ ! -d "$STATE_DIR" ]; then
  mkdir -p "$STATE_DIR/journal" 2>/dev/null || true
  if [ -f "$TPL_DIR/learner-model.md" ] && [ ! -f "$MODEL" ]; then
    cp "$TPL_DIR/learner-model.md" "$MODEL" 2>/dev/null || true
  fi
fi

# --- Read intensity + due concepts defensively ---
INTENSITY="ambient"
DUE=""
DUE_COUNT=0
if [ -f "$MODEL" ]; then
  i="$(grep -m1 '^intensity:' "$MODEL" 2>/dev/null | sed 's/^intensity:[[:space:]]*//')"
  [ -n "${i:-}" ] && INTENSITY="$i"
  while IFS= read -r line; do
    status="$(printf '%s' "$line" | grep -oE 'active|muted|known' | tail -1)"
    [ "$status" = "muted" ] && continue
    [ "$status" = "known" ] && continue
    slug="$(printf '%s' "$line" | sed 's/^concept:[[:space:]]*//; s/[[:space:]]*|.*$//')"
    due="$(printf '%s' "$line" | grep -oE 'due:[0-9-]+' | sed 's/due://')"
    if [ -n "${due:-}" ] && [[ ! "$due" > "$TODAY" ]]; then
      DUE="${DUE:+$DUE, }$slug"
      DUE_COUNT=$((DUE_COUNT + 1))
    fi
  done < <(grep '^concept:' "$MODEL" 2>/dev/null || true)
fi

# --- Build the lean directive ---
DIRECTIVE="df2tm is active (intensity: ${INTENSITY}). As you do real work, weave in brief, skimmable teaching about concepts that are load-bearing and forward-useful for THIS work, following your df2tm skill: default woven-inline, escalate only when a concept is pivotal or the user engages, and stay silent when nothing is worth teaching. Mark teaching asides distinctly (a 🎓 lead-in) so they are skippable. Record worth-remembering concepts to ${MODEL} plus a one-line journal entry under ${STATE_DIR}/journal/. Steering phrases the user may use: 'teach me more/less', 'df2tm off/on', 'just do it', 'quiz me', 'why did you do that', 'debrief', 'I already know this'. Concepts due for review now (${DUE_COUNT}): ${DUE:-none}. Read the df2tm skill and its references when you need the full method, the toolkit, or the science library."

# --- Emit JSON safely (python3 if present, else a sed fallback) ---
json_escape() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  else
    printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$(json_escape "$DIRECTIVE")"
exit 0
