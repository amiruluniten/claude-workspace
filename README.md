# Agency Workspace — Starter Pack

This is a pre-configured workspace for building client projects with Claude Code.

## Getting Started

1. **Install Claude Code** if you haven't already: https://claude.ai/download
2. **Unzip this folder** somewhere on your computer
3. **Open it in Claude Code** — either drag the folder in or run `claude` from inside it in your terminal
4. **Type this into the chat:**

```
Read the Claude.MD and initialize this project. Install any required dependencies.
```

Claude will handle the rest — setting up your folders, creating your `.env` file for API keys, connecting to GitHub, and making your first commit.

## What's Inside

- **CLAUDE.md** — Instructions that Claude reads automatically. Defines how the workspace is organized and how Claude should behave.
- **hooks/** — Scripts that run automatically to keep your workspace organized and your secrets safe.
- **6 PARA folders** (00-Inbox through 05-Goals) — An organizational system for all your work. Claude will explain how to use them.

## After Setup

- To start a new client project, just tell Claude what you're building
- If you get API keys (OpenAI, Anthropic, etc.), paste them into the chat — Claude will save them to your `.env` file
- Use `/clear` in the chat when switching between different client projects
