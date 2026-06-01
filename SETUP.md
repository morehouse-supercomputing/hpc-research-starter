# Setup: get the repo, keep it updated, and meet Sage

Three steps to get going, plus how to keep your copy up to date all week. However you do it, the whole folder ends up on your machine.

> **Windows or Mac?** The git commands below are the **same on both**. The only difference is the terminal you open:
> - **Mac:** the built-in **Terminal** app.
> - **Windows:** use **Git Bash** (it installs with Git) so every command here works exactly like it does on a Mac. If you use PowerShell or Command Prompt instead, the `git` commands still work, but a few navigation commands differ (for example, listing files is `ls` in Git Bash and Mac, and `dir` in PowerShell or Command Prompt).

---

## Step 1: Make your own copy

This keeps your work in your own account.

1. On this repo's GitHub page, click **Use this template → Create a new repository** (or **Fork** if you do not see that button).
2. Optional, if you want help during the workshop: your repo → **Settings → Collaborators → add `ashleyscruse`**. Your work stays yours; this just lets me look when you are stuck.

## Step 2: Get it onto your computer

Pick whichever you are comfortable with. All give you the full folder.

### Option A: Download ZIP (graphical, no git)

1. Green **Code** button → **Download ZIP**.
2. Unzip it. Done.

A ZIP is a one-time snapshot. To get later updates you would re-download. If you want to pull updates easily, use Option B or C instead.

### Option B: GitHub Desktop (graphical, can update)

1. Green **Code** button → **Open with GitHub Desktop → Clone**.
2. To update later: open GitHub Desktop and click **Pull origin** (or **Fetch origin**).

### Option C: Command line (git)

First, let GitHub know it is you. You only do this once, and it is the same on Windows and Mac:

1. Install the GitHub CLI (`gh`).
2. Run:
   ```
   gh auth login
   ```
3. Choose **GitHub.com → HTTPS → "Login with a web browser"**, and follow the prompts.

That stores your login so clone, push, and pull just work. (Alternatives: set up an SSH key, or use a Personal Access Token as your password when git asks.)

Then copy your repo onto your computer:
```
git clone https://github.com/YOUR-USERNAME/hpc-research-starter.git
cd hpc-research-starter
```

## Step 3: Open it in your tool and meet Sage

The **universal move** in any tool: open the folder, then tell the AI:

> "Read CLAUDE.md and skills/sage/SKILL.md, then be Sage and guide me."

| Tool | How to open the folder | How to start Sage |
|---|---|---|
| **Claude Code** (the CLI "coworker") | `cd` into the folder, run `claude` | Just say **hi**. It reads `CLAUDE.md` automatically and Sage introduces the process. |
| **Cursor** | File → Open Folder → your repo | Open chat (Cmd/Ctrl + L), paste the universal line |
| **VS Code + Copilot** | File → Open Folder → your repo | Open Copilot Chat, paste the universal line |
| **Antigravity** | Open the project folder | In the agent panel, paste the universal line |
| **Claude desktop app** | Create/open a Project, add this folder | Paste the universal line |
| **Claude on the web** (claude.ai) | No folder to mount here. **Upload** `CLAUDE.md`, `skills/sage/SKILL.md`, and the template you are filling (start with `templates/research-brief.md`) into a Project or chat | Paste the universal line |

> **Claude Code** is the only one that reads `CLAUDE.md` on its own, so "hi" is enough. Everywhere else, the universal line points the AI at Sage. For **Claude on the web**, keep the downloaded folder on your computer so you can upload files in and save your work back out.

---

## Keep your copy up to date

Your project lives in two places: **GitHub** (online) and **your computer** (offline). Git keeps them in sync. Think in two directions.

**You changed files on your computer, send them up:**
```
git status                       # see what changed
git add .                        # stage all your changes
git commit -m "what I changed"   # save them with a note
git push                         # send them to GitHub
```

**Files changed on the GitHub website, bring them down:**
```
git pull                         # update your computer with the latest from GitHub
```

> **Important when you fill in templates on the website.** If you edit a template in the GitHub web interface and click **Commit changes**, those edits are saved on GitHub but **not yet on your laptop**. To use them offline and let your AI tools read them, run `git pull` on your computer. So the flow is: edit on the website → **Commit changes** on the website → `git pull` on your computer.

### The handful of commands you will actually use

| Command | What it does |
|---|---|
| `git status` | Show what has changed |
| `git add .` | Stage all your changes |
| `git commit -m "..."` | Save staged changes with a message |
| `git push` | Send your commits up to GitHub |
| `git pull` | Bring GitHub's latest down to your computer |
| `git clone <url>` | Copy a repo onto your computer (first time only) |

These are identical on Windows (Git Bash) and Mac.

### Getting updates I add during the workshop

If I add shared materials to the starter during the week, connect to it once:
```
git remote add upstream https://github.com/ashleyscruse/hpc-research-starter.git
```
Then any time you want the latest:
```
git pull upstream main
```

---

## What happens next

Sage gets your workspace set up and walks you through your **research brief** first, then your **methodology**. Those filled-in templates become the AI's knowledge base for the rest of the week; code, analysis, and writing all read from them.
