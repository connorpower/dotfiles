# technical-writing

A Claude Code skill for writing and editing technical English that is precise, plain, and hard to misread — without going flat.

It merges three sources into one house style:

| Source | Contributes |
|---|---|
| **The Economist Style Guide** | What to say. Lead with the point, prefer the short word, cut the spare one, replace vague claims with numbers |
| **ASD-STE100 Simplified Technical English** | How to shape it. Short active sentences, one instruction each, one name per thing, no phrasal verbs, no semicolons |
| **US spelling and grammar** | The dialect layer, applied at every tier and overriding The Economist's British conventions |

## What it achieves

- **One consistent voice** across READMEs, PR descriptions, commit bodies, release notes, code comments, error messages, and memos.
- **Strings that survive being read alone.** An error message or tool description gets the discipline that was built so aircraft technicians could not misread a manual.
- **Claims you can check.** Weasel words become numbers and unsourced authority gets a name. Every sentence keeps a finite verb, because a label has no truth conditions and nothing checks it.
- **Prose that still reads.** Cohesion, rhythm, and reader address are first-class rules, so the output does not arrive as a list of correct, unreadable facts.
- **No invented detail.** Facts, conditions, scope qualifiers, numbers, and hedges survive the edit intact.

## The three tiers

The two source guides disagree. Rather than improvise, the skill picks a tier from what you are writing.

| | Tier 1 (machine-read) | Tier 2 (documentation) | Tier 3 (prose) |
|---|---|---|---|
| **Text** | Error messages, tool descriptions, prompts, runbooks, safety text | READMEs, guides, specs, ADRs, release notes, code comments | Memos, exec summaries, incident write-ups, announcements |
| **Who wins** | STE, outright | STE structure + Economist word choice | Economist voice, STE as a backstop |
| **Sentence cap** | 20 words | 25 words | 30 words, 15-20 average |

Tier 2 (documentation) is the default. When two tiers both fit, the stricter one wins.

## How it settles conflicts

Sixteen rulings are decided in advance. Four that show the shape of it:

- **Serial comma: used**, against The Economist, on STE grounds. A list without it has two readings.
- **Hedges: split.** Throat-clearing goes ("it could be argued that"). Modality stays ("may have failed"). Delete the word — if the truth conditions change, it was content, not padding.
- **Dates: US.** April 5, 2025 in prose. 2025-04-05 in logs, filenames, and machine-read strings.
- **US idiom: allowed.** But "reach out to" still becomes "contact" — as a phrasal verb, not as an Americanism.

## Guards

- **A project's written style guide outranks this skill**, rule by rule, and only if written. Existing repo prose is a habit, not an instruction. When project guidance displaces a rule, the output says so on an `Overruled by project style:` line.
- **Scope is fixed.** Cutting words is in scope. Cutting content is not. No restructuring, no deletions, no additions.
- **Weak content gets flagged, not polished.** These rules fix form, not substance.

## Usage

Invoke it directly:

```
/technical-writing            # or ask: "give this a style pass"
```

By default it returns the rewritten text, then a capped table of what changed, plus any of three lines that apply: `Kept as-is:`, `Flagged, not fixed:`, `Overruled by project style:`. Ask for "rewrite only" or "review only" to change the shape.

The user-level `~/.claude/CLAUDE.md` makes it the default for technical documentation contexts without being asked.

## Files

```
SKILL.md                      tiers, conflict rulings, workflow, output format
references/US-CONVENTIONS.md  spelling, punctuation, dates, numbers, grammar
references/STE-STRUCTURE.md   structural rules (applied) vs lexical (advisory)
references/CRAFT.md           cohesion, rhythm, warmth, self-containment, tone, cliches
references/WORD-RULINGS.md    A-Z of misused words, plus technical-writing rulings
references/SOURCES.md         attribution, licensing, and what this does not claim
examples/before-after.md      four worked examples and the two traps
```

## What it will not do

Rewrite direct quotations, code, identifiers, or literal strings. Convert third-party proper nouns. Flatten creative or persuasive copy. Touch legal text where "shall" and the passive are load-bearing. Certify a document as STE-compliant — the official ~900-word dictionary is not redistributable and is not reproduced here.

## Attribution

Derived from two MIT-licensed projects: [economist-style-guide-plugin](https://github.com/TAJD/economist-style-guide-plugin) by Tom Dickson, and [asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill) by Dustin Yuchen Teng. Neither *The Economist Style Guide* nor ASD-STE100 Issue 9 is reproduced. See `references/SOURCES.md` for what changed and why.
