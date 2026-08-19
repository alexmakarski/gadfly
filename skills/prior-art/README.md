# prior-art

## What the name means

"Art" in the old sense: skill, craft, technique. Same root as artisan and
artificial, from Latin *ars*. Patent law still uses it that way, which is why
patents talk about "a person skilled in the art", meaning an ordinary
practitioner in a field, not a painter. You already use the same sense in
"state of the art".

So **prior art** means the craft as it already stood before your attempt.
Everything the field already knew how to do. That is exactly the question this
skill asks.

---

## How this differs from `deep-research`

They look similar and are not. The difference is not topic or depth, it is the
**evidence contract**, and it is the entire reason this skill exists.

`deep-research` fans one query out to nine research engines (Perplexity,
Gemini, Claude, OpenAI, Manus, Tavily, Exa, Grok and others) and collects what
they say. The output is **model answers about a topic**. That is genuinely
useful and it is fast, but every line of it is something a model asserted.

`prior-art` requires every source to be **opened and quoted**. A search-result
snippet is not a source. A model's recollection of a paper is not a source. If
a scout could not fetch the page, the item goes in a "could not fetch" list and
is not presented as a finding at all. The orchestrator then re-fetches the
load-bearing claims by hand before showing anyone anything.

That contract exists because nine engines answering from their priors is
precisely the mechanism that produces confident citations to papers that do not
exist. Those are indistinguishable from real findings unless something forbids
them structurally.

| | `deep-research` | `prior-art` |
|---|---|---|
| Scoped to | a **topic** | a **problem you are about to try to solve** |
| Output is | what nine engines say | what documents say, quoted |
| Sources | asserted | fetched, quoted, spot-checked |
| Decomposition | one query, many engines | one angle per body of knowledge |
| Agents may judge | yes, they summarise and weigh | **no**, reporting only |
| Feeds | your understanding | a proposal, which then goes to the gauntlet |
| Failure mode | plausible fabrication | thin coverage |

They compose. `deep-research` is a reasonable way for a scout to find *leads*.
It is not a way to establish that something is true.

---

## How the three skills relate

They are a sequence, and each one runs at a different moment against a
different object. Nothing is a family prefix, because the relationship is about
**order**, not category.

```
prior-art        BEFORE a proposal exists     What already exists?
                 object: the PROBLEM          scouts REPORT, never judge

critic-gauntlet  ON the proposal              Is this wrong?
                 object: the DECISION         critics JUDGE, never fix

waterfall-lint   ON the finished artifact     Scrub until critics run dry
                 object: the ARTIFACT         defects FIXED at class level
```

**prior-art** answers "should we even be writing this proposal, and in this
shape?" It is the only one of the three that looks outside the building. Its
agents are forbidden from having opinions.

**critic-gauntlet** answers "is this specific proposal wrong?" One-shot,
independent, adversarial, raw outputs surfaced verbatim. Convergence binds:
if the critics agree against an approach, it does not ship without an explicit
escalation. Its critics judge but never implement.

**waterfall-lint** answers "what is still wrong with the thing we built?"
Inverted from the gauntlet: critics run ONE AT A TIME, each confirmed defect is
fixed at class level (a validator or a test, not a one-off patch), accepted
warts go in a ledger every later critic sees, and it stops after two
consecutive dry passes.

### The split that is easy to get wrong

`critic-gauntlet` versus `waterfall-lint` is **verdict versus scrub**, not
decision versus artifact. The gauntlet delivers a one-shot independent verdict
in all its modes, including on artifacts (science and editorial modes review
papers and articles). Waterfall-lint iteratively removes defects with fixes
between passes.

`prior-art` versus the other two is simpler: it is the only one that runs
before there is anything to judge.

### Why they do not share a prefix

`critic-gauntlet` exists as four hand-maintained forks, one of them a public
GitHub repo and one a marketplace plugin. Renaming means renaming a public
thing, rewriting the `FORKS` paths in its drift detector, and breaking every
reference in the ADR folders and the state files. The gain would be cosmetic.

There is also no convention to join. `critic-gauntlet` is noun-then-mechanism;
`waterfall-lint` is mechanism-then-noun. They do not match each other.

Skills are selected by their **description**, not by browsing an alphabetical
list, so the family relationship belongs in the description text where it
actually gets read. Each of the three names the other two there.

---

## When to run which

| Situation | Skill |
|---|---|
| "This feels novel and I'm about to design it" | prior-art |
| "Surely someone has solved this" | prior-art |
| Choosing a vendor, platform, or new dependency | prior-art, then gauntlet |
| An ADR is drafted and needs a verdict | critic-gauntlet (architecture) |
| A paper is ready for submission | critic-gauntlet (science) |
| An article needs a five-lens review | critic-gauntlet (editorial) |
| A client report is finished and needs scrubbing | waterfall-lint |
| A launch site is going live | waterfall-lint (site-launch) |
| "Find everything about X" with no decision attached | deep-research |

The sequence for a real architectural decision is: **prior-art → write the
proposal → critic-gauntlet → build → waterfall-lint the output.**

Skipping the first step is what produced five rounds of increasingly clever
answers to a question the field had already answered differently.

---

## Origin

Built 2026-08-09, from AM's observation the day before:

> "we have the gauntlet that evaluates a proposal and votes to kill it or not.
> but what we don't have is a group of researchers thinking about creative ways
> to solve a problem... we have not asked them once about what have other people
> discussed and what have they attempted to do as a solution."

The first run, before the skill existed, is preserved internally as a worked
example with all five raw scout reports.
