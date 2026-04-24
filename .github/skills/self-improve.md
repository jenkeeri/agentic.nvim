# Skill: Self-Improvement Protocol

Load this skill **after every completed task** — without exception.

## The threshold question

Before adding anything, ask: "Would a fresh Copilot session starting this project
benefit from knowing this?"

- Yes → add it
- Uncertain → skip it

## When to improve

Add a new entry if you discovered during this task:

- A pattern or convention not yet documented
- A command or tool that works better than what's documented
- A gotcha in the mini.test / LuaCATS / Neovim API that caused confusion
- A correction to something existing that was wrong or misleading
- A new edge case in the multi-tabpage architecture
- A discovery about the plugin's UI rendering or buffer management

## When NOT to improve

Skip if:

- The discovery is task-specific and won't recur
- You're uncertain — omit rather than guess
- It repeats what's already documented
- It's a user preference expressed once but not confirmed as standing policy

## How to improve

**Rule: add-only. Never delete or rewrite existing entries.**

If an existing instruction is wrong, annotate it:

```markdown
> **Update (reason):** prefer `X` over `Y` because Z.
```

### What to update

| Discovery | Target file |
|-----------|-------------|
| New Lua pattern or convention | `copilot-instructions.md` → relevant section |
| Testing gotcha (mini.test, spy, assert) | `skills/lua-testing.md` |
| QA or review process improvement | `skills/qa-review.md` |
| Self-improvement process change | this file |
| Visual / UI rendering discovery | `skills/ui-theming.md` (create if needed) |
| Completed work summary | `.github/progress.md` |

### Commit format

Self-improvement commits are **always separate** from the task work:

```bash
git add .github/
git commit -m "docs: self-improve <skill-name>

One sentence describing what was learned."
```

## After every task — checklist

1. Did I hit any gotcha that wasn't documented?
2. Did I find a better command or approach than what's described?
3. Did I correct a wrong assumption?
4. Update `.github/progress.md` with what changed (always — even small tasks)
5. If yes to 1–3: update the relevant file, commit separately
