# Trello MCP Server

A [Model Context Protocol](https://modelcontextprotocol.io) (MCP) server that connects [Trello](https://trello.com) to Claude Code. Manage your boards, lists, cards, checklists, and more — all through natural language.

> **74 tools** | **Zero config startup** | **Auto-loads `.env`** | **Docker ready** | **Remote HTTP support**

---

## Prerequisites

- [Node.js 22+](https://nodejs.org/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A Trello account
- [Docker](https://www.docker.com/) (only needed for remote/Docker mode)

---

## Option A: Local Setup (Stdio Mode)

Best for personal use on your own machine. Claude Code launches the server automatically — no Docker needed.

### Step 1: Clone and install

```bash
git clone https://github.com/GabrielRamirez/trello-mcp.git
cd trello-mcp
npm install
```

### Step 2: Get your Trello credentials

Run the interactive setup wizard:

```bash
npm run setup
```

It will:
1. Ask for your API key — get one at [trello.com/power-ups/admin](https://trello.com/power-ups/admin)
2. Open your browser to authorize the app
3. You click **Allow**, copy the token, and paste it back
4. Save both values to a `.env` file automatically

> The `.env` file is git-ignored. Your credentials stay local.

### Step 3: Register the server with Claude Code

```bash
claude mcp add trello -- npx tsx src/index.ts
```

### Step 4: Verify it works

Open Claude Code and ask:

```
List my Trello boards
```

You should see your boards listed. The 73 Trello tools are now available in every Claude Code conversation.

---

## Option B: Docker Setup (Remote HTTP Mode)

Best for running on a server, sharing with a team, or keeping the server always-on. The server exposes an HTTP endpoint that Claude Code connects to via URL.

### Step 1: Clone the repo

```bash
git clone https://github.com/GabrielRamirez/trello-mcp.git
cd trello-mcp
```

### Step 2: Configure credentials

```bash
cp .env.example .env
```

Open `.env` in your editor and fill in your values:

```env
TRELLO_API_KEY=your-api-key-here
TRELLO_TOKEN=your-token-here
```

Need credentials? Get your API key at [trello.com/power-ups/admin](https://trello.com/power-ups/admin), then click the token link on that page to authorize.

### Step 3: Build and start the server

```bash
docker compose up --build
```

You should see:

```
trello-mcp-1  | Trello MCP server listening on http://0.0.0.0:3333/mcp
```

> The server will refuse to start if credentials are missing, with a clear error telling you what's needed.

### Step 4: Verify the server is running

In a new terminal:

```bash
curl http://localhost:3333/health
```

Expected response:

```json
{"status":"ok"}
```

### Step 5: Connect Claude Code to the server

```bash
claude mcp add --transport http trello http://localhost:3333/mcp
```

If the server is running on a remote machine, replace `localhost` with the server's hostname or IP:

```bash
claude mcp add --transport http trello http://your-server:3333/mcp
```

### Step 6: Verify it works

Open Claude Code and ask:

```
List my Trello boards
```

---

## Option C: Using the Published Docker Image

The image is published on [Docker Hub](https://hub.docker.com/r/gabermz/trello-mcp). No cloning or Node.js required.

### Step 1: Run the container

```bash
docker run -d -p 3333:3333 \
  -e TRELLO_API_KEY=your_key \
  -e TRELLO_TOKEN=your_token \
  --name trello-mcp \
  gabermz/trello-mcp
```

### Step 2: Connect Claude Code

```bash
claude mcp add --transport http trello http://localhost:3333/mcp
```

That's it — no Node.js, no cloning, no `npm install`.

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TRELLO_API_KEY` | Yes | — | Your Trello API key ([get one here](https://trello.com/power-ups/admin)) |
| `TRELLO_TOKEN` | Yes | — | Your Trello authorization token |
| `PORT` | No | `3333` | HTTP server port (Docker/remote mode only) |

---

## Sharing with Your Team

### Option 1: Project-scoped config

Register the server for everyone working in a specific project:

```bash
claude mcp add --transport http trello --scope project http://localhost:3333/mcp
```

This saves the config to `.mcp.json` in the project root, which you can commit to git.

### Option 2: Manual `.mcp.json` with environment variable support

Create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "trello": {
      "type": "http",
      "url": "${TRELLO_MCP_URL:-http://localhost:3333}/mcp"
    }
  }
}
```

Each teammate can set `TRELLO_MCP_URL` to point to their own server, or omit it to use the default `localhost:3333`.

---

## What Can It Do?

Once connected, just ask Claude in natural language:

| You say | What happens |
|---------|--------------|
| *"List my Trello boards"* | Fetches all your boards |
| *"Show me the cards in my Sprint board"* | Gets all cards on that board |
| *"Create a card called Fix login bug in the To Do list"* | Creates a new card |
| *"Move that card to In Progress"* | Moves a card between lists |
| *"Add a checklist called QA Steps to that card"* | Creates a checklist |
| *"Search for cards about authentication"* | Searches across all boards |
| *"Add a comment: Blocked by API rate limit"* | Comments on a card |
| *"Archive all done cards"* | Archives completed cards |

---

## Tools Reference

### Boards (14 tools)

| Tool | Description |
|------|-------------|
| `list_boards` | List all boards for the authenticated user |
| `get_board` | Get board details by ID |
| `get_board_lists` | Get all lists on a board |
| `get_board_cards` | Get all cards on a board |
| `get_board_labels` | Get all labels on a board |
| `get_board_members` | Get all members of a board |
| `get_board_actions` | Get the activity feed for a board |
| `get_board_custom_fields` | Get custom field definitions on a board |
| `create_board` | Create a new board |
| `update_board` | Update name, description, closed status, or background |
| `delete_board` | Permanently delete a board (irreversible) |
| `create_label` | Create a new label on a board |
| `add_board_member` | Add a member to a board with a role |
| `remove_board_member` | Remove a member from a board |

### Cards (21 tools)

| Tool | Description |
|------|-------------|
| `get_card` | Get card details with checklists, labels, and members |
| `create_card` | Create a new card on a list |
| `update_card` | Update card name, description, due date, or position |
| `move_card` | Move a card to a different list or board |
| `archive_card` | Archive a card (reversible) |
| `unarchive_card` | Unarchive (reopen) a closed card |
| `delete_card` | Permanently delete a card (irreversible) |
| `add_comment` | Add a comment to a card |
| `update_comment` | Edit a comment on a card |
| `delete_comment` | Delete a comment from a card |
| `add_label_to_card` | Add a label to a card |
| `remove_label_from_card` | Remove a label from a card |
| `add_member_to_card` | Assign a member to a card |
| `remove_member_from_card` | Unassign a member from a card |
| `get_card_actions` | Get the activity feed for a card |
| `list_attachments` | List all attachments on a card |
| `get_attachment` | Download an image attachment and return it as image content |
| `add_attachment` | Add a URL attachment to a card |
| `delete_attachment` | Delete an attachment from a card |
| `get_card_custom_fields` | Get custom field values for a card |
| `update_custom_field_item` | Set a custom field value on a card |

### Lists (8 tools)

| Tool | Description |
|------|-------------|
| `get_list` | Get a list and all its cards |
| `create_list` | Create a new list on a board |
| `update_list` | Rename or reposition a list |
| `archive_list` | Archive a list |
| `unarchive_list` | Unarchive (reopen) a closed list |
| `move_all_cards` | Move all cards from one list to another |
| `archive_all_cards` | Archive all cards in a list |
| `move_list_to_board` | Move a list to a different board |

### Checklists (7 tools)

| Tool | Description |
|------|-------------|
| `create_checklist` | Create a checklist on a card |
| `get_checklist` | Get a checklist by ID with all its items |
| `update_checklist` | Rename or reposition a checklist |
| `delete_checklist` | Permanently delete a checklist |
| `add_checklist_item` | Add an item to a checklist |
| `update_checklist_item` | Toggle, rename, or reposition a checklist item |
| `delete_checklist_item` | Delete an item from a checklist |

### Labels (3 tools)

| Tool | Description |
|------|-------------|
| `get_label` | Get a label by ID |
| `update_label` | Update a label's name or color |
| `delete_label` | Permanently delete a label |

### Members (7 tools)

| Tool | Description |
|------|-------------|
| `get_member` | Get member info by ID or username |
| `get_member_cards` | Get all cards assigned to a member |
| `get_member_boards` | Get all boards a member belongs to |
| `get_member_organizations` | Get all workspaces a member belongs to |
| `get_notifications` | Get notifications for the authenticated user |
| `mark_all_notifications_read` | Mark all notifications as read |
| `search_members` | Search for members by name, username, or email |

### Custom Fields (4 tools)

| Tool | Description |
|------|-------------|
| `create_custom_field` | Create a custom field definition on a board |
| `get_custom_field` | Get a custom field definition by ID |
| `delete_custom_field` | Delete a custom field definition |
| `get_custom_field_options` | Get dropdown options for a list-type custom field |

### Organizations (5 tools)

| Tool | Description |
|------|-------------|
| `get_organization` | Get workspace details by ID or name |
| `get_organization_members` | Get all members of a workspace |
| `get_organization_boards` | Get all boards in a workspace |
| `create_organization` | Create a new workspace |
| `update_organization` | Update workspace name, description, or website |

### Webhooks (4 tools)

| Tool | Description |
|------|-------------|
| `create_webhook` | Create a webhook for model change notifications |
| `get_webhook` | Get webhook details by ID |
| `update_webhook` | Update a webhook's URL, model, or active status |
| `delete_webhook` | Delete a webhook |

### Search (1 tool)

| Tool | Description |
|------|-------------|
| `search` | Search boards and cards with [Trello search operators](https://support.atlassian.com/trello/docs/searching-for-cards-all-boards/) (`@member`, `#label`, `list:name`, `is:open`, etc.) |

> Tools that require Trello Premium or Enterprise (Custom Fields, some board features) will return a clear error message if your account doesn't have access.

---

## Project Structure

```
trello-mcp/
├── src/
│   ├── index.ts              # Stdio entry point (local mode)
│   ├── remote.ts             # HTTP entry point (Docker/remote mode)
│   ├── server.ts             # Shared server factory
│   ├── trello-client.ts      # HTTP client with auth and error handling
│   ├── types.ts              # TypeScript interfaces for Trello objects
│   ├── tools/
│   │   ├── boards.ts         # Board tools (14)
│   │   ├── cards.ts          # Card tools (20)
│   │   ├── lists.ts          # List tools (8)
│   │   ├── checklists.ts     # Checklist tools (7)
│   │   ├── labels.ts         # Label tools (3)
│   │   ├── members.ts        # Member tools (7)
│   │   ├── customfields.ts   # Custom Field tools (4)
│   │   ├── organizations.ts  # Organization tools (5)
│   │   ├── webhooks.ts       # Webhook tools (4)
│   │   └── search.ts         # Search tool (1)
│   └── utils/
│       ├── env.ts            # .env file loader
│       └── response.ts       # Response formatting helpers
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── package.json
├── tsconfig.json
└── tsup.config.ts
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **"Missing required environment variables"** | Copy `.env.example` to `.env` and fill in your credentials, or pass them via `-e` flags. |
| **"Trello API credentials are not configured"** | Run `npm run setup` to configure credentials interactively. |
| **401 Unauthorized** | Your API key or token is invalid. Run `npm run setup` to generate new ones. |
| **Server starts but no tools appear** | Make sure you used `claude mcp add`, not just `npx tsx src/index.ts` directly. |
| **"Cannot find module" errors** | Run `npm install` to install dependencies. |
| **Docker health check failing** | Ensure port 3333 isn't already in use. Check logs with `docker compose logs`. |
| **Can't connect to remote server** | Check firewall rules allow port 3333. Verify with `curl http://your-server:3333/health`. |

---

## Development

```bash
# Install dependencies
npm install

# Run in dev mode (stdio, auto-loads .env)
npm run dev

# Build for production
npm run build

# Run HTTP server locally without Docker
npm run start:remote

# Run production build (stdio)
npm run start
```

---

## License

[MIT](LICENSE)
