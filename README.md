# GADFLY

Three Claude Code skills that attack your work before the real world does.

You do work in three stages: you decide what to build, you build it, and you
ship it. GADFLY puts a checkpoint at each stage:

| Stage | Skill | The question it answers |
| --- | --- | --- |
| Before you propose | `prior-art` | Has someone already solved this? |
| Before you commit | `critic-gauntlet` | Is this proposal wrong? |
| Before you ship | `waterfall-lint` | What defects are still in this thing? |

## Why "gadfly"

In Plato's *Apology*, Socrates tells the jury why he spent his life questioning
everyone: the god attached him to Athens like a gadfly to a big, well-bred
horse, a horse grown lazy from its own size, needing to be stung awake. Athens
killed him for it, which tells you how welcome honest criticism usually is.

Your proposals are the horse: big, confident, and half asleep. This stack is
the fly. Its critics are prompted to attack, forbidden to flatter, and the
person who wrote the proposal is never allowed to grade the critiques.

The name is also a backronym for the six steps, in order:

**G**ather what exists. **A**ttack the proposal. **D**ecide by convergence.
**F**ix at class level. **L**int until critics run dry. **Y**ield only when dry.

## The three skills

### 1. prior-art (scout)

Before anyone writes a proposal, parallel scouts search separate bodies of
knowledge: academic literature, what regulated industries actually ship,
vendor architectures, practitioner forums, GitHub. Two hard rules make it
trustworthy: scouts report and never recommend, and every quote must come from
a page the scout actually opened. A remembered citation is not a source.

**Use it** when a problem feels novel, before an architecture decision, or
before picking a vendor. Someone has usually solved it already.
**Skip it** for quick topic research (any research tool does that) or when the
decision is already made and you just need to execute.

### 2. critic-gauntlet (verdict)

Independent critics from different model families (Claude, Codex, Grok,
Gemini, DeepSeek) attack one proposal in parallel, each blind to the others.
Their raw critiques are shown to you word for word. Then a separate, deliberately
small model tallies where they agree. Agreement binds: if the critics converge
against your approach, you don't get to ship it just because the summary
sounded persuasive. Overriding them takes an explicit human decision, in plain
words.

**Use it** for decisions where being wrong is expensive: system architecture, a
paper before submission, an article that could get you sued.
**Skip it** for bug fixes, refactors, routine work, or anything you'd fix
anyway regardless of the verdict. It buys judgment, not polish.

### 3. waterfall-lint (scrub)

For a finished artifact. Critics run one at a time, not in parallel, because
you fix between passes and each critic should face the repaired version. Every
claimed defect is checked against receipts before it's fixed: critics are
wrong often enough that an unchecked "fix" makes things worse. Confirmed
defects get fixed at class level (a validator or test, not just the one
instance). The loop stops when two critics in a row find nothing new.

**Use it** on work where a shipped defect costs credibility with a real
reader: a client report, a paper, a site going live.
**Skip it** for judging proposals or strategies (that's the gauntlet's job),
and never run both skills on the same draft for the same purpose.

The rule of thumb: not proposed yet, scout. Deciding, verdict. Polishing, scrub.

## How the Claude critic runs (and what claude-critic.sh is)

Every panel includes a Claude critic. There are two doorways to it, and both
are locked down:

- **Inside Claude Code:** it runs as the `gauntlet-critic` subagent, which can
  only read files and write its one critique. No shell, no git, no external
  services. This is the default.
- **Anywhere else** (a Codex session, a cron job, any host without Claude
  Code's Agent tool): `claude-critic.sh` does the same job as a script. It
  pipes the brief and the material into `claude -p` (the Claude CLI's
  answer-once mode, billed to your subscription), catches the reply, and
  writes the critique file itself. The model gets no tools at all, and the
  script strips `ANTHROPIC_API_KEY` from its environment so it can never
  silently switch you to metered API billing.

Same critic, same rubric, two ways to summon it. That's the whole trick that
makes these skills work from Claude Code and Codex with one set of files.

The lockdowns are not decoration. They exist because critics once ran with
full permissions and, unasked, committed to main and filed tickets in a live
tracker. The work was even good. That's the trap: a capable agent with a full
toolbelt finds adjacent work and does it. So the fence is structural, not a
polite request in the prompt.

## Install

As a plugin (recommended):

```
/plugin marketplace add alexmakarski/gadfly
/plugin install gadfly@gadfly
```

Or copy the files into place:

```bash
./install-gadfly.sh
```

Codex users: copy `skills/` into `~/.agents/skills/`.

## Requirements

- Claude Code, or any orchestrator that can run shell scripts.
- Optional external critics, each detected and skippable: the `codex` CLI,
  `XAI_API_KEY` (Grok), `GEMINI_API_KEY` (Gemini), `DEEPSEEK_API_KEY`
  (DeepSeek, US-hosted endpoint by default). See
  `skills/critic-gauntlet/.env.example`. A critique costs a few cents.
- Never set `ANTHROPIC_API_KEY` to "fix" the Claude critic. It runs on your
  subscription; the key would reroute all of Claude Code to metered billing.
- `jq`, `curl`, `rsync`.

## Lineage

Extracted from an internal stack that ran production reviews on architecture
decisions, client intelligence reports, working papers, and site launches
through 2026. Client names and internal run names are removed; the measured
lessons are kept, including the convergence override that cost a month and the
critics-committed-to-main incident described above.

Predecessor repos `alexmakarski/critic-gauntlet` and
`alexmakarski/waterfall-lint` are superseded by this bundle.

## License

MIT.
