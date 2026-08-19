#!/usr/bin/env bash
# Claude adversarial critic invocation for the critic-gauntlet skill.
#
# Usage: claude-critic.sh <decisions-folder> <round-number>
# Example: claude-critic.sh /path/to/decisions/ADR-002-bar 1
#
# Part of the unified critic-script family shared by critic-gauntlet and
# waterfall-lint. Reads brief-v<N>.md and proposal-v<N>.md from the work folder.
# On round 2+ it also appends prior-round critiques and syntheses UNLESS
# prior-round context is disabled (--no-prior-rounds, or automatically in
# --mode qa; see the note above the prior-round block). Builds the prompt, runs
# the Claude Code CLI in headless print mode (-p), writes critique-v<N>-claude.md.
#
# This is the Claude-critic path for hosts WITHOUT the Agent tool (Codex, or any
# other orchestrator). Inside Claude Code, prefer the gauntlet-critic subagent;
# both paths are least-privilege (here, the model gets NO tools at all: content
# is piped in and this script writes the one output file itself).
#
# BILLING: this routes through the `claude` CLI, which uses your Max-subscription
# OAuth session, NOT the metered Anthropic API. ANTHROPIC_API_KEY is deliberately
# scrubbed from the CLI subprocess (env -u) so that even if the key is present in
# the environment, the critic can never silently bill the API. Do not "fix" an auth
# failure by adding the key back: log in to Claude Code instead (`claude` once,
# interactively). See SKILL.md billing guardrail.

set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <work-folder> <round-number> [--mode architecture|science|editorial|qa] [--no-prior-rounds]" >&2
    exit 1
fi

DIR="$1"
ROUND="$2"
shift 2

MODE="architecture"
NO_PRIOR_ROUNDS=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --mode) MODE="$2"; shift 2 ;;
        --no-prior-rounds) NO_PRIOR_ROUNDS=1; shift ;;
        *) echo "ERROR: unknown argument: $1" >&2; exit 1 ;;
    esac
done

# qa mode is the waterfall-lint rubric. In a waterfall the artifact is
# REGENERATED between passes, so a prior critique describes a page that no
# longer exists. So qa mode ALWAYS runs without prior-round context; the flag
# exists for any other mode that needs the same isolation.
if [ "$MODE" = "qa" ]; then
    NO_PRIOR_ROUNDS=1
fi

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_FILE="$SKILL_DIR/modes/${MODE}.system.txt"
if [ ! -f "$SYSTEM_FILE" ]; then
    echo "ERROR: unknown mode '$MODE' (no $SYSTEM_FILE)" >&2
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "ERROR: work folder not found: $DIR" >&2
    exit 1
fi

BRIEF="$DIR/brief-v${ROUND}.md"
PROPOSAL="$DIR/proposal-v${ROUND}.md"
OUTPUT="$DIR/critique-v${ROUND}-claude.md"

if [ ! -f "$BRIEF" ]; then
    echo "ERROR: brief not found: $BRIEF" >&2
    exit 1
fi
if [ ! -f "$PROPOSAL" ]; then
    echo "ERROR: proposal not found: $PROPOSAL" >&2
    exit 1
fi

# Resolve the claude CLI binary (subscription auth lives inside it).
CLAUDE_BIN="${CLAUDE_BIN:-}"
if [ -z "$CLAUDE_BIN" ]; then
    if command -v claude >/dev/null 2>&1; then
        CLAUDE_BIN="$(command -v claude)"
    elif [ -n "${CLAUDE_CODE_EXECPATH:-}" ] && [ -x "${CLAUDE_CODE_EXECPATH}" ]; then
        CLAUDE_BIN="$CLAUDE_CODE_EXECPATH"
    elif [ -x "$HOME/.local/bin/claude" ]; then
        CLAUDE_BIN="$HOME/.local/bin/claude"
    else
        echo "ERROR: claude CLI not found on PATH, CLAUDE_CODE_EXECPATH, or ~/.local/bin." >&2
        echo "Install Claude Code and run 'claude' once to log in to your subscription." >&2
        exit 1
    fi
fi

# Optional model override. If unset, the CLI uses your configured session model.
MODEL_LABEL="default CLI session model"
MODEL_ARGS=()
if [ -n "${CLAUDE_CRITIC_MODEL:-}" ]; then
    MODEL_ARGS=(--model "$CLAUDE_CRITIC_MODEL")
    MODEL_LABEL="$CLAUDE_CRITIC_MODEL"
fi

# Collect prior-round artifacts if this is round 2+ (skipped when prior-round
# context is disabled; see the qa-mode note above)
PRIOR_CONTEXT=""
if [ "$NO_PRIOR_ROUNDS" -eq 0 ] && [ "$ROUND" -gt 1 ]; then
    PRIOR_ROUND=$((ROUND - 1))
    for f in "$DIR/synthesis-v${PRIOR_ROUND}.md" "$DIR/critique-v${PRIOR_ROUND}-claude.md" "$DIR/critique-v${PRIOR_ROUND}-codex.md" "$DIR/critique-v${PRIOR_ROUND}-grok.md" "$DIR/critique-v${PRIOR_ROUND}-gemini.md" "$DIR/critique-v${PRIOR_ROUND}-deepseek.md"; do
        if [ -f "$f" ]; then
            PRIOR_CONTEXT="$PRIOR_CONTEXT

===== $(basename "$f") =====
$(cat "$f")"
        fi
    done
fi

DATE=$(date +%Y-%m-%d)

# System prompt = mode rubric with placeholders substituted. This critic's identity.
SYSTEM_PROMPT=$(cat "$SYSTEM_FILE")
SYSTEM_PROMPT="${SYSTEM_PROMPT//\{\{ROUND\}\}/$ROUND}"
SYSTEM_PROMPT="${SYSTEM_PROMPT//\{\{DATE\}\}/$DATE}"
SYSTEM_PROMPT="${SYSTEM_PROMPT//\{\{CRITIC\}\}/Claude (Claude Code CLI, Max subscription)}"
SYSTEM_PROMPT="${SYSTEM_PROMPT//\{\{MODEL\}\}/${MODEL_LABEL} via claude -p headless}"

USER_PROMPT="Read everything below, then produce the critique.

===== BRIEF =====
$(cat "$BRIEF")

===== MATERIAL UNDER REVIEW (the target of critique) =====
$(cat "$PROPOSAL")
${PRIOR_CONTEXT}

===== TASK =====
Produce the adversarial critique now. Markdown format. No preamble. Start with the heading and metadata, then follow the brief's output format exactly."

# Run headless. env -u ANTHROPIC_API_KEY guarantees subscription billing: if the key
# were present, the CLI would flip to API billing, which is exactly what we forbid.
ERRFILE=$(mktemp)
set +e
CONTENT=$(printf '%s' "$USER_PROMPT" | env -u ANTHROPIC_API_KEY "$CLAUDE_BIN" \
    -p \
    --output-format text \
    --system-prompt "$SYSTEM_PROMPT" \
    ${MODEL_ARGS[@]+"${MODEL_ARGS[@]}"} 2>"$ERRFILE")
STATUS=$?
set -e

if [ "$STATUS" -ne 0 ] || [ -z "$CONTENT" ]; then
    echo "ERROR: claude CLI failed (exit $STATUS) or returned empty output." >&2
    echo "If this is an auth error, log in with 'claude' interactively. Do NOT set ANTHROPIC_API_KEY." >&2
    echo "stderr:" >&2
    cat "$ERRFILE" >&2
    rm -f "$ERRFILE"
    exit 1
fi
rm -f "$ERRFILE"

echo "$CONTENT" > "$OUTPUT"

WORDS=$(echo "$CONTENT" | wc -w | tr -d ' ')
RECOMMENDATION=$(printf '%s\n' "$CONTENT" | grep -im1 -E '(ship[[:space:]]+with([[:space:]]+named)?[[:space:]]+amendments|kill,?[[:space:]]*re[- ]?formulate|ship[[:space:]-]+as[[:space:]-]+is)' || true)
RECOMMENDATION=${RECOMMENDATION//\*/}
RECOMMENDATION=${RECOMMENDATION:0:80}

echo "Claude critique written to $OUTPUT (Max subscription, no API billing)"
echo "Words: $WORDS"
echo "Recommendation snippet: $RECOMMENDATION"
