# Second Brain — LLM Wiki for Claude Code

A personal knowledge base that compounds over time, powered by Claude Code and the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy.

Instead of re-deriving knowledge from raw documents on every question (like RAG), the LLM incrementally builds and maintains a persistent wiki. Every source you add gets integrated, cross-referenced, and synthesized. The wiki keeps getting richer with every use.

## Why

Most knowledge workflows are lossy. You read a doc, attend a meeting, review a PR — and the insights evaporate. Second Brain fixes this by giving Claude Code a persistent, structured wiki that it maintains for you. You drop in sources; the LLM does all the filing, cross-referencing, and bookkeeping.

After a few weeks, you can ask "what did the team deliver last sprint?" or "what's blocking the DoCA convergence?" and get answers grounded in everything you've ingested — not hallucinated, not re-derived from scratch.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed and working
- No Obsidian required (optional enhancement)

## Setup (2 minutes)

**Step 1: Clone this repo**
```bash
git clone https://github.com/agentictaskx/second-brain-pack.git
cd second-brain-pack
```

**Step 2: Run setup**

Mac/Linux:
```bash
chmod +x setup.sh
./setup.sh
```

Windows (PowerShell):
```powershell
.\setup.ps1
```

This creates:
- `~/second-brain/` — your wiki vault (all markdown files)
- `~/.claude/skills/second-brain/SKILL.md` — the Claude Code skill

**Step 3: Personalize**

Edit `~/second-brain/CLAUDE.md` and fill in the "About You" section with your name, role, team, and preferences. This is how the LLM knows who it's working for.

## Usage

Open Claude Code anywhere and use `/second-brain` followed by what you want to do:

### Ingest — capture and file information

```
/second-brain ingest this: [paste email, meeting notes, article, Slack thread, etc.]
```

The LLM will:
1. Save the source in `raw/` (immutable record)
2. Update wiki pages — people go to `people.md`, links go to `bookmarks.md`, project updates go to `projects/`, etc.
3. Extract action items into `todo.md`
4. Cross-link everything
5. Update the index and log

### Query — search and synthesize

```
/second-brain what do I know about [topic]?
/second-brain what's Tao's email?
/second-brain what am I waiting on?
/second-brain weekly summary
```

The LLM reads the index, finds relevant pages, and synthesizes an answer. Good syntheses get filed back as wiki pages (weekly reviews, analyses).

### Lint — health check

```
/second-brain lint
```

Finds stale pages, marks completed tasks, flags overdue items, identifies broken links, and surfaces recurring themes.

## What's in the vault

```
~/second-brain/
├── CLAUDE.md           # Schema — all rules and conventions (edit this!)
├── index.md            # Wiki catalog (LLM reads this first)
├── log.md              # Event log (append-only)
├── raw/                # Immutable sources
│   ├── articles/       # Ingested articles
│   ├── emails/         # Ingested emails
│   ├── meetings/       # Meeting notes
│   ├── channels/       # Channel digests
│   └── ...             # chats, documents, books, ideas, assets
└── wiki/               # LLM-maintained knowledge
    ├── people.md        # People directory
    ├── bookmarks.md     # Curated links
    ├── todo.md          # Tasks and follow-ups
    ├── top-of-mind.md   # Current priorities
    ├── decisions.md     # Decision log
    ├── concepts.md      # Ideas and frameworks
    ├── channels.md      # Communication channels
    ├── tools.md         # Tools and services
    ├── projects/        # One page per project
    ├── reviews/         # Weekly/monthly reviews
    └── overviews/       # Syntheses and analyses
```

## Key principle: information goes where you'd look for it

Every piece of information has a natural home:

| Information type | Goes to |
|-----------------|---------|
| Person mentioned | `wiki/people.md` |
| URL or reference | `wiki/bookmarks.md` |
| Project update | `wiki/projects/{name}.md` |
| Action item | `wiki/todo.md` |
| Decision made | `wiki/decisions.md` |
| New concept | `wiki/concepts.md` |
| Channel/chat | `wiki/channels.md` |

The LLM routes automatically based on the entity routing table in `CLAUDE.md`.

## Custom vault path

By default the vault lives at `~/second-brain/`. To use a different location:

```bash
# Set before running setup
export SECOND_BRAIN_PATH="/path/to/your/vault"
./setup.sh
```

Setup persists the vault path to `~/.claude/second-brain.json`, so it works in every future session without needing the env var. To change the path later, re-run setup with the new `SECOND_BRAIN_PATH` or edit the JSON file directly.

## Optional: Obsidian

The wiki is plain markdown. If you install [Obsidian](https://obsidian.md/) and open `~/second-brain/` as a vault, you get graph view, backlinks, and visual navigation for free. No configuration needed.

If you have Obsidian's MCP server, the skill will use it for faster reads/writes. Otherwise it falls back to Claude Code's native file system tools.

## How it works under the hood

The skill file (`SKILL.md`) is tiny — it just locates the vault and reads `CLAUDE.md`. All the real logic lives in `CLAUDE.md`:

- **Architecture:** Three layers — raw sources (immutable), wiki (LLM-maintained), schema (co-evolved)
- **Ingest:** 8-step workflow from reading source → filing → cross-linking → indexing
- **Query:** Index-first lookup → drill into pages → synthesize → file back useful answers
- **Lint:** Todo accountability, wiki health, gap analysis, index maintenance
- **Usage logging:** Every invocation is logged in `wiki/usage-log.md` for skill optimization

The schema travels with the vault. Share the folder and the rules come with it.

## Adapting for your team

`CLAUDE.md` is designed to be co-evolved with the LLM. As you use it, tell the LLM to update the schema:

- "Add a new entity type for design docs"
- "Change the output format to be more concise"
- "Add a new section for OKR tracking"

The LLM will update `CLAUDE.md` and follow the new rules going forward.

## Credits

Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).
