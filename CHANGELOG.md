# Changelog

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
