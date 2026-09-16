# Before and After

Four examples follow: two at Tier 1 (machine-read), one each at Tier 2 (documentation) and Tier 3 (prose). The two traps that catch most rewrites come after them.

Note what the rewrites do **not** do: none of them invents a number, a cause, or a timeout that the original did not state. Where the original was vague, the rewrite stays vague and says so.

---

## Tier 1 (machine-read) — Tool description

**Before**

> This tool can be utilised to spin up a new worker process; it will return a handle which may then be leveraged by the caller in order to monitor progress, and it is important to note that the operation is not guaranteed to be instantaneous.

**After**

> Starts a new worker process. Returns a handle. Use the handle to monitor progress. The worker does not become ready immediately.

| Rule | Original | Revised |
|---|---|---|
| British spelling | "utilised" | "use" — and the word was jargon anyway |
| Phrasal verb | "spin up" | "starts" |
| Semicolon | 1 instance | Split into sentences |
| Jargon | "leveraged by the caller" | "use the handle" |
| Filler | "in order to" | "to" |
| Throat-clearing | "it is important to note that" | Deleted |
| Passive | "may then be leveraged" | "use the handle" |
| Sentence length | 41 words | 4 sentences, 20 words total |

Kept as-is: "not guaranteed to be instantaneous" became "does not become ready immediately," not "takes up to 30 seconds." The source gave no timeout. The rewrite cannot supply one.

---

## Tier 1 (machine-read) — Error message

**Before**

> An error was encountered whilst attempting to process your request due to the fact that the configuration file could not be read; please ensure that appropriate permissions have been configured and then simply try again.

**After**

> Cannot read the configuration file. The service needs read access to it. Give the service user read access, then retry.

| Rule | Original | Revised |
|---|---|---|
| British usage | "whilst" | "while" — then cut entirely |
| Passive | "an error was encountered", "permissions have been configured" | "cannot read", "give the service user read access" |
| Filler | "due to the fact that" | "because" — then cut |
| Semicolon | 1 instance | Split |
| Condescension | "simply try again" | "retry" |
| Nominalization | "ensure that appropriate permissions have been configured" | "give read access" |
| Lede | The failure appeared in clause 3 | The failure opens the message |

An error message has three jobs, in this order: what failed, why, what to do. The original buried all three.

---

## Tier 2 (documentation) — README

**Before**

> Our cutting-edge library provides a seamless way to handle retries. It has been designed from the ground up to be extremely robust, and many users have found that it significantly improves the reliability of their services. In order to utilise it, simply install the package and initialise the client, and then it will automatically retry any requests which fail.

**After**

> This library retries failed requests. Install the package, then initialize the client. The client retries a failed request automatically.

| Rule | Original | Revised |
|---|---|---|
| Marketing adjectives | "cutting-edge", "seamless", "extremely robust" | Deleted. None of them was measurable |
| Cliche | "from the ground up" | Deleted |
| Weasel words | "many users", "significantly improves" | Cut — see below |
| Passive | "it has been designed" | "this library retries" |
| British spelling | "utilise", "initialise" | "use", "initialize" |
| Filler | "in order to" | "to" — then cut |
| Condescension | "simply install" | "install" |
| Restrictive clause | "requests which fail" | "a failed request" |

Cut: "many users have found that it significantly improves the reliability of their services." It is an unsourced claim with no number behind it. Restore it with a benchmark, or leave it out.

---

## Tier 3 (prose) — Incident write-up

Tier 3 (prose) keeps a voice. It does not keep the cliches.

**Before**

> This document aims to provide an overview of the incident that occurred on April 3rd. Checkout was unavailable for 47 minutes. At the end of the day, a perfect storm of factors came together. It should be noted that the on-call engineer was paged at approximately 3am, and it could be argued that the runbook was somewhat out of date, which may have contributed to the delay in resolution.

**After**

> Checkout was down for 47 minutes on April 3. Several failures coincided. The on-call engineer was paged at about 3 a.m. and worked from a runbook that was out of date, which may have added to the delay.

| Rule | Original | Revised |
|---|---|---|
| Buried lede | Opened by announcing itself | Opens with the outage and its length |
| Throat-clearing | "this document aims to provide an overview of", "it should be noted that", "it could be argued that" | Deleted |
| Cliche | "at the end of the day", "perfect storm of factors came together" | "several failures coincided" |
| Long word | "approximately" | "about" |
| Date and time format | "April 3rd", "3am" | "April 3", "3 a.m." |
| Nominalization | "the delay in resolution" | "the delay" |

Two judgment calls worth naming:

- **"was paged" stayed passive.** The pager is the actor, and no reader cares which system sent it. This is the case the rule leaves open.
- **"may have added to the delay" kept its hedge.** "Caused the delay" would be a different and stronger claim than the author made. Compare "it could be argued that," which was deleted in the same sentence: that phrase carried no claim at all.

Flagged, not fixed: "several failures coincided" still needs a number. The original did not give one, so the rewrite cannot either. Ask the author.

---

## The two traps

### Trap 1: cutting a hedge because it is short

| Original | Bad rewrite | Why it fails |
|---|---|---|
| "The request may have failed." | "The request failed." | A possibility became a fact |
| "This is likely to reduce cost." | "This reduces cost." | A forecast became a result |
| "Roughly 200 nodes were affected." | "200 nodes were affected." | An estimate became a count |

A word cap tempts you toward exactly the words that carry confidence. Delete the word and test: if the truth conditions of the claim change, the word was content.

### Trap 2: supplying the detail the original lacked

| Original | Bad rewrite | Why it fails |
|---|---|---|
| "The operation is not instantaneous." | "The operation takes up to 30 seconds." | Invented a bound |
| "Several teams use it." | "Twelve teams use it." | Invented a count |
| "It failed because of the config." | "It failed because the config had an invalid retry policy." | Invented a mechanism |

A rewrite that reads better because it supplied a cause, a number, or a limit has stopped being a rewrite. Flag the gap instead.
