# Second Brain — LLM Wiki Distribution Pack

A personal knowledge base that compounds over time, powered by Claude Code and the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy.

Instead of re-deriving knowledge from raw documents on every question (like RAG), the LLM incrementally builds and maintains a persistent wiki. Every source you add gets integrated, cross-referenced, and synthesized. The wiki keeps getting richer.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed

## Setup

**Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

This will:
1. Copy the vault template to `~/second-brain/`
2. Install the skill to `~/.claude/skills/second-brain/`
3. Create the raw source subdirectories

## First Use

1. Open Claude Code
2. Say: `/second-brain ingest this: [paste any text, email, article, or meeting notes]`
3. The LLM will create a source page, update wiki pages, and cross-link everything

## Customization

Edit `~/second-brain/CLAUDE.md` — the "About You" section. Fill in your name, role, team, and communication preferences. The LLM reads this at the start of every session.

## Commands

| Say this | What happens |
|----------|-------------|
| `/second-brain ingest this: [content]` | Capture source, update wiki, extract tasks |
| `/second-brain query: what do I know about X?` | Search wiki, synthesize answer |
| `/second-brain lint` | Health check: stale pages, open tasks, broken links |
| `/second-brain weekly summary` | Generate weekly review from recent sources |

## Custom vault path

By default the vault lives at `~/second-brain/`. To use a different location, set the environment variable:

```bash
export SECOND_BRAIN_PATH="/path/to/your/vault"
```

## Optional: Obsidian

The wiki works as plain markdown files. If you install [Obsidian](https://obsidian.md/), open `~/second-brain/` as a vault for graph view, backlinks, and visual navigation. No configuration needed — it just works.

## How It Works

Three operations:
- **Ingest** — capture a source, update wiki pages, extract tasks, cross-link
- **Query** — search the wiki, synthesize answers, file back useful syntheses
- **Lint** — health check: mark done tasks, find stale pages, surface gaps

All conventions and rules live in `CLAUDE.md` inside the vault. The skill file (`SKILL.md`) just points to it. This means the schema travels with the vault — share the vault folder and the rules come with it.
