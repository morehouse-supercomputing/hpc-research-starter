# Skills

Reusable `SKILL.md` instructions Claude understands, one folder per skill.

| Skill | Use it to |
|---|---|
| `sage` | Meet Sage, your guide, and be walked through filling in your templates — start here |
| `tacc-vista` | Write and debug Slurm job scripts for the Vista supercomputer (queues, GPU/CPU templates, common pitfalls) |

A `SKILL.md` is a markdown file with a short YAML header (`name`, `description`) followed by step-by-step instructions. Add more as `skills/<name>/SKILL.md`.

## How to use a skill (any tool)

- **Claude Code / Cursor:** open the repo and say "use the &lt;name&gt; skill," or just describe the task. The AI reads the matching `SKILL.md`; `CLAUDE.md` points it here.
- **VS Code + Copilot:** open the relevant `skills/<name>/SKILL.md` and reference it in your prompt.
- **Claude on the web:** upload or paste the `SKILL.md` (plus your filled-in template) into the chat.
