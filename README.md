# GADFLY

An adversarial review stack for Claude Code: three skills that keep your work
honest before it ships, at the three moments dishonesty creeps in.

| Stage | Skill | Question it answers |
| --- | --- | --- |
| Scout | `prior-art` | How has the field ALREADY solved this? Every source fetched and quoted, never recalled. |
| Verdict | `critic-gauntlet` | Is this proposal wrong? Independent multi-model critics in parallel; convergence binds. |
| Scrub | `waterfall-lint` | What findable defects remain in the finished artifact? Sequential critics, receipts decide, stop when dry. |

They run in that order. `prior-art` runs before a proposal exists, so you don't
write one the field already made obsolete. `critic-gauntlet` runs on the
proposal and renders a verdict you are not allowed to talk your way past.
`waterfall-lint` runs last, on the finished artifact, and removes defects until
two consecutive critics come up dry.

## Why "gadfly"

In Plato's *Apology*, Socrates tells the jury that the god fastened him to
Athens the way a gadfly is set upon a great and noble horse, a horse grown
sluggish from its own size and needing to be stung awake. He spent his life
stinging the thing he loved so it could not sleepwalk, and Athens voted to kill
him for it, which tells you how welcome real criticism usually is.

That is the job here. Your own proposals are the noble horse: big, well-bred,
and drowsy with self-regard. This stack is the licensed irritant. The critics
it spawns are prompted to attack, forbidden to flatter, and structurally unable
to be talked out of a converged verdict by the person who wrote the proposal,
because the person who wrote the proposal never writes the synthesis.

The backronym maps to the six steps, in the order they run:

- **G**ather what exists (prior-art)
- **A**ttack the proposal (critics in parallel)
- **D**ecide by convergence (binding, never overridden in prose)
- **F**ix at class level (validator, not instance)
- **L**int until the critics run dry (waterfall)
- **Y**ield only when dry (the stopping rule)

## What's inside

- `skills/prior-art/` — parallel scouts across separate bodies of knowledge
  (academic literature, regulated-industry practice, vendor architecture,
  practitioner threads, GitHub). Scouts report; they never judge. Every quote
  must appear in a page the scout actually opened.
- `skills/critic-gauntlet/` — spawns a sandboxed Claude critic subagent plus
  any external critics you have provisioned (Codex CLI, Grok, Gemini,
  DeepSeek) in parallel against one adversarial brief. Three rubric modes:
  `architecture`, `science`, `editorial`. Raw critiques surface verbatim; a
  fresh, deliberately small synthesizer does the convergence math; convergence
  against your approach binds the decision.
- `skills/waterfall-lint/` — sequential QA loop for finished artifacts. One
  critic per pass, every finding fact-checked against receipts, confirmed
  defects fixed at class level, accepted warts and refuted findings carried in
  ledgers so no later critic re-litigates them. Stops after two consecutive
  dry passes.
- `agents/` — the least-privilege agent definitions both skills require
  (`gauntlet-critic`, `gauntlet-synthesizer`: Read, Grep, Glob, Write, nothing
  else). Born of a real incident in which fully-toolbelted critics made git
  commits and filed tickets nobody asked for.

The three API-critic scripts are one unified family shared by critic-gauntlet
and waterfall-lint. `--mode qa` (the waterfall's mode) hard-disables
prior-round context, because a waterfall regenerates the artifact between
passes and a prior critique would describe a page that no longer exists.

## Install

As a plugin (recommended):

```
/plugin marketplace add alexmakarski/gadfly
/plugin install gadfly@gadfly
```

Or copy into place:

```bash
./install-gadfly.sh
```

## Requirements

- Claude Code. The Claude critic and synthesizer run as subagents on your
  existing subscription; never set `ANTHROPIC_API_KEY` to "fix" them (see the
  billing note in the critic-gauntlet SKILL.md).
- Optional external critics, each presence-detected and skippable: Codex CLI
  (`codex`), `XAI_API_KEY` (Grok), `GEMINI_API_KEY` (Gemini),
  `DEEPSEEK_API_KEY` (DeepSeek via a US-hosted OpenAI-compatible endpoint by
  default). See `skills/critic-gauntlet/.env.example`. Paid-API cost is a few
  cents per critique.
- `jq`, `curl`, `rsync`.

## Lineage

Extracted from an internal stack that ran production reviews on architecture
decisions, client-facing intelligence reports, working papers, and site
launches through 2026. Internal run names and client details are removed; the
measured lessons (contamination numbers, the convergence-override failure that
cost a month, the critics-committed-to-main incident) are kept with
genericized provenance.

Predecessor repos `alexmakarski/critic-gauntlet` and
`alexmakarski/waterfall-lint` are superseded by this bundle.

## License

MIT.
