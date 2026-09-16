# STE Structure

ASD-STE100 is a controlled language built by the AeroSpace and Defence Industries Association of Europe so that maintenance technicians could not misread a manual. Issue 9 (January 2025) holds 53 writing rules in 9 sections. It adds a dictionary of about 900 approved words, each locked to one meaning and one part of speech, and about 1,200 words to avoid.

This skill borrows the rules, not the dictionary. ASD grants free reproduction rights only to eight listed categories of organization, and this is not one of them. See `SOURCES.md`.

That split matters, because the rules divide in two.

**Structural rules describe sentence shape.** They are self-contained, and you can apply and verify them from the description alone. Apply them with confidence.

**Lexical rules are defined by the dictionary.** Without it they degrade from a checkable standard into a preference for plain, consistent words. Apply them as a direction of travel. Never claim STE compliance you cannot verify.

## Structural rules — apply these

| Rule | Do | Don't |
|---|---|---|
| **Active voice** | "The agent deletes the file." | "The file is deleted." Passive is allowed only in descriptive text, and only when the actor is genuinely unknown or irrelevant |
| **One instruction per sentence** | "Open the file. Read line 3." | "Open the file and read line 3, then check whether it matches." |
| **Sentence length** | Tier 1 (machine-read): 20 words. Tier 2 (documentation): 25. Tier 3 (prose): 30, averaging 15-20 | Compound sentences stacked with subordinate clauses |
| **No phrasal verbs** (Rule 9.3) | "Remove the panel." "Start the job." "Contact the owner." | "Take off the panel." "Spin up the job." "Reach out to the owner." A two-word verb means something the parts do not predict |
| **No semicolons** (Rule 8.1) | Split into two sentences | Any semicolon. STE bans the mark outright, not only as a clause join. Every other standard mark stays legal, the em dash included — though an em dash often marks a sentence that wants splitting |
| **Noun clusters cap at 3** | "fuel pump valve", "retry policy config" | "high pressure fuel pump inlet valve assembly", "agent task queue priority handler" |
| **No ellipsis of sentence parts** | Keep the subject, verb, and article explicit even when it runs longer | Dropping words to save space. "Files not backed up will be lost" hides which files |
| **Simple tenses** | Infinitive, imperative, simple present, simple past, simple future, past participle as an adjective | Present perfect and other compound forms — with the exception below |
| **Keep modality** | "The request **may have** failed" stays as it is | Promoting a hedge to a fact, or inventing a certainty the source did not state |
| **One topic per paragraph, 6 sentences max** | Split when the topic turns | Multi-topic paragraphs |
| **Lists for sequences** | A numbered or bulleted list for 3+ steps or conditions | A sequence buried inside one prose sentence |
| **Safety first in the sentence** | "Before you restart the service, drain the queue." Condition or command opens | A warning buried mid-sentence after two clauses of context |

### The present-perfect exception

Aircraft manuals never need the present perfect, so banning it costs the standard nothing. Other text is not so lucky. "The job has completed" means its output is available now. "The job completed" means it finished at some past point. These are different statements, and status text often needs the first.

Keep the compound form where it carries information the simple form cannot: current relevance, or a hedge as in "may have failed." Note the departure. Elsewhere, follow the rule.

## Lexical rules — direction of travel only

| Rule | Do | Don't | Why it is weaker here |
|---|---|---|---|
| **One word, one meaning** | Pick one verb per action and reuse it. Always "check", never rotating check/verify/confirm/validate for the same act | Rotate synonyms for one idea across a document | Consistency within a document is checkable. Which word is the *approved* one is not, without the dictionary |
| **One part of speech per word** | "Apply oil to the valve" (oil as a noun) | "Oil the valve" (oil as a verb) | Whether "oil" is approved as a noun only is a dictionary fact. Prefer the noun when both read equally well. Claim nothing |
| **Verb, not noun** (Rule 3.7) | "Analyze the log." | "Perform an analysis of the log." | Rule 3.7 says use an *approved* verb. Preferring the verb form is safe anywhere. Knowing the approved verb needs the dictionary |
| **Domain terms** | Keep necessary technical nouns and verbs. Define each once if it is not common English | Use jargon you never define | STE explicitly allows a project glossary on top of its base dictionary. The allowance is real. The base dictionary it extends is absent here |

The term lock is where STE and The Economist argue hardest. The Economist varies its verbs for rhythm. STE forbids it. The tier table in SKILL.md settles it. Technical terms are locked at every tier. Ordinary prose verbs relax from Tier 1 (machine-read) up to Tier 3 (prose).

## The six-point scan

Six mechanical habits account for most hard-to-parse English. Each one lets you point at the exact word or mark that breaks it, with no judgment call. Scan for all six before rewriting anything.

1. **Synonym rotation** — one thing gets several names ("the user", "the customer", "the client"). The reader cannot tell whether that is one thing or three. Fix: pick one name and use it every time.
2. **Hedge stacking** — qualifiers pile up until the sentence asserts nothing. "It is important to note that this may potentially help to improve." Fix: state the claim, or delete it. Mind the hedge rule in SKILL.md: cut the throat-clearing, keep the modality.
3. **Nominalization** — an action frozen into a noun: "perform an analysis of", "provides assistance to", "makes a determination". Fix: use the verb.
4. **Marketing adjectives** — words that claim quality instead of showing it: seamless, robust, powerful, cutting-edge, effortless, blazing-fast. Fix: delete, or replace with the measurement that earns the claim.
5. **Run-on sentences** — several ideas strung together with semicolons or em dashes. Fix: one idea per sentence.
6. **Soft phrasal verbs** — spin up, reach out, dive into, kick off, circle back, touch base. Fix: start, contact, read, begin, follow up, meet.

## What STE cannot do

- It fixes the form of a text, not its substance. A hollow paragraph rewritten under these rules is a clean, short, well-punctuated hollow paragraph.
- It is not a compliance certificate. Without ASD's dictionary, this is a clarity discipline inspired by STE, not certified STE authoring. For real aircraft maintenance documentation, request the standard from the [official downloads page](https://www.asd-ste100.org/STE_downloads.html) and check word by word.
- It should not be pushed past clarity. Cutting words is not the goal. Removing ambiguity is. Past a certain point, compression starts costing the reader time instead of saving it. Stop when the sentence is unambiguous, not when it is shortest.
