---
name: prior-art
version: 1.1.0
description: Find out how a problem has ALREADY been solved, before anyone writes a proposal about it. Dispatches parallel scouts across separate bodies of knowledge (academic literature, production practice in regulated industries, vendor architecture, practitioner threads on X / HN / Reddit, implementations on GitHub) and returns what exists, with every source fetched and quoted rather than recalled. Scouts REPORT; they never judge, rank, or recommend. Run this BEFORE critic-gauntlet: the gauntlet decides whether a proposal is wrong, this decides whether the proposal should have been written that way at all. Use when facing an architectural decision, a hard technical problem that feels novel, a vendor or platform choice, or any question where "surely someone has solved this" is worth asking.
trigger_phrases:
  - prior art
  - what already exists
  - has anyone solved this
  - how do others do this
  - scout the field
  - what does the field do
---

# prior-art

## Why this exists

The critic-gauntlet asks "is this proposal wrong". It has never once asked
"what do the people who already solved this do".

That gap is not theoretical. One internal product line ran five gauntlet rounds on numeric fidelity
in generated prose and produced regexes and a clause library. The first
prior-art pass, on 2026-08-08, found in one evening that no regulated industry
ships model-written prose without a human reading it, that every published
checker is weakest on exactly the error class being chased, and that the
cheapest measured fix (repairing the input tables, 52-76% error reduction) had
never been considered. The work had been aimed one layer too low.

Blank-page and 80/110 steelmanning do not fill this gap. They ask the same
models to invent from their own priors under adversarial framing, which
reliably produces narrower answers than asking them to go and read.

## The two rules that make it work

**1. Scouts report. They never judge.** No recommendations, no ranking, no
"this one looks most promising". The moment a scout starts advocating it stops
searching and starts arguing, and you get a critic with a worse rubric. Judging
is the gauntlet's job and it happens later.

**2. Every source is FETCHED and QUOTED, never recalled.** A search-result
snippet is not a source. A model's memory of a paper is not a source. The scout
opens the page, and the line it quotes must literally appear in what it opened.
Anything it could not open goes in a "could not fetch" list and is NOT
presented as a finding.

Rule 2 is the whole reliability of this skill. Confident citations to papers
that do not exist are the failure mode, and they are indistinguishable from
real findings unless the contract forbids them up front.

## Procedure

### 1. Write the problem statement, domain-neutral

Strip the project. No product names, no internal history, and above all **no
mention of what has already been tried**. Naming the tried solutions is how you
get five scouts arguing about your priors instead of reporting what exists.

Include instead: the shape of the problem, the constraints that actually bind
(cost per operation, latency, who reads the output, what "correct" means), and
the failure mode in concrete but generic terms.

You do the mapping back onto the project yourself, afterwards. That is not the
scouts' job and they are worse at it than you.

### 2. Pick 3 to 5 angles, split by BODY OF KNOWLEDGE, not by model

Model diversity buys nothing here; coverage does. Each scout searches somewhere
the others cannot see. The angles that earned their place on the first run:

- **The field that owns the problem.** Usually there is one, and it usually
  predates LLMs by decades. Find it first; it is the highest-yield angle.
- **The measurement and evaluation literature.** How does anyone know whether a
  solution works? This is where reported failure rates live.
- **Production practice in a high-stakes industry.** Medicine, law, finance,
  aviation, safety. What do people who cannot afford to be wrong actually ship,
  and what do they explicitly refuse to automate? Least academic, often most
  useful.
- **The narrow version of your exact failure.** Targets the specific shape.
- **Practitioner chatter.** X, HN, Reddit, engineering blogs. Where a technique
  shows up a year or two before a paper describes it.

### 3. Dispatch in parallel

One agent per angle, all in one message. Give each the neutral problem
statement, its angle, the hard rules, and the output schema below.

On hosts without an Agent tool (Codex or any other orchestrator), run each
scout as its own headless session instead (`claude -p` with the scout prompt,
or `codex exec --sandbox read-only`), one per angle, each writing its own
report file. The rules and schema are identical either way.

### 4. Verify before you show anyone anything

Pick the load-bearing claims (the ones that would change a decision) and fetch
those sources YOURSELF. Check the quoted line actually appears, and check the
title and authors match. On the first run this caught a scout reporting
aggregate figures from a publisher's social post as if they were in the
peer-reviewed abstract; the per-type figures in the real paper were worse.

A scout that self-flags an unverifiable quote is behaving correctly. Say so and
keep its other findings. A scout that cannot produce the source is reporting
fiction; drop the finding.

### 5. Hand off

Surface the raw files first, unsummarized. Then map onto the project yourself.
The output feeds a proposal, and the proposal goes to critic-gauntlet.

## Output schema (give this to every scout, verbatim)

```
# Scout report: <angle>

## <Any up-front question the orchestrator asked>
Answer plainly, first, before the detail.

## Approaches found

### <name of the approach>
- **What it is:** 2 to 4 sentences, plain English
- **Who uses it:** named production users, or "research only"
- **Source:** full URL
- **Quoted line from that page:** "..." (must literally appear in the fetched page)
- **Fetched:** yes
- **Reported reliability / failure rate:** whatever the source states, or "not stated"
- **Rough cost to try:** honest estimate, or "unknown"
- **Measurement that would show it works:** what you would measure

## Sources I could not fetch
URL and why. Anything here is NOT a finding.

## What I looked for and did NOT find
Be specific. Negative results are the most valuable thing here and the
easiest to skip.
```

Ask each scout for a short summary (under 200 words) as its return message, and
the count of sources it actually fetched. The file is the deliverable.

## Sources and their access status

See `sources.md` for verified endpoints, auth status and what is blocked.
Highlights, all verified 2026-08-09:

- **Hacker News: use the Algolia API, not the web UI.** `hn.algolia.com/api/v1`,
  no auth, full text across stories and comments with points and dates. The web
  UI rate-limits hard and will 429 you mid-run.
- **OpenAlex** for systematic literature coverage. No auth, no key, citation
  counts included for ranking.
- **GitHub via `gh`**, already authenticated. Issues and discussions are where
  people report what broke when they tried the thing.
- **X is reachable only through `grok_query` with `sources="x"`**, and x.com
  returns 402 to direct fetches, so those citations are Grok's rendering and
  must be labelled unverified.
- **Reddit bodies are blocked.** Titles and snippets via SERP with a site
  filter. Say so rather than implying you read the thread.
- **LinkedIn: do not bother.** No content search, aggressive blocking, and the
  signal is self-promotional by construction. Prior art needs people describing
  what failed, which is the one thing nobody posts there.

## Where this sits

`prior-art` runs BEFORE the proposal exists. `critic-gauntlet` runs ON the
proposal. `waterfall-lint` runs ON the finished artifact. See `README.md` for
the full relationship and for how this differs from `deep-research`.

This skill ships inside GADFLY, the adversarial review stack containing all
three skills, and is versioned with that repo.

## Cost and scale

Five scouts with heavy fetching ran roughly 15 to 30 minutes wall clock on the
first pass. Token cost is the real cost. Three angles is a legitimate run.
Scale by how consequential the decision is, not by how interesting the topic is.

## Known failure modes

- **Fabricated citations.** Mitigated by rule 2 and step 4. Never skip step 4.
- **Anchoring.** If you brief the scouts on what you already tried, they grade
  your attempt instead of reporting the field. Keep the brief neutral.
- **Scouts drifting into advocacy.** Reinforce rule 1 in the prompt; it does
  not hold on its own.
- **Thin results read as "nothing exists".** Thin is a finding, but check the
  angle was searchable first. On the first run the practitioner lane came back
  thin because the problem is discussed mostly as a different, adjacent failure.
