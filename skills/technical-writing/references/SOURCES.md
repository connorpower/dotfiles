# Sources and Attribution

This skill is a synthesis of three inputs. None of them is reproduced whole.

## The Economist Style Guide

The craft layer — tone, precision, cliche, word rulings, structure — derives from the [economist-style-guide-plugin](https://github.com/TAJD/economist-style-guide-plugin) by Tom Dickson, MIT licensed, © 2025. That plugin is itself a distillation of *The Economist Style Guide*, which is a copyrighted work published by The Economist Group. Nothing here reproduces the book.

Changed from that source:
- **Dialect.** The original detects and matches the document's dialect. This skill converts to US English at every tier.
- **Serial comma.** The Economist omits it. This skill uses it, on STE grounds.
- **Dates, honorifics, and abbreviation points** follow US convention, not Economist convention.
- **Money** spells the scale word in prose ($5 million) rather than abbreviating it ($5m).
- **"Chairman"** is not retained as a generic role title.
- **Output** is a rewrite plus a change table, not a review report.

## ASD-STE100 Simplified Technical English

The structural layer derives from the [asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill) by Dustin Yuchen Teng, MIT licensed, © 2026.

The underlying standard is ASD-STE100 Issue 9 (January 2025), maintained by the Simplified Technical English Maintenance Group. It is free to obtain but **not** free to redistribute. Issue 9, page 2 reserves reproduction to eight listed categories of organization:

- ASD, AIA, and AIAC member associations
- Their member companies and those companies' customers
- Defense ministries of member states
- A4A, and airworthiness authorities
- Universities and research institutes, for education

This skill is in none of them.

So this skill encodes the **rule categories**, not the standard's text, and **not** the roughly 900-word approved dictionary. That is why `STE-STRUCTURE.md` splits structural rules (applied) from lexical rules (direction of travel only).

Changed from that source:
- **Tiers.** The original has two modes (Strict, STE-flavored). This has three, keyed to document type, and it merges Economist craft into Tier 2 (documentation) and Tier 3 (prose).
- **Output.** The original returns the rewritten text alone by default. This returns the text plus a capped change table.

### What this skill does not claim

It is not a certified STE authoring tool and it cannot produce a guaranteed STE-compliant document. For real aerospace or defense maintenance documentation, request the standard from the [official downloads page](https://www.asd-ste100.org/STE_downloads.html) and check word by word against the real dictionary. That page is a request form that emails a link, not a direct download.

## US spelling and grammar

Conventions in `US-CONVENTIONS.md` follow mainstream US publishing practice. Where Chicago and AP disagree, they lean on *The Chicago Manual of Style*. The one departure is headings, which use sentence case rather than Chicago's title case, following modern technical documentation practice.

## Further reading

- [ASD-STE100 official site](https://www.asd-ste100.org/)
- [ASD-STE100 — About STE](https://www.asd-ste100.org/about_STE.html)
- [TechScribe — ASD-STE100 Simplified Technical English](https://www.techscribe.co.uk/techw/asd-simplified-technical-english.htm)
- [Simplified Technical English — Wikipedia](https://en.wikipedia.org/wiki/Simplified_Technical_English)
