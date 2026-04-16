# Customization

## Loop Limit

Default: **3 loops**

To change, edit `SKILL.md` and `commands/workflow.md`, replacing `3` with your preferred limit in the loop-related rules.

Lower values (1-2) are faster but may leave issues unresolved. Higher values (4-5) are more thorough but consume more tokens.

## Web Testing Scope

Default: **Dev server + HTTP requests**

The Reviewer will attempt to:
1. Start the dev server (`npm run dev`, `yarn dev`, etc.)
2. Send HTTP requests to endpoints
3. Check status codes and response structure
4. Test error paths

To limit web testing to build-only, edit the Gate 2 section in `commands/workflow.md` and `commands/review.md`:

```
### Web Testing (if applicable)
- Run the build command (npm run build or equivalent)
- Report success or failure
- Do NOT start dev server or send HTTP requests
```

## Adding Project-Specific Review Rules

Add custom review criteria to your project's `.claude/CLAUDE.md`:

```markdown
# Project: my-app

## Additional Reviewer Rules
- All API endpoints must validate input with zod schemas
- No raw SQL queries — use the ORM
- All async functions must have error boundaries
- Components must not exceed 200 lines
```

The Reviewer will enforce these in Gate 2 alongside the default checks.

## Skipping Gate 1

Use `/po` instead of `/workflow` to skip direction review and go straight to implementation. Useful for small, well-defined tasks where direction review adds no value.

Follow up with `/review` to get verification.

## Model Override

Default: **Opus for both agents**

dual-claude is designed for Opus. Using Sonnet will reduce review quality, especially for complex architectural decisions and security analysis. Not recommended for production workflows.

## Per-Project Overrides

Create a `.claude/CLAUDE.md` in your project root to add project-specific instructions that layer on top of dual-claude's global rules. Claude Code merges all instruction files it finds.

Example project-level override:

```markdown
# Project: my-app

## Additional Reviewer Rules
- This project uses Tailwind CSS — flag any inline styles
- Auth is handled by Clerk — do not implement custom auth
- All database migrations must be reversible

## PO Constraints
- Do not modify files in src/legacy/ — they are frozen
- Use pnpm, not npm
```