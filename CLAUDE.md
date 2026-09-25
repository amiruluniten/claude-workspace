# Agency Workspace — CLAUDE.md

## First-Time Setup

On the first session in this workspace, check if the system is ready:

1. Check if `jq` is installed by running `which jq`. If missing, install it:
   - macOS: `brew install jq`
   - Linux (Debian/Ubuntu): `sudo apt-get install -y jq`
   - Linux (other): `sudo yum install -y jq` or equivalent
2. Check if the hook scripts are executable by running `ls -l hooks/`. If they show `-rw-` instead of `-rwx-`, run `chmod +x hooks/*.sh`.
3. Check that the 6 PARA folders exist (00-Inbox, 01-Projects, 02-Areas, 03-Resources, 04-Archives, 05-Goals). If any are missing, create them with `mkdir -p 00-Inbox 01-Projects 02-Areas 03-Resources 04-Archives 05-Goals`.
4. Create a `.env` file at the workspace root if one does not already exist. Pre-populate it with common placeholder keys so the user can fill them in:
   ```
   # API Keys — paste your real keys here to replace the placeholders
   OPENAI_API_KEY=your-openai-key-here
   ANTHROPIC_API_KEY=your-anthropic-key-here
   GOOGLE_API_KEY=your-google-key-here
   ```
   After creating it, tell the user: "I created a `.env` file at the workspace root. Paste your API keys there whenever you have them — I'll use that file to reference your keys for any project that needs them."
5. Create a `.gitignore` at the workspace root if one does not already exist. It should include at minimum:
   ```
   .env
   .env.local
   .env.production
   .DS_Store
   node_modules/
   ```

6. Git and GitHub setup:
   a. Check if `gh` (GitHub CLI) is installed by running `which gh`. If missing, install it:
      - macOS: `brew install gh`
      - Linux: Follow instructions at https://github.com/cli/cli/blob/trunk/docs/install_linux.md
   b. Check if the user is authenticated with GitHub by running `gh auth status`.
      - If NOT authenticated: Run `gh auth login --web -p https` and walk the user through the browser-based login flow. Wait for them to confirm it completed before continuing.
   c. Check if git is initialized by running `git rev-parse --is-inside-work-tree`. If not, run `git init`.
   d. Stage all files and create an initial commit: `git add -A && git commit -m "Initial workspace setup"`.
   e. Create a private GitHub repo using the current folder name and push:
      - Get the folder name with `basename "$PWD"` and convert it to kebab-case (lowercase, spaces to hyphens).
      - Run `gh repo create <repo-name> --private --source=. --remote=origin --push`.
   f. Confirm success by running `git remote -v` and tell the user: "Your workspace is now backed up to GitHub at <repo-url>. All your work will be version-controlled from here."

Only run these checks once. After setup is confirmed, skip this section in future sessions.

## Folder Structure (Modified PARA Method)

This workspace uses a 6-folder PARA system. All work lives inside these folders. System files (.git, .gitignore, .claude, hooks) stay at the root.

- `00-Inbox/` — Quick capture. Unsorted files, new client assets, anything not yet processed. Process regularly into the correct folder.
- `01-Projects/` — Active client work with a deadline or deliverable. Organized by client, then by project (e.g., `01-Projects/acme/landing-page/`). Each client folder contains a `CLIENT.md` with client-wide context.
- `02-Areas/` — Ongoing responsibilities with no end date. Examples: internal tools, SOPs, recurring retainer work, agency operations.
- `03-Resources/` — Reference material, code snippets, tutorials, design systems, boilerplate templates, reusable components.
- `04-Archives/` — Completed or inactive projects. Move finished client work here. Never delete — archive.
- `05-Goals/` — Strategic planning. Annual goals, quarterly roadmaps, sprint plans, weekly plans, daily logs.

### Sorting rules

- New files with no clear home go in `00-Inbox/`.
- A project is "active" if it has upcoming deliverables. Otherwise it belongs in `04-Archives/`.
- Reusable code, templates, or references that aren't tied to one client go in `03-Resources/`.
- When a single project is completed, move it to `04-Archives/` under a client subfolder with a date prefix (e.g., `04-Archives/acme/2026-03-landing-page/`).
- When an entire client relationship ends, move the whole client folder to `04-Archives/` with a date prefix (e.g., `04-Archives/2026-03-acme/`).

## Client Context Management

### Client and project structure

Each client gets their own folder under `01-Projects/`. Inside that folder, a `CLIENT.md` holds client-wide context (brand guidelines, tone, contacts, preferred tech stack, credentials references). Individual projects live as subfolders under the client.

```
01-Projects/
├── acme/
│   ├── CLIENT.md              # Client-wide context: brand, tone, contacts, preferences
│   ├── .env                   # Client-specific API keys (git-ignored)
│   ├── landing-page/
│   │   ├── README.md          # Project scope, deadlines, deliverables
│   │   ├── CLAUDE.md          # Project-specific conventions (optional)
│   │   ├── .env.example       # Template for required env vars
│   │   ├── src/
│   │   └── ...
│   └── email-campaign/
│       ├── README.md
│       └── src/
├── globex/
│   ├── CLIENT.md
│   ├── website-redesign/
│   │   ├── README.md
│   │   └── src/
│   └── ...
```

### CLIENT.md contents

Every client folder must have a `CLIENT.md`. Include:
- **Company name** and primary contact(s)
- **Brand voice and tone** guidelines
- **Preferred tech stack** and frameworks
- **Deployment targets** (hosting, CI/CD, domains)
- **Access notes** (where credentials are stored — never the credentials themselves)
- **Ongoing retainer details** if applicable

### Switching between clients

When switching context between client projects, use `/clear` to reset the context window. Long sessions mixing multiple clients degrade output quality. Treat each client as a separate session.

When resuming work on a client project, start by reading that client's `CLIENT.md` and the project's `README.md` to reload context.

### Project-specific instructions

If a project has unique conventions (naming, frameworks, deployment targets), add a `CLAUDE.md` inside that project's subfolder. It will be loaded automatically when working in that directory.

## API Keys and Secrets

IMPORTANT: Never commit secrets to git. Never write API keys, tokens, passwords, or credentials into any tracked file.

### Storage

- When a user provides an API key or secret in the chat, **immediately write it to a `.env` file** in the relevant project folder (or the workspace root if no project is active). This ensures keys are saved for later use.
- Use `.env` files for all secrets. Every project should have a `.env` in `.gitignore`.
- Provide a `.env.example` with placeholder values (no real keys) so collaborators know which variables are needed.
- For shared team secrets, use a secrets manager (1Password, Doppler, AWS Secrets Manager) — not files in this repo.

### Writing secrets

- Always write API keys and secrets to `.env` files — never into source code files. The `protect-secrets.sh` hook enforces this: it allows writes to `.env` files but blocks secrets from being written anywhere else.
- In code, always read secrets from environment variables (`process.env.API_KEY`, `os.environ["API_KEY"]`, etc.).
- Never hardcode secrets as string literals in source files.
- Never log secret values, even in debug mode.

### Checking for leaks

Before any commit, verify no secrets are staged:
- Search staged files for patterns like `sk-`, `API_KEY=`, `SECRET`, `TOKEN=`, `password`.
- If a secret is found in a staged file, unstage it immediately and move the value to `.env`.

## Workflow Best Practices

### Starting a new client project

1. If the client doesn't have a folder yet, create one in `01-Projects/` (e.g., `01-Projects/acme/`) and add a `CLIENT.md` with client-wide context.
2. Create a project subfolder under the client (e.g., `01-Projects/acme/landing-page/`).
3. Add a `README.md` with: project scope, deadline, tech stack, deployment target, key contacts.
4. Add `.env.example` listing required environment variables.
5. Add `.gitignore` covering `.env`, `node_modules/`, build artifacts.
6. If the project has unique code conventions, add a `CLAUDE.md` in the project root.

### Daily workflow

1. Process `00-Inbox/` — sort new files into the right folders.
2. Check `05-Goals/` for the current weekly plan and daily priorities.
3. Work on `01-Projects/` tasks in priority order.
4. At end of day, log what was completed in `05-Goals/` (daily log).

### Completing a project

1. Confirm all deliverables are shipped.
2. Remove any local `.env` files or sensitive data.
3. Move the project subfolder to `04-Archives/client-name/` with a date prefix (e.g., `04-Archives/acme/2026-03-landing-page/`). If the client still has other active projects, leave the client folder in `01-Projects/`.
4. Update `05-Goals/` to reflect completion.

### Code quality

- Run linters and formatters before committing.
- Write tests for any non-trivial logic.
- Prefer small, focused commits with descriptive messages.
- Use branches for features; merge via pull request.

### Context management

- Use `/clear` between unrelated tasks or client switches.
- Keep sessions focused on one project at a time.
- For research or exploration, use subagents to avoid polluting the main context.

## Git Conventions

- Branch naming: `client/project-name/feature-description` (e.g., `acme/landing-page/add-hero-section`).
- Commit messages: imperative tense, concise, focused on "why" not "what" (e.g., "Add hero section with CTA for launch campaign").
- Never force-push to main.
- Never commit `.env`, credentials, or build artifacts.

## File Naming

- Use kebab-case for folders and files (e.g., `acme-landing-page`, `hero-section.html`).
- Prefix archived projects with the completion date (e.g., `2026-03-landing-page` inside `04-Archives/acme/`).

## Hooks

This workspace has hooks installed at `hooks/` that enforce the PARA system:

- `protect-secrets.sh` — Funnels secrets into `.env` files. Allows writing to `.env` but blocks secrets from being written into source code.
- `enforce-para.sh` — Prevents creating files outside the 6 PARA folders.
- `load-para-context.sh` — Loads a workspace snapshot into context at session start.
- `log-file-creation.sh` — Audit trail of every file created, logged to `.claude/file-audit.log`.
- `inbox-reminder.sh` — Reminds you when 00-Inbox has 5+ unsorted items.

Hook config lives in `.claude/settings.json`. Scripts require `jq` (see First-Time Setup above).
