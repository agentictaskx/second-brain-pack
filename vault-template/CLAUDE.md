# Your LLM Wiki

**Schema version: 2**

This is a personal knowledge base following the [LLM Wiki pattern](raw/framework.md) by Andrej Karpathy. The LLM incrementally builds and maintains a persistent wiki — structured, interlinked markdown files. The LLM handles all bookkeeping; you curate sources, direct analysis, and think.

**Your markdown editor is the IDE; the LLM is the programmer; the wiki is the codebase.**

## Architecture

Three layers:

| Layer | Location | Who Writes | Who Reads |
|-------|----------|-----------|-----------|
| **Raw sources** | `raw/` | LLM captures, never edits after | LLM + You |
| **Wiki** | `wiki/`, `index.md`, `log.md` | LLM owns entirely | LLM + You |
| **Schema** | This file (`CLAUDE.md`) | You + LLM co-evolve | LLM |

## Vault Structure

```
second-brain/
├── CLAUDE.md          <- you are here (the schema)
├── index.md           <- wiki catalog, LLM reads first for queries
├── log.md             <- event log, append-only
├── raw/               <- immutable sources
│   ├── articles/      emails/  meetings/  chats/  channels/
│   ├── documents/     books/   ideas/     assets/
├── wiki/              <- LLM-maintained knowledge
│   ├── projects/      <- folder: one .md per project
│   ├── reviews/       <- folder: one .md per weekly/monthly review
│   ├── overviews/     <- folder: one .md per synthesis
│   ├── people.md      <- all people in one page
│   ├── tools.md       <- all tools/MCPs/apps in one page
│   ├── channels.md    <- all channels/chats in one page
│   ├── bookmarks.md   <- curated bookmark lists
│   ├── concepts.md    <- ideas, frameworks, mental models
│   ├── decisions.md   <- decision log
│   ├── todo.md        <- living: tasks, action items, follow-ups
│   └── top-of-mind.md <- living: current themes, priorities
└── templates/
```

## Conventions

### Frontmatter
Every page gets YAML frontmatter:
```yaml
---
title: Page Title
date: YYYY-MM-DD
type: source | wiki | wiki-living
tags: [relevant, tags]
---
```

**Additional fields by page type:**
- Wiki pages: add `source_count: N` (how many sources contributed) and `last_updated: YYYY-MM-DD`
- Entity pages (people, projects): add `entity_type: person | project | tool | channel`
- Source pages: add `source: URL-or-path` for the original source location

### Naming
- Filenames: kebab-case (e.g., `project-alpha.md`, `jane-doe.md`)
- Date-prefixed for temporal sources: `YYYY-MM-DD-description.md`
- Wiki page filenames match the topic: `wiki/people.md`, `wiki/tools.md`

### Links
- Use `[[wikilinks]]` for internal links (works in Obsidian, VS Code with extensions, and many markdown editors)
- Link from source pages to wiki pages and vice versa
- **Bidirectional linking:** If page A links to page B, page B should link back. When linking to a page that doesn't exist, create a stub.
- **Contradictions:** When new information contradicts existing wiki content, note the contradiction explicitly — never silently overwrite. Use format: `> [!contradiction] [source: [[new-source]]] contradicts [source: [[old-source]]]: [explanation]`. Newer information generally supersedes older, but preserve both perspectives until resolved.
- Cross-reference liberally — connections are as valuable as content

### Tags
- Use hierarchical tags where useful: `topic/subtopic` (e.g., `project/alpha`, `people/engineering`)
- Keep tags consistent — check existing tags before creating new ones
- Tag hierarchy helps filter and navigate as the wiki grows

### Wiki Files vs Folders
- **Folders** for things with many individual pages: `projects/`, `reviews/`, `overviews/`
- **Single files** for things that work as one page with sections: `people.md`, `tools.md`, `channels.md`, `bookmarks.md`, `concepts.md`, `decisions.md`, `todo.md`, `top-of-mind.md`
- If any file grows too large to navigate, split it into a folder during lint

---

## Operations

### Ingest

When the user says "ingest this", "file this", "save this", "process this", or drops a source:

1. **Read** the source material
2. **Discuss** key takeaways with the user
3. **Save** source page in `raw/{type}/` — immutable after creation
   - Frontmatter: title, date, type: source, tags, source URL if applicable
   - Content: full text or summary of the source
4. **Update wiki pages** — every piece of new information goes to its natural home page. If a wiki page exists, append new context. If not, consider creating it (ask the user if unsure).

   **Entity routing table:**

   | Entity Type | Home Page | Key Metadata to Capture |
   |-------------|-----------|------------------------|
   | People | `wiki/people.md` | Name, alias, email, role, team, squad, location, what they care about, recent activity |
   | Projects | `wiki/projects/{name}.md` | Status, tracking IDs, milestones, squad structure, blockers, architecture |
   | Links/URLs | `wiki/bookmarks.md` | URL, description, category, source context |
   | Channels | `wiki/channels.md` | Channel name, IDs, purpose, key people |
   | Tools | `wiki/tools.md` | Tool name, what it does, setup notes |
   | Decisions | `wiki/decisions.md` | What was decided, rationale, date, who decided |
   | Concepts | `wiki/concepts.md` | Concept name, description, source, relevance |
   | Tasks | `wiki/todo.md` | Description, source, added date, due date |
   | Priorities | `wiki/top-of-mind.md` | Current focus areas, recurring themes, open questions |

   **Metadata richness:** Don't just record names — capture context. For people: what they care about, what they recently delivered. For links: why it matters, not just the URL. For projects: tracking IDs across all systems. The more context per entity, the better future queries work.
5. **Extract action items** -> add to `wiki/todo.md` using the task format:
   `- [ ] Description` `` `src:[[raw/source-page]]` `` `` `added:YYYY-MM-DD` `` `` `due:YYYY-MM-DD` `` (due is optional)
   - Check for duplicates before adding (match by description + source)
   - Place in appropriate section: Do Today / Do This Week / Waiting / Backlog
6. **Cross-link and cite** — add `[[wikilinks]]` between source page and all touched wiki pages. Every claim in a wiki page should cite its source inline:
   `"Reached 94.3% accuracy [source: [[raw/source-page|Source Title]]]"`
   This makes the wiki auditable — when someone asks "where did this come from?" the answer is right there.
7. **Update index.md** — add/update entries for any new or modified wiki pages. Every wiki page must appear in the index. Format: `- [[path|Title]] — one-line summary`
8. **Append to log.md** — `## [YYYY-MM-DD] ingest | {type} | {title}`

Not every ingest touches all steps. A simple FYI email may only need steps 1-3, 7-8. A strategic meeting may touch all 8. Use judgment.

A single source might touch 10-15 wiki pages. That's normal and good.

### Usage Logging

**Every `/second-brain` invocation gets logged** in `wiki/usage-log.md` — append a row with: date, operation type (ingest/query/lint/feedback), input summary, outcome, and pages touched. This enables skill optimization over time.

### Query

When the user asks a question, searches for something, or asks for a summary/report:

1. **Read `index.md`** to find relevant pages
2. **Read identified pages** — drill into wiki pages and source pages as needed
3. **Synthesize** an answer with `[[wikilinks]]` citations
4. **File back** — if the answer is a useful synthesis (weekly summary, analysis, comparison), save it as a wiki page:
   - Weekly summaries -> `wiki/reviews/weekly-YYYY-Www.md`
   - Monthly reports -> `wiki/reviews/monthly-YYYY-MM.md`
   - Analyses/comparisons -> `wiki/overviews/{topic}.md`
5. **Auto-generate todos** — if the query reveals action items, add to `wiki/todo.md`
6. **Two outputs rule** — output one is the answer to the user. Output two is updates to relevant wiki pages. If the query produced a valuable synthesis, comparison, or connection, always ask: "Should I file this back into the wiki?" This is how the wiki compounds — without it, good answers evaporate into chat history.

Query types:
- **Search**: "What do I know about X?" -> list relevant pages
- **Look up**: "What's Jane's email?" -> read people.md
- **Synthesize**: "Write my weekly summary" -> read recent sources + project pages -> generate review
- **Auto-todos**: "What action items do I have?" -> scan recent ingests + todo.md
- **Follow-ups**: "What am I waiting on?" -> read todo.md waiting section

### Lint

When the user asks for "health check", "lint", "check wiki", or weekly maintenance:

1. **Todo accountability**:
   - Mark done items `[x]` if evidence in recent ingests shows completion — add `done:YYYY-MM-DD`
   - Flag items open 7+ days (check `added:` date): "This has been open since [date]"
   - Check follow-ups with no update in 7+ days: "No update since [date]. Follow up?"
   - Check for duplicate tasks (same description + source) — merge if found
2. **Wiki health**:
   - Find stale pages (not updated in 30+ days) — suggest refresh or archive
   - Find orphan pages (no inbound links) — suggest connections
   - Find broken `[[wikilinks]]` pointing to non-existent pages — suggest creation
   - **Check bidirectional links** — if page A links to page B, verify page B links back. Fix any one-directional links.
   - Find missing cross-references between related pages
   - Find contradictions between pages (newer sources may supersede older claims)
3. **Gaps**:
   - Suggest new sources or questions to fill knowledge gaps
   - Surface recurring themes from recent ingests -> update `wiki/top-of-mind.md`
4. **Overview refresh**:
   - Update `wiki/overview.md` with a high-level synthesis of the entire wiki's current state
5. **Index maintenance**:
   - **Regenerate `index.md`** by scanning all files in `wiki/` — every wiki page must have an entry
   - Compare index entries against actual files — flag pages missing from index, remove entries for deleted pages
   - Format: `- [[path|Title]] — one-line summary` under the appropriate category heading
6. **Append to log.md** — `## [YYYY-MM-DD] lint | Wiki health check`

---

## About You

Fill in your details so the LLM has context on who it's working for.

- **Name:** {your name}
- **Email:** {your email}
- **Role:** {your role}
- **Team:** {your team}
- **Location:** {your city, timezone}
- **Languages:** {languages you use}
- **Current P0:** {your main project or focus area}

### Key Stakeholders
| Person | Role | Email |
|--------|------|-------|
| | | |

### How I Work

**Thinking framework — always in this order:**
1. **Understand** — what is the problem, context, constraints?
2. **Identify** — what are the options, tradeoffs, risks?
3. **Execute** — what's the action plan?

Don't skip to solutions without understanding first.

### Communication Preferences

Customize these to match how you want the LLM to interact with you:

- Direct and concise
- No fabricated data — never invent statistics or facts
- Challenge my thinking — back it up with evidence
- Move fast and make assumptions when intent is clear

### Output Format
- **Chat messages:** 1-3 paragraphs. No more.
- **Everything else:** Start with TLDR (2-5 bullets) unless trivially short (<200 words).
- Use numbered lists for options. Minimal formatting.
- Substance over style.

---

## Tools Available

List whatever tools are available on THIS device. Updated per device. No hard dependencies — you can always paste content manually and the LLM processes it.

### This Device (update as discovered)

| Tool | Available | Notes |
|------|-----------|-------|
| File system (Read/Write) | Always | Primary tool for all vault I/O |
| Obsidian vault MCP | Optional | write_note, read_note, search_notes — install Obsidian for enhanced experience |
| WorkIQ-Teams MCP | Optional | Teams chats and channels |
| Slack MCP | Optional | Slack messages |

**If a tool is unavailable, skip it and note what was skipped. Never fail because a tool is missing.**
