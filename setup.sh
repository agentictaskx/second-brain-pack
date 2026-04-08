#!/bin/bash
set -e

VAULT_DIR="$HOME/second-brain"
SKILL_DIR="$HOME/.claude/skills/second-brain"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Second Brain Setup ==="
echo ""

# Create vault from template
if [ -d "$VAULT_DIR" ]; then
    echo "Vault already exists at $VAULT_DIR — skipping copy to avoid overwriting."
    echo "To start fresh, delete $VAULT_DIR and re-run this script."
else
    echo "Creating vault at $VAULT_DIR..."
    cp -r "$SCRIPT_DIR/vault-template" "$VAULT_DIR"
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
echo "Next steps:"
echo "  1. Edit $VAULT_DIR/CLAUDE.md — fill in the 'About You' section"
echo "  2. Open Claude Code and say: /second-brain ingest this: [paste something]"
echo ""
