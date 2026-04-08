#!/bin/bash
set -e

# Resolve vault path: SECOND_BRAIN_PATH env var first, default second
VAULT_DIR="${SECOND_BRAIN_PATH:-$HOME/second-brain}"
SKILL_DIR="$HOME/.claude/skills/second-brain"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/vault-template"

echo "=== Second Brain Setup ==="
echo ""
echo "Vault path: $VAULT_DIR"
echo ""

if [ -d "$VAULT_DIR" ]; then
    echo "Existing vault found at $VAULT_DIR — running migration..."
    echo ""

    # Backfill any new files from template that don't exist in the vault
    backfilled=0
    while IFS= read -r -d '' file; do
        rel_path="${file#$TEMPLATE_DIR/}"
        target="$VAULT_DIR/$rel_path"
        if [ ! -f "$target" ]; then
            mkdir -p "$(dirname "$target")"
            cp "$file" "$target"
            echo "  + Added missing file: $rel_path"
            backfilled=$((backfilled + 1))
        fi
    done < <(find "$TEMPLATE_DIR" -type f -print0)

    if [ "$backfilled" -eq 0 ]; then
        echo "  All template files present — no backfill needed."
    else
        echo "  Backfilled $backfilled file(s)."
    fi
    echo ""
    echo "Note: Existing files were NOT overwritten. To pick up schema changes,"
    echo "compare your CLAUDE.md with vault-template/CLAUDE.md manually."
else
    echo "Creating vault at $VAULT_DIR..."
    cp -r "$TEMPLATE_DIR" "$VAULT_DIR"
fi

# Create raw subdirectories
echo "Creating raw source directories..."
for dir in articles emails meetings chats channels documents books ideas assets projects; do
    mkdir -p "$VAULT_DIR/raw/$dir"
done

# Install skill
echo "Installing skill to $SKILL_DIR..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Vault location: $VAULT_DIR"
echo "Skill location: $SKILL_DIR/SKILL.md"
echo ""
echo "Next steps:"
echo "  1. Edit $VAULT_DIR/CLAUDE.md — fill in the 'About You' section"
echo "  2. Open Claude Code and say: /second-brain ingest this: [paste something]"
echo ""
if [ -n "$SECOND_BRAIN_PATH" ]; then
    echo "Using custom vault path from SECOND_BRAIN_PATH=$SECOND_BRAIN_PATH"
    echo "Make sure this env var is set in every terminal session (add to .bashrc/.zshrc)."
    echo ""
fi
