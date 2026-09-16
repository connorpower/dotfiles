# Craft

What The Economist contributes: judgment about what to say, and the nerve to cut the rest. STE shapes the sentence. This decides whether the sentence deserves to exist.

## Orwell's six rules

The Economist's style guide opens on them, and they still hold.

1. Never use a metaphor, simile, or other figure of speech you are used to seeing in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word, or a jargon word if you can think of an everyday English equivalent.
6. Break any of these rules sooner than say anything outright barbarous.

Rule 6 is the one people forget. A sentence that obeys every rule and reads badly has failed.

## The tone don'ts

- **Do not be stuffy.** Write the way people speak, not the way lawyers and bureaucrats write.
- **Do not be hectoring or arrogant.** People who disagree with you are not stupid. Persuade with evidence, not volume.
- **Do not be too pleased with yourself.** Let the analysis carry it. No self-congratulation, no victory laps in a changelog.
- **Do not be too chatty.** Keep a professional distance. No "Let's dive in!", no "Awesome!", no exclamation points.
- **Do not be too didactic.** Guide. Do not lecture.
- **Get straight in.** No throat-clearing opening. Cut the paragraph that explains what you are about to explain.

## How sentences connect

STE gives you short sentences. It does not tell you how to join them. Sentences with no connective tissue read as a list of facts rather than an argument.

Two techniques do most of the work.

### Old information first, new information last

Open each sentence with something the reader already has. End it on what you are adding. The end of one sentence then feeds the start of the next, and the reader is carried forward instead of restarting every time.

> ❌ The client retries a failed request. The retry budget is 3. Requests are dropped after the budget is exhausted. Callers see a 503.
>
> ✅ The client retries a failed request up to three times. After that budget is exhausted, it drops the request and the caller sees a 503.

Same facts, same rules obeyed. The first reads as a list because every sentence starts from scratch. The second hands each sentence to the next.

**One warning.** Old-before-new is not a license for the passive. "A 503 is returned to the caller" puts old information first by hiding the actor. Reorder the sentence instead of demoting the verb.

### The stress position

English puts its emphasis at the end of a sentence. Put the words that matter there.

| Weaker | Stronger |
|---|---|
| Restart the service after editing this file. | After editing this file, restart the service. |
| A 503 goes to the caller once the budget is exhausted. | Once the budget is exhausted, the caller gets a 503. |
| Data loss can occur if you skip the drain step. | Skip the drain step and you can lose data. |

### Connect with words, not punctuation

The semicolon is banned below Tier 3 (prose), and the em dash is capped. The joins have to be lexical: but, so, because, then, instead, after, once, until, yet. These are short words doing structural work, and they cost less than the punctuation they replace.

## Rhythm

The sentence cap is a ceiling, not a target. Prose that hits 24 words every time tires a reader as fast as prose that runs to 40.

- **Never write three consecutive sentences of the same length and shape.**
- **A short sentence after two long ones lands.** Spend it on the point that matters.
- **Vary how sentences open.** Not every one starts with its subject. A clause of time, condition, or contrast up front changes the shape and usually improves the stress position at the same time.
- **Read it aloud.** Where you run out of breath, split the sentence. Where you flatten out, vary it.

Rhythm also settles the standing complaint against the term lock. One word per concept means writing "the widget" ten times, and that is correct. **Vary the sentence shape, not the noun.** A repeated key term reads as precision. A repeated sentence pattern reads as a machine.

## Warmth without chattiness

Dry is not the same as neutral. Neutral means no spin. Dry means no reader.

Four moves buy readability at Tier 2 (documentation) at no cost in precision:

1. **Address the reader as "you."** "Run the migration," not "the user should run the migration" and not "one must run." An imperative is already second person, which is why procedures read faster than descriptions of procedures.
2. **Give the reason once.** "Drain the queue first, because a restart drops in-flight jobs." One clause of why buys more compliance than three of what.
3. **Name the consequence, not the rule.** "Skip this and the migration fails halfway" beats "this step is required."
4. **Stay concrete.** A real path, a real value, a real error string. An abstract example is a worked example the author declined to work.

What this is not: exclamation points, jokes, "let's dive in," emoji, or calling the reader "folks." The tone don'ts above still hold. Warmth means the reader is present in the text. It does not mean the author is performing.

## Weasel words

Vague terms that look like claims without committing to anything checkable.

**Vague quantifiers:** many, few, several, numerous, various, some, a number of. → Give the number or the share.

**Vague qualifiers:** significant, substantial, considerable, notable, remarkable, dramatic. → Quantify it or cut it.

**Unsourced authority:** "studies show", "experts say", "it is widely believed", "research indicates", "many people think", "best practice suggests". → Name the study, the expert, the team, or drop the claim.

| Weak | Strong |
|---|---|
| Many companies now offer remote work | 43% of S&P 500 companies now offer remote work |
| The project saw significant delays | The project finished four months late |
| Sales increased considerably | Sales rose 23% to $4.2 million |
| Performance improved | p99 latency fell from 840 ms to 210 ms |
| The service is used widely | 12 internal teams call the service |

Replace vague time and place too:

- recently → last month, in Q3, on October 15
- soon → next week, by March, within 30 days
- in the near future → by year end
- in many countries → in the US, Germany, and Japan
- according to reports → according to the IMF's October report

## Fillers

Delete on sight.

**Redundant openings:** It should be noted that. It is important to realize that. The fact of the matter is. For all intents and purposes. At this point in time (→ now). In this day and age (→ today).

**Dead intensifiers:** very unique (→ unique), completely finish (→ finish), absolutely essential (→ essential), totally destroy (→ destroy), extremely critical (→ critical).

**Empty phrases:** in terms of, in the process of, for the purpose of (→ to), in the final analysis, when it comes to, the ability to.

**Tautologies:** advance planning, past history, future plans, end result, final outcome, collaborate together, join together, new innovation, added bonus, close proximity, general consensus, unexpected surprise, free gift.

**Redundant pairs:** each and every, first and foremost, null and void, various and sundry, aid and abet. Keep one.

## Cliches and dead metaphors

Orwell's first rule, applied. A cliche signals a writer who stopped thinking. Replace it with the plain meaning.

| Cliche | Say instead |
|---|---|
| at the end of the day | ultimately, or cut |
| game-changer | say what changes |
| level playing field | fair competition |
| low-hanging fruit | the easiest gains |
| move the needle | say how much it changes |
| paradigm shift | say what kind of change |
| perfect storm | name the factors that coincided |
| silver bullet, holy grail | a simple fix, the ultimate goal |
| sea change, watershed moment | say what changed |
| think outside the box | describe the unconventional idea |
| tip of the iceberg | say what is hidden, and how much |
| double-edged sword | say both effects |
| leave no stone unturned | search thoroughly |
| last but not least | finally |
| deep dive | a close look, or cut |
| best-in-class, industry-leading | give the benchmark |

The test: if the phrase could appear in any company's press release, it is doing no work in yours.

## Plain words

### Jargon and business-speak

| Instead of | Write |
|---|---|
| utilize | use |
| optimize | improve (unless real optimization is meant) |
| facilitate | help, enable |
| implement | build, add, start |
| leverage | use |
| synergy | cooperation |
| stakeholder | name who is affected |
| going forward | from now on |
| action (as a verb) | do, carry out |
| learnings | lessons |
| ideate | think, plan |
| operationalize | put into practice |
| surface (as a verb) | show, report |
| enablement | training, support |

### Long words

| Instead of | Write |
|---|---|
| approximately | about |
| commence | begin, start |
| endeavor | try |
| purchase | buy |
| terminate | end, stop |
| obtain | get |
| ascertain | find out |
| demonstrate | show |
| sufficient | enough |
| additional | more |
| numerous | many |
| regarding, with regard to | about |
| prior to | before |
| subsequent to | after |
| in order to | to |
| in the event that | if |
| due to the fact that | because |
| a majority of | most |
| at this time | now |

**The test:** would you use this word talking to a colleague at lunch? If not, do not write it.

### Inclusive language

Prefer the neutral term where it reads naturally:

- artificial or synthetic, not man-made
- workforce or staff, not manpower
- firefighter, police officer, flight attendant
- chair or head, not chairman, when the role is generic

Use they/them when a person's pronouns are unknown. Respect stated pronouns.

The Economist itself retains "chairman". This skill does not follow it there.

## Label register

Block language — the grammar of headlines, captions, catalog entries, and slide titles — drops the verb and hangs modifiers off a noun phrase:

> Four worked examples, one per tier plus the two traps that catch most rewrites.

It is a real register, and it is correct on a real label: a heading, a table cell, a figure caption, a nav entry. A caption works because the thing it names sits right there.

In running prose it fails twice over.

**It collides with the reader's expectation.** Prose sets up a speaker addressing a reader. A verbless fragment opens a slot for a predicate that never arrives. The line then reads as a machine labeling its own output, not as a person telling you something.

**It has no truth conditions.** This is the serious one. "One per tier" is a tag, not a claim. Nothing predicates it, so nothing checks it. The example above stood in this skill for two revisions while being false. The file it introduced holds two Tier 1 (machine-read) examples, not one per tier. Written as a claim — "one example per tier" — the arithmetic is visible and the error surfaces at once.

Brevity rules push hard toward this register. A sentence cap and "cut every spare word" both reward dropping the verb, and neither notices that the claim left with it. **A cap is never a reason to drop a predicate.** If a sentence will not fit under the cap with its verb intact, split the sentence.

The fully unpacked version is rarely the fix either:

| Version | Problem |
|---|---|
| "Four worked examples, one per tier plus the two traps." | No verb, so no checkable claim |
| "This document shows four worked examples. One example is given per tier. The two traps are also demonstrated." | Self-reference, two agentless passives, three sentences for one idea |
| "Four examples follow: two at Tier 1 (machine-read), one each at Tier 2 (documentation) and Tier 3 (prose)." | Finite verb, no announcement, glossed labels |

Keep the verb. Drop the announcement.

## Writing for a reader who lands mid-document

Readers do not start at the top. They arrive from a search result, a deep link, a diff, a chat message, or a log line. They land in the middle of your document with no idea what came before.

Write so that landing works.

- **Define a term where it first appears.** A glossary is a backstop, not a mechanism. A reader who has to go find it has already left.
- **Cut every backward reference that carries meaning.** "As mentioned above," "as discussed earlier," "the aforementioned approach." Repeat the three words instead. Repetition costs the reader less than a scroll.
- **Cut every forward reference that gates comprehension.** If this paragraph cannot be understood until the next section, the sections are in the wrong order.
- **Keep a pronoun near its antecedent.** Same sentence, or the one before, with no competing noun in between. Otherwise repeat the noun. Repeating a noun is not a style failure.
- **Name what a link points to.** "See the retry policy," never "see here" or "see this document."
- **Budget your acronyms.** Past about three distinct acronyms in a paragraph, the reader is substituting symbols rather than reading.

**The test:** could someone who landed on this heading from a search result read the section and get what they came for? They will try.

## Gloss every label

A label points at a meaning. It does not carry one.

| Bare | Glossed |
|---|---|
| Tier 1 | Tier 1 (machine-read) |
| phase 2 | phase 2 (the migration) |
| ADR-014 | ADR-014 (the retry-policy decision) |
| E_CONF_02 | E_CONF_02 (config unreadable) |
| Project Bluebird | Project Bluebird (the billing rewrite) |
| the amber state | the amber state (degraded, still serving) |

**Gloss at first use in each place a reader can land** — not once per document. Readers arrive from a search result, a deep link, a diff, a log line, or a table of contents. They do not start at the top.

- First use in the document, and first use in each major section
- Any heading or list item that could be read out of order
- Every Tier 1 (machine-read) string, every single time. An error message citing "phase 2" tells the reader nothing, and they have no document to scroll up in

**Do not gloss when:**

- The name already carries the meaning. "The retry-policy doc" needs no parenthesis
- You glossed it in the same paragraph. Twice is noise
- The label is universal to the audience: HTTP 404, exit 1, `main`

**In a dense table, use a one-line legend** instead of glossing every cell. A legend under the heading costs one line. Glossing 20 cells costs the table its readability.

**Give every label a short name once, and the gloss costs two words.** The tiers in this skill are machine-read, documentation, and prose, which is why they can be glossed inline anywhere without bloat. A label you cannot gloss in two words is a label that needs renaming.

## Structure

### Lead with the point

The main claim goes in the first sentence, not the third paragraph. The most common defect in technical writing is the document that spends four paragraphs on context before saying what happened.

- **Error message:** what failed, then why, then what to do.
- **Incident write-up:** what broke, who it hit, for how long. Timeline after.
- **PR description:** what changed and why, in the first line. Implementation notes after.
- **Design doc:** the recommendation first, then the alternatives and the reasoning.
- **Release note:** what the reader can now do that they could not do before.

### Paragraphs

- One topic each. Six sentences maximum, three to five is the norm.
- Open with the topic sentence. Evidence follows it.
- Every paragraph advances the argument. If one only restates the last, delete it.

### Endings

A conclusion that summarizes what the reader just read adds nothing. Either say what follows from it, or stop. Most technical documents should stop.

## Attribution

Claims need owners.

| Weak | Strong |
|---|---|
| It is believed rates will fall | The Federal Reserve expects two cuts this year |
| Critics argue the policy will fail | The Budget Office projects the policy will cost $2 billion more than planned |
| The migration is considered risky | Two of the three on-call engineers flagged the migration as risky |

If you cannot name the source, you probably cannot support the claim. Cut it.
