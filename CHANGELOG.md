# Changelog

## 1.2.3 (2026-09-30)

- The Grok, Gemini and DeepSeek scripts now fail loudly (critic-gauntlet 2.9.3,
  waterfall-lint 1.3.3). Before, an API error body was saved as the critique and
  the script exited 0. Now any error body, any reply under 500 characters, and
  any reply cut off at the token limit exits 1 and writes no critique file.
  Seen live: an out-of-credits message and a model-not-found message were
  saved as critiques, and a DeepSeek reply cut off mid-critique would have
  passed the liveness gate.
- Codex critic pinned to `-m gpt-6-astra -c model_reasoning_effort=high` in
  both skills, instead of inheriting the operator's Codex config.

## 1.2.2 (2026-09-30)

- DeepSeek critic default re-pinned to `accounts/fireworks/models/deepseek-v4p1-flash`
  (critic-gauntlet 2.9.2, waterfall-lint 1.3.2). Both V4-Pro ids now return 404
  on Fireworks serverless, even though `GET /v1/models` still lists them.
  V4.1 Flash is DeepSeek's current flagship: DeepSeek's 2026-09-10 announcement
  puts it ahead of V4-Pro and phases V4-Pro out. Still US-hosted Fireworks.
- DeepSeek reply budget raised from 16,000 to 32,000 tokens. V4.1 Flash thinks
  before it answers; at 16,000 one run returned no text and the next stopped
  mid-critique before the recommendation.

## 1.2.0 (2026-08-19)

The exemplar-bar release, adapted from Matt Shumer's Claude of Duty via
robonuggets/gauntlet-loop (CC BY 4.0):

- waterfall-lint 1.3.0: optional BAR PASS after the loop goes dry. One blind
  A/B against a named, fetched exemplar of the same class, run twice with two
  model families and document order swapped; only losses both critics name
  survive, entering triage as GAP (operator-judged, never able to override a
  receipt). Proof-of-life measured: on a peer pair, single verdicts followed
  document position and the overlap rule correctly returned zero; on a
  known-gap pair, both critics found the better document from opposite
  positions and recovered the rework's actual improvements.
- prior-art 1.2.0: scouts harvest "best-in-class specimens" (named, fetchable,
  comparable) as candidate quality bars for the two consumers above.
- critic-gauntlet 2.9.0: optional EXEMPLAR block in the editorial brief
  anchors the reader-engagement and slop lenses to a real fetched piece;
  rides call 2 so the cold read stays cold.

## 1.1.0 (2026-08-19)

- Universal across runtimes: the SKILL.mds now work from Claude Code AND any
  orchestrator without the Agent tool (Codex CLI etc.). New `claude-critic.sh`
  joins the unified script family: headless `claude -p` on your subscription,
  `ANTHROPIC_API_KEY` scrubbed from the subprocess, the model receives no
  tools (content piped in, the script writes the one output file).
- critic-gauntlet 2.8.0: DeepSeek promoted from uncalibrated to full binding
  panel member (2.7.0), universality note (2.8.0).
- waterfall-lint 1.2.0, prior-art 1.1.0: no-Agent-tool dispatch fallbacks.

## 1.0.0 (2026-08-19)

First public release of GADFLY, bundling three previously separate skills:

- `critic-gauntlet` 2.6.0 (previously `alexmakarski/critic-gauntlet`, last
  standalone release 2.5.1)
- `waterfall-lint` 1.1.0 (previously `alexmakarski/waterfall-lint`, last
  standalone release 1.0.1)
- `prior-art` 1.0.1 (first public release)

Changes versus the standalone repos:

- The three API-critic scripts (`grok-critic.sh`, `gemini-critic.sh`,
  `deepseek-critic.sh`) are now ONE unified family, byte-identical between the
  two skills that ship them. The waterfall's no-prior-round-context isolation
  is enforced at runtime: `--mode qa` always disables prior-round context, and
  `--no-prior-rounds` forces the same in any other mode. Previously this was a
  hand-maintained script fork.
- Because the unified scripts default to `--mode architecture`, waterfall-lint
  invocations must pass `--mode qa` explicitly (the SKILL.md invocation lines
  already do).
- `agents/` ships both least-privilege agent definitions (`gauntlet-critic`
  and `gauntlet-synthesizer`); the standalone waterfall-lint repo shipped only
  the critic.
- Installable as a plugin (`/plugin marketplace add alexmakarski/gadfly`) or
  via `./install-gadfly.sh`.

The predecessor repos are superseded by this bundle.
