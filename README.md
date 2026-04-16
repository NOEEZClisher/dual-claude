# dual-claude

A Claude Code skill pack that splits AI work into two specialized agents: **PO** (Product Owner) and **Reviewer**.

```
User Request -> Reviewer (approve direction) -> PO (build) -> Reviewer (verify) -> Done
                                                                    | issues found
                                                              PO (fix) -> Reviewer (re-verify)
                                                                       (max 3 loops)
```

## Why

A single agent doing everything — planning, coding, reviewing — tends to skip its own mistakes. Splitting the work into two roles with distinct objectives forces structured checkpoints and catches problems earlier.

- **PO**: Owns all implementation. Code, files, config, dependencies, architecture decisions.
- **Reviewer**: Owns all verification. Direction review, code review, test execution, web testing, final sign-off.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Claude Max plan (uses Opus for both agents)

## Install

```bash
git clone --depth 1 https://github.com/NOEEZ/dual-claude.git ~/.claude/skills/dual-claude
cd ~/.claude/skills/dual-claude && chmod +x setup.sh && ./setup.sh
```

The setup script symlinks `/workflow`, `/po`, and `/review` commands to `~/.claude/commands/`.

## Usage

### Full pipeline

```
/workflow implement user authentication with JWT
```

Runs the complete Reviewer -> PO -> Reviewer loop automatically.

### Individual agents

```
/po refactor the database layer to use connection pooling
/review check the current codebase for security issues
```

## Update

```bash
cd ~/.claude/skills/dual-claude && git pull
```

Commands update automatically since they are symlinked.

## Uninstall

```bash
cd ~/.claude/skills/dual-claude && chmod +x uninstall.sh && ./uninstall.sh
```

Or manually:

```bash
rm ~/.claude/commands/{workflow,po,review}.md
rm -rf ~/.claude/skills/dual-claude
```

## Customization

See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for tuning loop limits, test scope, and agent behavior.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed workflow specification.

## License

MIT