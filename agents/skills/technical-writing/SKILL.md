---
name: technical-writing
description: "Write or edit technical English that is precise, plain, and hard to misread. Combines The Economist's style guide with ASD-STE100 Simplified Technical English, in US spelling and grammar. Use when drafting or revising READMEs, docs, guides, specs, runbooks, PR and MR descriptions, commit bodies, release notes, code comments, error messages, tool descriptions, prompts, or memos. Triggers: edit this, tighten this, style pass, make this clearer, plain-English rewrite, proofread, US English."
version: 1.0.0
---

# Technical Writing: Economist craft, STE discipline, US English

Two traditions, one house style.

**The Economist** teaches what to say. Lead with the point. Prefer the short word and cut the spare one. Replace vague claims with numbers. Never reach for a phrase you have seen in a press release.

**ASD-STE100** teaches how to shape it: short active sentences, one instruction each, one name per thing, no phrasal verbs, no semicolons. It was built so an aircraft technician could not misread a manual. The same discipline stops an AI agent, a translator, or a tired on-call engineer misreading you.

They disagree in places. The tier system and the conflict rulings below settle every disagreement in advance, so you never have to improvise a ruling mid-edit.

**US spelling and grammar apply at every tier.** This overrides The Economist's British conventions. Do not detect the document's dialect and match it. Convert it.

## Precedence: a project's own style guide

A project can outrank this skill, but only in writing.

**What counts as a project style guide:**

- A `STYLE.md`, `STYLEGUIDE.md`, or a style section in `CONTRIBUTING.md`
- Prose rules in a `CLAUDE.md`, `AGENTS.md`, or equivalent instruction file
- A configured prose linter that encodes decisions: `.vale.ini`, `vale/` styles, `textlintrc`, `proselint` config
- The user saying so in the conversation

**What does not count:** the existing prose. A repository full of British spelling, title-case headings, and semicolons is a habit, not an instruction. Convert it.

**How the two combine:**

1. **Rule by rule, not wholesale.** If the project mandates the Oxford comma or title-case headings, it wins on that rule alone. It does not win on cliches, weasel words, phrasal verbs, or anything else it does not mention.
2. **Where the project guide is silent, this skill applies in full.** A style guide that covers only headings and code blocks leaves every rule here in force.
3. **A project guide cannot license bad writing.** It can set a convention. It cannot make "leverage our seamless, robust platform" acceptable, because that is not a convention question.

**Always report it.** When project guidance displaces a rule here, say so on an `Overruled by project style:` line, naming the source file and each rule it displaced. Never silently follow a house style the user cannot see you following.

## Step 1: Pick the tier

| | Tier 1 — Machine-read | Tier 2 — Documentation (default) | Tier 3 — Prose |
|---|---|---|---|
| **Text** | Error messages, tool and function descriptions, system prompts, inter-agent instructions, runbooks, procedures, safety text, alert copy | READMEs, API docs, guides, specs, ADRs, release notes, changelogs, PR descriptions, commit bodies, code comments | Memos, exec summaries, blog posts, design rationale, incident write-ups, announcements |
| **Who wins** | STE, outright. Flat is correct here | STE structure + Economist word choice | Economist voice. STE is a backstop against unparseable sentences |
| **Sentence cap** | 20 words | 25 words | 30 words, 15-20 average |
| **Term lock** | Total. One word per concept, no exceptions | Technical terms locked. Ordinary verbs consistent within a section | Technical terms locked; prose may vary |
| **Metaphor** | None | None | Fresh only, and rarely. Never a cliche |
| **Semicolon** | Never | Never | Sparingly |
| **Em dash** | Never. Split the sentence | One per paragraph | Free, closed up: `word—word` |
| **Passive** | Only when the actor is genuinely unknown | Same | Same |
| **Voice** | None. Say the thing | Plain and calm. Give reasons, not just rules | Dry wit permitted, never jokes |
| **Rhythm** | Uniform. Predictability is the feature | Vary length and opening. No three same-shape sentences in a row | Vary deliberately. A short sentence after two long ones |
| **Reader address** | Imperative: "Run the migration" | Second person. "You" and imperatives, never "the user should" | Second person, or "we" where a team genuinely speaks |

Infer the tier from the text. State it in one line inside the change table, not as a preamble. A document can mix types. In a README with a procedure in it, apply Tier 1 (machine-read) to the procedure block and Tier 2 (documentation) to the rest.

**When two tiers both fit, take the lower number.** The stricter tier costs a little voice. The looser one costs a reader who misreads you.

- **The test:** will anyone read this without being able to ask a follow-up question? A parser, a stranger, a translator, an on-call engineer at 3 a.m.? If yes, go stricter.
- **Genuinely unclear? Use Tier 2 (documentation).** It is the default for a reason: STE structure with Economist word choice is right for most technical prose.
- **Never pick a tier to license a sentence you wanted to keep.** Choosing Tier 3 (prose) because a sentence runs long is not a tier judgment.

## Step 2: The non-negotiables

These hold at every tier. The first eight say what to build. Read them in order — a writer who meets "no phrasal verbs" before "old before new" has learned the wrong priority.

### Build the sentence

1. **Active voice.** Name the actor. Passive only when the actor is genuinely unknown or irrelevant.
2. **Old before new.** Open each sentence with something the reader already has. End it on what you are adding. This is what makes short sentences read as prose instead of a list of facts. See `references/CRAFT.md`.
3. **A finite verb in every sentence.** "Four worked examples, one per tier plus the two traps" is a label, not a claim. An appositive stack has no truth conditions, so nobody can check it, including you. Keep verbless block language for headings, table cells, and captions.
4. **One idea per sentence.** Two instructions means two sentences.

### Serve the reader

5. **Gloss every label.** Write "Tier 1 (machine-read)", not "Tier 1". A number, code, or codename points at a meaning without carrying it.
6. **Keep every section self-contained.** No "as mentioned above." No forward reference that gates comprehension. No pronoun whose antecedent is a scroll away. Readers land mid-document and they will not go looking. See `references/CRAFT.md`.
7. **Lists for sequences.** Three or more steps or conditions go in a numbered or bulleted list, never buried in prose.
8. **Preserve every fact, condition, scope qualifier, and number.** Add none.

### Cut

9. **No phrasal verbs.** Spin up → start. Reach out to → contact. Dive into → read. Kick off → begin. Their meaning is not predictable from the parts.
10. **No nominalizations.** "Perform an analysis of the log" → "analyze the log."
11. **No marketing adjectives.** Seamless, robust, powerful, blazing-fast, world-class, cutting-edge. Delete, or replace with the measurement that earns the claim.
12. **No cliches.** Game-changer, low-hanging fruit, move the needle, perfect storm, at the end of the day. If it would appear in any company's press release, it is doing no work in yours.
13. **No weasel words.** Many, several, significant, substantial, "studies show." Give the number, name the source, or cut the claim.
14. **Noun clusters cap at three words.** "High pressure fuel pump inlet valve assembly" → "the inlet valve on the fuel pump."

### Mechanics

15. **Sentence case headings.** "Configuring the retry policy," not "Configuring The Retry Policy."
16. **Never start a sentence with a numeral.** Spell it out or rewrite.

## Step 3: The conflict rulings

Where the two guides disagree, this is the ruling. Do not relitigate it in the edit.

Tiers in this table: **1** machine-read, **2** documentation, **3** prose.

| Question | The Economist | ASD-STE100 | **Ruling** |
|---|---|---|---|
| Spelling | -ise, colour, centre, defence | silent | **US: -ize, color, center, defense, gray, analyze, canceled, modeling, judgment** |
| Serial comma | omit it | silent | **Use it, always.** "Tax, spending, and regulation." A saved character never outweighs a possible misreading |
| Dates | April 5th 2025 | silent | **April 5, 2025** in prose. **2025-04-05** in logs, filenames, tables, and machine-read strings |
| Abbreviations | Mr, Dr, eg, ie | silent | **US points: Mr., Dr., e.g., i.e.** In Tiers 1-2 prefer "for example" and "that is" |
| Quotation marks | double, punctuation outside | silent | **Double quotes.** Commas and periods **inside** in prose. **Outside** when quoting a literal string, path, command, or code token, where a stray comma changes the value |
| Semicolon | fine | banned outright | **Banned in Tiers 1-2. Sparing in Tier 3** |
| Em dash | frequent, closed up | allowed, discouraged | **Per tier (see table). Closed up when used** |
| Metaphor | fresh ones welcome | none | **Tier 3 only, fresh only.** A cliche is banned everywhere |
| Synonym variety | vary for rhythm | one word, one meaning | **Technical terms locked at every tier.** Prose verbs relax by tier |
| Hedges | cut them | preserve them | **Split them. See below** |
| Numbers | one to ten in words, 11 up in figures | silent | **Same** — except numerals always for steps, versions, measurements, parameters, ports, exit codes, and every Tier 1 quantity |
| Money | $5m, $3.2bn | silent | **"$5 million" in prose. $5m in tables and charts** |
| Collective nouns | singular | silent | **Singular.** "The team is," "the company is." US and Economist agree |
| US idiom (meet with, figure out) | avoid as Americanisms | silent | **Allowed.** This is a US document. But "reach out to" still becomes "contact" — as a phrasal verb, not as an Americanism |
| Honorifics | full name first, then Ms. Yellen | silent | **Keep.** Job titles stay lowercase: "Jerome Powell, chairman of the Federal Reserve" |

### The hedge rule

The Economist says cut hedges. STE says preserve modality. Both are right, about different words.

- **Cut throat-clearing.** It could be argued that, arguably, it is important to note that, to some extent, in a sense, somewhat, relatively, fairly, quite, rather.
- **Keep epistemic modality.** May, might, is likely to, we estimate, roughly, about, in most cases. "The request may have failed" is not "the request failed."
- **The test:** delete the word. If the truth conditions of the claim do not change, it was throat-clearing. If they change, it was content, and cutting it is not an edit — it is a new claim.

This is the most common way a well-meant tightening pass goes wrong. A word cap tempts you toward exactly the words that carry confidence.

### Present perfect

STE bans compound tenses: "we received the report," not "we have received the report." Follow that by default. Keep the compound form where it carries information the simple form cannot. Two cases qualify: current relevance ("the job has completed," and its output is available now) and a hedge ("may have failed"). Note the departure when you keep it.

## Step 4: The workflow

1. **Read the whole text for meaning** before changing a word. You cannot preserve what you have not understood.
2. **Scan for the mechanical faults first**, so you fix named rules rather than vibes. Sweep for:
   - British spellings, semicolons, and em dashes over the tier limit
   - Phrasal verbs, nominalizations, passive voice, compound tenses
   - Marketing adjectives, cliches, weasel words, filler phrases
   - Sentences over the tier cap, and synonym rotation

   The six-point scan in `references/STE-STRUCTURE.md` covers the structural half.
3. **Fix in this order.** Each pass makes the next one easier:
   - **Structure** — lead with the point, kill the buried lede, one idea per sentence, sequences into lists
   - **Precision** — weasel words to numbers, vague time to dates, "studies show" to a named source
   - **Voice** — passive to active, nominalizations to verbs
   - **Words** — long to short, jargon to plain, British to US, term lock
   - **Mechanics** — punctuation, numbers, dates, capitalization
4. **Read the result back cold**, against the original. Every number, condition, scope qualifier, and hedge must still be there, saying the same thing.
5. **If a fix would cost precision, do not make it.** Keep the longer phrasing and report it on the `Kept as-is:` line.
6. **If the text already complies, say so.** Do not manufacture changes to look busy.

## Step 5: Output format

**Default: the rewritten text, then a short table of what changed.**

````markdown
<the rewritten text>

**Changes** (Tier 2, documentation)

| Rule | Original | Revised |
|---|---|---|
| Weasel word | "significant delays" | "four months late" |
| Phrasal verb | "spin up a worker" | "start a worker" |
| British spelling | 12 instances | -ize, color, defense |
| Passive voice | "the file is deleted" | "the agent deletes the file" |

Kept as-is: "may have failed" — "failed" would assert a certainty the source did not.
Flagged, not fixed: "several teams use it" needs a number the source did not give.
Overruled by project style: STYLE.md mandates the Oxford comma and title-case headings. Applied both.
````

Rules:
- The rewritten text comes first, clean, with no preamble about this skill.
- Cap the table at roughly eight rows. Collapse repeats into a count, as with the spelling row above.
- Say "Already compliant" and stop if nothing material changed.

Three optional lines follow the table. Include each only when it has something to report, and omit it otherwise:

| Line | Use it when |
|---|---|
| `Kept as-is:` | Step 5 of the workflow kept a longer phrasing on purpose |
| `Flagged, not fixed:` | The text needs a fact, number, or restructure that you must not supply yourself |
| `Overruled by project style:` | Project guidance displaced a rule from this skill. Name the source file and each displaced rule |

**On request, other shapes:**
- *"rewrite only" / "just the text"* — the rewritten text alone, no table.
- *"review only" / "don't edit"* — no rewrite. Findings with line references, original, suggestion, and a one-line reason each.
- *"show everything"* — every change, not the top eight, with the tier choice explained.

When editing files in place, apply the edits and print only the change table.

## Scope limits

Edit the prose you were given. Nothing else.

- **Do not restructure the document.** No deleting sections, merging them, reordering them, or changing what the document covers. If it needs restructuring, say so in one line and let the author decide.
- **Do not cut a paragraph because it is weak.** Flag it. A thin claim is the author's to defend or drop, and cutting it is an editorial decision disguised as a style fix.
- **Do not add.** No new sections, examples, caveats, or "helpful" background the author did not write. This is the same rule as *add no facts*, one level up.
- **Cutting words is in scope. Cutting content is not.** Losing "it is important to note that" is a style fix. Losing the sentence that follows it is not.
- **The one structural move that is in scope:** lifting a buried claim to the front of its own paragraph. That is a lede fix, not a reorganization.
- **If the text shrinks by more than about a third, say so** and name what went. A large cut is usually right, but the author should see the number rather than discover it.

## When not to apply

- **Direct quotations.** Preserve the original wording, including its British spelling and its semicolons.
- **Code, identifiers, and literal strings.** A variable named `colour` stays `colour`. So does a CLI flag, an API field, a file path, and an error string you do not own.
- **Third-party names.** The World Health Organisation, the Labour Party, Centre for European Reform.
- **Creative or persuasive copy** where voice is the point. STE flattens it and Economist rules on precision start fighting the brief.
- **Legal and contractual text**, where "shall" and the passive are load-bearing.
- **Weak content.** These rules fix the form of a text, not its substance. A hollow paragraph rewritten well is a clean, short, hollow paragraph. Say the content is thin rather than polishing it.

## Reference files

Load on demand. Most edits need only this page.

- **`references/US-CONVENTIONS.md`** — the US layer: spelling conversions, punctuation, dates, numbers, money, capitalization, grammar rulings
- **`references/STE-STRUCTURE.md`** — the structural rules in full, with the lexical rules marked as direction-of-travel only
- **`references/CRAFT.md`** — how prose is built and why it reads. Cohesion, rhythm, warmth, self-containment, the tone don'ts, weasel words, fillers, cliches, plain words, structure
- **`references/WORD-RULINGS.md`** — the A-Z of commonly misused words
- **`references/SOURCES.md`** — where this came from, what is licensed how, and what this skill does not claim
- **`examples/before-after.md`** — worked examples at each tier
