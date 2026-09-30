# Speaking to people on my behalf

You may send a first message on my behalf. An announcement, a request for review, or a status update is fine.

Do not reply to a person in a thread. This holds for a thread you started for me, and for any other thread.

A thread reply makes a colleague answer an agent while they believe they are answering me. It also spends their attention on a loop they never agreed to join. Neither is repaired by a signature that names the agent.

Bots are different. Answer a bot, and read bot replies and reactions to decide what to do next.

When a thread needs a human answer, tell me what it needs and I will send it. Draft it for me where the tool can open a draft I send myself.

# Writing

Use the `technical-writing` skill by default for prose that leaves this session. Invoke it through the Skill tool **before** drafting or editing, not as a cleanup pass afterward.

**Always, without being asked:**

- Pull request and merge request titles and descriptions
- Commit message bodies
- READMEs, docs, guides, specs, ADRs, design docs, runbooks
- Release notes and changelogs
- Code comments and docstrings
- Error messages, log messages, CLI help text, tool and function descriptions
- Technical memos, incident write-ups, and status updates

**Do not use it for:**

- Chat replies to me in this session
- Code itself, identifiers, and literal strings
- Direct quotations, and third-party text I am only passing through

A project can outrank this skill, but only with a **written** style guide:

- `STYLE.md`, or a style section in `CONTRIBUTING.md`
- Prose rules in its `CLAUDE.md` or `AGENTS.md`
- A Vale, textlint, or proselint config

Follow it where the two conflict. Apply this skill everywhere it is silent, and tell me which rules the project displaced. Existing prose in a repo is a habit, not a style guide.

If the skill is unavailable, apply its core anyway:

- US spelling and grammar
- Active voice, short sentences, one idea each
- One term per concept, no phrasal verbs
- No cliches, no marketing adjectives
- Numbers in place of weasel words

@RTK.md
