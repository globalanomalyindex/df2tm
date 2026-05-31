#!/usr/bin/env bash
# Structural validation for the df2tm plugin. Exit non-zero on any failure.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
say() { printf '%-44s %s\n' "$1" "$2"; }

# 1) JSON files parse
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then say "json:$f" "OK"; else say "json:$f" "FAIL"; fail=1; fi
done

# 2) Hook script: syntax, executable, valid JSON output, exit 0
if bash -n hooks/handlers/session-start.sh 2>/dev/null; then say "hook:syntax" "OK"; else say "hook:syntax" "FAIL"; fail=1; fi
[ -x hooks/handlers/session-start.sh ] && say "hook:executable" "OK" || { say "hook:executable" "FAIL"; fail=1; }
TMP="$(mktemp -d)"
if DF2TM_STATE_DIR="$TMP/df2tm" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/handlers/session-start.sh \
   | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then say "hook:json-output" "OK"; else say "hook:json-output" "FAIL"; fail=1; fi
rm -rf "$TMP"

# 3) SKILL.md frontmatter has name + description, body is lean
if [ -f skills/df2tm/SKILL.md ]; then
  head -5 skills/df2tm/SKILL.md | grep -q '^name:' && say "skill:name" "OK" || { say "skill:name" "FAIL"; fail=1; }
  head -8 skills/df2tm/SKILL.md | grep -q '^description:' && say "skill:description" "OK" || { say "skill:description" "FAIL"; fail=1; }
  words=$(wc -w < skills/df2tm/SKILL.md); [ "$words" -lt 1200 ] && say "skill:words($words<1200)" "OK" || { say "skill:words($words)" "WARN"; }
else say "skill:exists" "PENDING"; fi

# 4) Command frontmatter
if [ -f commands/df2tm.md ]; then
  head -6 commands/df2tm.md | grep -q '^description:' && say "cmd:description" "OK" || { say "cmd:description" "FAIL"; fail=1; }
else say "cmd:exists" "PENDING"; fi

# 5) Science library has all three tiers
if [ -f skills/df2tm/references/science-library.md ]; then
  for t in "Tier 1" "Tier 2" "Tier 3"; do
    grep -q "$t" skills/df2tm/references/science-library.md && say "lib:$t" "OK" || { say "lib:$t" "FAIL"; fail=1; }
  done
fi

[ "$fail" -eq 0 ] && echo "ALL STRUCTURAL CHECKS PASSED" || echo "VALIDATION FAILED"
exit $fail
