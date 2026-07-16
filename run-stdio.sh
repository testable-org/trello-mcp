#!/usr/bin/env bash
# Launcher for user-scoped stdio MCP registration: ensures cwd is the repo
# root so src/index.ts and .env resolve regardless of where Claude Code runs.
cd "$(dirname "$(readlink -f "$0")")" || exit 1

# Claude Code spawns this non-interactively, so nvm isn't loaded and PATH may
# hold an older system node. Source nvm and pin Node 24 explicitly. stdout is
# the MCP protocol channel — nvm's chatter must go to /dev/null.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh" --no-use
  nvm use 24 >/dev/null 2>&1 || { echo "trello-mcp: Node 24 not installed in nvm" >&2; exit 1; }
fi

node_major=$(node --version | sed 's/^v//' | cut -d. -f1)
if [ "$node_major" -lt 22 ]; then
  echo "trello-mcp: Node >=22 required, found $(node --version)" >&2
  exit 1
fi

exec npx tsx src/index.ts
