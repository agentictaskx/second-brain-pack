---
name: second-brain
description: "Personal knowledge base using the LLM Wiki pattern (Karpathy). Activates on explicit /second-brain invocation. Supports: 'ingest', 'query', 'lint', 'health check', 'weekly summary', 'monthly report'."
---

# Second Brain — LLM Wiki

Personal knowledge base following [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Setup

At session start, locate and read the schema:

**Vault path discovery (in order):**
1. Config file `~/.claude/second-brain.json` → read `vault_path` key
2. Environment variable `SECOND_BRAIN_PATH` if set
3. Default: `~/second-brain/`

Read `CLAUDE.md` from the vault root — this is the schema with all conventions, workflows, and protocols. Follow its instructions exactly.

## Operations

The schema defines three operations:

- **Ingest** — capture a source into `raw/`, update wiki pages, update index, log it
- **Query** — read index, find relevant pages, synthesize answer, file back good answers as wiki pages
- **Lint** — health check the wiki, mark done items, flag undone items, find gaps

## Activation Rules

This skill activates ONLY on explicit `/second-brain` invocation. Generic phrases like "look up", "todo", or "weekly summary" in normal conversation should NOT trigger this skill — only when prefixed with `/second-brain`.

Mutating operations (ingest, lint) require explicit invocation. Read-only queries may activate on `/second-brain query` or `/second-brain what do I know about`.

## Tools

Use whatever tools are available on this device. Check `CLAUDE.md` § Tools Available.

**Primary:** Claude Code's native Read/Write/Edit tools work with any local folder.
**Optional enhancement:** Obsidian vault MCP if the user has Obsidian installed.

If no specialized tools are available, the user pastes content and the LLM processes it with file system Read/Write.

## That's It

The schema (`CLAUDE.md`) in the vault is the single source of truth. It travels with the vault across devices.
This skill file just points to it.
