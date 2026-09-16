# US Conventions

The dialect layer. It overrides The Economist's British defaults everywhere, at every tier.

Do not detect the document's dialect and match it. Convert it. The only exceptions are direct quotations, proper nouns, code identifiers, and literal strings (see *When not to apply* in SKILL.md).

## Spelling

### -ize, -yze, -or, -er

| Use | Not |
|---|---|
| organize, organization | organise, organisation |
| realize, recognize, prioritize | realise, recognise, prioritise |
| analyze, paralyze, catalyze | analyse, paralyse, catalyse |
| color, favor, labor, honor, behavior, neighbor | colour, favour, labour, honour, behaviour, neighbour |
| center, theater, meter, liter, fiber | centre, theatre, metre, litre, fibre |

Watch the -yze family: only the verb changes. *Analyse* becomes *analyze*, but the noun *analysis* is spelled the same in both dialects.

### Single vs double consonants

| Use | Not |
|---|---|
| traveling, traveled, traveler | travelling, travelled, traveller |
| canceled, canceling | cancelled, cancelling |
| modeling, labeling, signaling | modelling, labelling, signalling |
| focused, focusing | focussed, focussing |

US doubles the consonant only when the final syllable is stressed: *referred*, *occurred*, *committed*, *transferred*.

### Other conversions

| Use | Not |
|---|---|
| defense, offense, license (noun and verb), practice (noun and verb) | defence, offence, licence/license split, practice/practise split |
| judgment, acknowledgment | judgement, acknowledgement |
| gray | grey |
| catalog, dialog (in UI), analog | catalogue, dialogue (in UI), analogue |
| program | programme |
| airplane, aluminum, math, toward, afterward | aeroplane, aluminium, maths, towards, afterwards |
| check (payment), curb (roadside), tire (wheel) | cheque, kerb, tyre |
| encyclopedia, medieval, estrogen, archeology | encyclopaedia, mediaeval, oestrogen, archaeology |

*Dialogue* keeps its -ue when it means conversation. *Dialog* is the UI element.

## Punctuation

### Serial comma — always

The Economist omits it. This skill does not.

- "The service validates, transforms, and stores each record."
- "We tested on Linux, macOS, and Windows."

The reason is STE's, not style: a list without the final comma has two readings, and the reader has to pick one. Machine readers pick badly.

### Quotation marks

Double quotes outside, single inside: `She called it "a clear 'no' from the board."`

Placement of commas and periods:

- **Inside, in prose.** US convention: `The build is "green," so ship it.`
- **Outside, for literal values.** When the quoted thing is a string, path, command, flag, or code token, a comma inside it changes the value: `Set the mode to "strict", not "lax".` Better still, use code formatting and dodge the question: ``Set the mode to `strict`.``

Colons and semicolons always sit outside. Question marks and exclamation points go inside only when they belong to the quoted material.

### Periods in abbreviations

US takes the points where The Economist drops them.

- Honorifics: Mr., Mrs., Ms., Dr., Prof., Jr., Sr.
- Latin: e.g., i.e., etc., et al., vs. — each followed by a comma when it introduces a clause: "some formats, e.g., JSON and YAML"
- Initials: J.K. Rowling, W.E.B. Du Bois
- No points in acronyms and initialisms: US, UK, GDP, API, HTTP, NATO, CEO

In machine-read and documentation text (Tiers 1-2), prefer "for example" over *e.g.* and "that is" over *i.e.*. They are plainer and they never get mixed up.

### Dashes and hyphens

- **Em dash**, closed up, no spaces: `The policy—announced in March—failed.` Per-tier limits apply. See SKILL.md.
- **En dash** for ranges and for compound modifiers whose parts are open compounds: `pages 20–30`, `2020–2024`, `New York–London flight`.
- **Hyphen** for compound modifiers before a noun, not after: *a well-known bug*, but *the bug is well known*. Never hyphenate an -ly adverb: *a highly available cluster*.
- Numbers and ages: *a five-year-old record*, *a 30-day window*, *a two-thirds majority*.
- US closes up what British hyphenates: *cooperate*, *coordinate*, *prewar*, *postwar*, *email*, *nonzero*, *reenter*. Keep the hyphen only when the closed form misreads: *re-sign* (sign again) vs *resign*.

### Other marks

- One space after a period, never two.
- No exclamation points. Rhetorical questions almost never.
- Ellipses only inside quoted material to mark an omission. Never to trail off.
- Parentheses: if the whole sentence is inside them, the period goes inside too.

## Dates and times

| Context | Format |
|---|---|
| Prose | April 5, 2025 — comma after the year when the sentence continues: "On April 5, 2025, the service failed." |
| Prose, no day | April 2025 — no comma |
| Logs, filenames, tables, machine strings, API fields | 2025-04-05 (ISO 8601) |
| Timestamps | 2025-04-05T14:30:00Z — always state the zone |
| Clock time in prose | 3 p.m., 9:30 a.m. — or use the 24-hour clock in operational text |
| Decades | the 1990s, the '90s — no apostrophe before the s |
| Ranges | 2020–2024, April–June — en dash |

Never write a numeric date as 4/5/25. It reads as April 5 in the US and May 4 nearly everywhere else.

Days and months are capitalized. Seasons are not, and they are ambiguous across hemispheres — give a month or a quarter instead.

## Numbers

**Spell out one through ten. Use figures from 11.** "Three retries," "27 nodes."

**Always figures, regardless:**

- Percentages: 5%, 2.5% — the symbol closed up, no space
- Money: $5, $1.2 million
- Measurements and units: 5 kg, 250 ms, 3 GB, 40 Mbps — space between number and unit, except for % and °
- Versions, ports, exit codes, HTTP statuses, parameters: v2, port 8080, exit 1, HTTP 404
- Numbered steps, chapters, figures, tables: step 3, figure 2
- Ages over ten, dates, times, page numbers
- Anything in a table, chart, or machine-read string
- Every quantity in Tier 1 (machine-read) text

**Formatting:**

- Comma separators from four digits: 1,250 — 9,000 — 1,000,000
- Decimal point, never a decimal comma: 4.7%, not 4,7%
- Money in prose spells the scale: $5 million, $3.2 billion, $1 trillion. Tables and charts may abbreviate: $5m, $3.2bn, $1trn
- Percentage *points* for a change in a rate: "the rate rose from 3% to 5%, up two percentage points" — not "up 2%"
- Ratios and multiples: "three times larger," "a 3x speedup" in technical text
- Never open a sentence with a numeral. "Twenty-seven nodes failed," or rewrite: "The outage took down 27 nodes."
- Round to the precision you can defend. 23%, not 23.47%, unless the decimals carry information.

## Grammar rulings

- **Collective nouns are singular.** "The team is shipping." "The company has 40 engineers." "The government is divided."
- **"Different from,"** not *different than* or *different to*.
- **"Try to,"** not *try and*.
- **"Toward," "afterward," "forward"** — no trailing s.
- **"Will," not "shall."** *Shall* survives only in contractual text.
- **"Gotten"** is standard US for the past participle of *get* when it means acquire or become: "the latency has gotten worse." *Have got* stays for possession and obligation.
- **"Around" and "about"** both work for approximation. *Approximately* is the long word. Use *about*.
- **Compared with** when you are noting differences. **Compared to** when you are likening.
- **That vs which.** *That* introduces a restrictive clause with no comma: "the file that failed." *Which* introduces a non-restrictive clause with a comma: "the config file, which we ship by default." US English keeps this distinction more strictly than British does. STE depends on it, because the comma is the only signal of scope.
- **Titles and roles are lowercase** unless they sit directly before a name: "Jerome Powell, chairman of the Federal Reserve," but "Chairman Jerome Powell." Prefer the first.
- **People:** full name on first mention, honorific plus surname after — "Janet Yellen ... Ms. Yellen." In most technical documents, surname alone is fine after first mention. Be consistent.

## Capitalization

- **Headings: sentence case.** "Configuring the retry policy." Capitalize only the first word and proper nouns.
- **Product and feature names** take the capitalization their owner uses. Generic descriptions do not: "the Kubernetes scheduler," but "a scheduler."
- **Institutions** are capitalized when specific, lowercase when generic: "the Federal Reserve" but "the central bank," and "Congress" but "the legislature."
- **Do not capitalize for emphasis.** No Important Concepts in Title Case mid-sentence.
- **Acronyms:** spell out on first use with the acronym in parentheses, then use the acronym: "a service level objective (SLO)." Skip the expansion for acronyms your whole audience knows (API, HTTP, CPU). Do not expand an acronym you use only once — just say the words.
