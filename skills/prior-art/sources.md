# Sources: what is reachable, what it costs, what is blocked

Status column is honest. **VERIFIED** means a live call was made from this
machine on the stated date and returned usable data. **KNOWN** means it is
documented and widely used but was not tested here. **BLOCKED** means it was
tried and refused.

Re-verify anything older than a few months before relying on it. Access
changes, and a scout quoting a dead endpoint fails silently by finding nothing.

---

## Literature

### OpenAlex — VERIFIED 2026-08-09
No auth, no key. Best default for systematic coverage; returns citation counts,
which is the cheapest relevance signal available.

```bash
curl -s "https://api.openalex.org/works?search=data-to-text%20faithfulness&per-page=5"
```
Test returned 131,975 works; second hit was "Sticking to the Facts: Confident
Decoding for Faithful Data-to-Text Generation" (48 citations). Put your email in
a `mailto=` param to land in the polite pool and get better rate limits.

### arXiv API — VERIFIED 2026-08-09
No auth. **Use https**; the http endpoint returned nothing in testing.

```bash
curl -s "https://export.arxiv.org/api/query?search_query=all:%22data-to-text%22&max_results=10"
```
Atom XML. For reading a paper's full text, `ar5iv.labs.arxiv.org/html/<id>`
renders cleanly and is far more fetchable than the PDF.

### Crossref — VERIFIED 2026-08-09
No auth. Broad DOI coverage, weaker relevance ranking than OpenAlex; better for
resolving a known work than for discovery.

```bash
curl -s "https://api.crossref.org/works?query=table-to-text+hallucination&rows=5"
```

### PubMed E-utilities, Europe PMC — KNOWN
Open, no key needed for modest volume. The route into clinical and regulated
medical practice. PubMed abstract pages fetch cleanly; that is how the
radiology error-detection figures were verified on the first run.

### Semantic Scholar — KNOWN
Free key, higher limits with one. Good citation graph.

### Publisher walls — BLOCKED
Nature (`nature.com`) 303-redirects to an auth wall; ScienceDirect and MIT Press
return 403. ACL Anthology **PDFs** return undecoded binary, but the **HTML
abstract pages** work. Route around: ar5iv for arXiv preprints, PubMed for
abstracts, institutional repositories.

---

## Practitioner discussion

### Hacker News via Algolia — VERIFIED 2026-08-09
No auth. **Use this, not the web UI.** `news.ycombinator.com` rate-limits hard
and returned 429 twice mid-run on 2026-08-08.

```bash
curl -s "https://hn.algolia.com/api/v1/search?query=<terms>&tags=story&hitsPerPage=10"
curl -s "https://hn.algolia.com/api/v1/search?query=<terms>&tags=comment"
```
Returns points, comment counts and dates, so you can rank by engagement.
`tags=comment` is often the better search: the substance is in the replies.

### X — via `grok_query` ONLY
`x.com` returns **402 to direct fetches**, VERIFIED 2026-08-08. There is no
other route into X in this toolset.

Use `mcp__ai-signals__grok_query` with `sources="x"` or `"both"`. It runs an
agentic search server-side and returns x.com permalinks as citations.

**Critical honesty rule:** because the permalinks cannot be opened, every X
finding is *Grok's rendering of a post*, not something anyone read. Label them
"citation only, body not fetched". Do not present them as quotes you verified.

Operational: the client timeout was raised to 300s on 2026-08-09
(`ai-signals-mcp/server.py`) after long `sources="both"` prompts timed out five
times. If it still times out, shorten the prompt and run more queries rather
than one big one.

### Reddit — PARTIAL
Thread bodies are **BLOCKED** to WebFetch (VERIFIED 2026-08-08). The official
API needs an app registration and approval, not yet done.

Works today: SERP with a site filter (any Google SERP tool) using
`site:reddit.com <terms>`. Gives titles and snippets, which is how production
report pipelines typically read Reddit: "the capture is thread titles and
snippets from Google's index".

Say "citation only" on anything sourced this way.

### StackExchange — VERIFIED 2026-08-09
No auth for light use. Quota is **300 calls/day unauthenticated**; the response
carries `quota_remaining`, so watch it.

```bash
curl -s --compressed "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=votes&q=<terms>&site=stackoverflow"
```

---

## Implementations

### GitHub via `gh` — VERIFIED 2026-08-09
Already authenticated on this machine. No setup.

```bash
gh search issues "<terms>" --limit 20 --json title,url,repository
gh search code "<symbol>" --limit 20
gh search repos "<terms>" --sort stars
```
The highest-value angle most scouts skip: **issues are where people report what
broke when they tried the thing**, which is the half that papers omit.

---

## Not worth it

### LinkedIn — DO NOT
No content search API, aggressive blocking, ToS problems. The real reason is
the signal: LinkedIn posts are self-promotional by construction, and prior art
needs people describing what *failed*. That is the one thing nobody posts there.

### Patents — LOW YIELD HERE
Literally the namesake corpus (Google Patents, USPTO, EPO OPS). For software
methods the noise is high and the disclosure is deliberately vague. Wire it last
if at all. For a hardware, materials or process question, move it to the top.

---

## Vendor and production practice

No API. This is manual fetching of vendor docs, engineering blogs, regulatory
guidance and conference talks, and it was one of the highest-yield angles on the
first run.

Two rules learned there:

1. **Mark vendor claims as vendor claims.** Arria's site states "100% accuracy,
   100% of the time"; that describes their deterministic layer, not measured
   output, and they publish no error rate. Stanford measured the same category
   of vendor at 17-33% hallucination.
2. **Regulatory bodies are fetchable and blunt.** FINRA notices, CIOMS working
   group drafts and FDA framework documents state what is actually required,
   and they often decline to set the numeric threshold everyone assumes exists.
