---
description: Clean all Frends development artifacts while preserving directory structure
allowed-tools: Bash
---

Clean the Frends workspace by removing development artifacts while preserving `.gitkeep` files and directory structure.

## What to Clean

- `active-development/processes/` - pulled Process exports
- `active-development/feedback/` - test/run output
- `.frends-token-cache` - cached bearer token

## What to Preserve

- `.env`, `.env.local`, `preferred_connections.md`, and any custom files the user added.
- Directory structure and `.gitkeep` files.

## How to Execute

Run from the project root:

```bash
# Remove all files except .gitkeep under active-development
find active-development -type f ! -name ".gitkeep" -delete 2>/dev/null || true
# Drop the cached token (a fresh one is fetched on next API call)
rm -f .frends-token-cache 2>/dev/null || true
```

Report what was cleaned and confirm the directory structure is preserved.
