#!/bin/bash
# GADFLY installer
# Copies the three skills and the two least-privilege agent definitions into
# your Claude Code directories. Run from the folder containing this script.
#
# (Preferred alternative: install as a plugin via
#  /plugin marketplace add alexmakarski/gadfly
#  /plugin install gadfly@gadfly )

set -e

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

for skill in prior-art critic-gauntlet waterfall-lint; do
    if [ ! -d "$SCRIPT_DIR/skills/$skill" ]; then
        echo "ERROR: expected $SCRIPT_DIR/skills/$skill next to this script."
        exit 1
    fi
    if [ -d "$SKILLS_DIR/$skill" ]; then
        echo "Updating existing skill at $SKILLS_DIR/$skill"
        rm -rf "$SKILLS_DIR/$skill"
    fi
    cp -R "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill"
    chmod +x "$SKILLS_DIR/$skill/"*.sh 2>/dev/null || true
    echo "Installed skill: $SKILLS_DIR/$skill"
done

# Least-privilege agents. Do not clobber a differing existing copy silently.
for agent in gauntlet-critic gauntlet-synthesizer; do
    SRC="$SCRIPT_DIR/agents/$agent.md"
    DST="$AGENTS_DIR/$agent.md"
    if [ -f "$DST" ]; then
        if cmp -s "$SRC" "$DST"; then
            echo "Agent already installed (identical): $DST"
        else
            echo "NOTE: $DST already exists and differs. Left untouched. Any"
            echo "      version works as long as tools stay scoped to"
            echo "      Read, Grep, Glob, Write."
        fi
    else
        cp "$SRC" "$DST"
        echo "Installed agent: $DST"
    fi
done

echo ""
echo "Done. Optional external critics need keys (see skills/critic-gauntlet/.env.example):"
echo "  XAI_API_KEY (Grok), GEMINI_API_KEY (Gemini), DEEPSEEK_API_KEY (DeepSeek),"
echo "  and the codex CLI for the Codex critic."
echo "Never set ANTHROPIC_API_KEY to 'fix' the Claude critic; it runs on your"
echo "subscription as a subagent and an API key reroutes ALL of Claude Code to"
echo "API billing."
