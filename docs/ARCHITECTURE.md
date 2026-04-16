# Architecture

## Overview

dual-claude is a Claude Code skill pack that enforces a two-agent workflow for software development. Instead of a single AI handling everything, work is split between a **PO** (builder) and a **Reviewer** (verifier) with strict role boundaries.

## Design Principles

### Separation of Concerns

The PO never reviews its own work. The Reviewer never writes production code. This separation exists because self-review is unreliable — an agent that wrote the code will rationalize its own mistakes.

### Gate-Based Flow

The workflow has two gates, both owned by the Reviewer:

- **Gate 1 (Direction)**: Before any code is written, the Reviewer assesses whether the approach makes sense. If it doesn't, the Reviewer proposes an alternative and proceeds — never a dead-end rejection.
- **Gate 2 (Verification)**: After the PO finishes, the Reviewer runs code review, tests, and web testing. Issues are sent back to the PO with specific descriptions and locations.

### Bounded Loops

The fix-review cycle is capped at 3 iterations. This prevents infinite loops where the PO keeps introducing new issues while fixing old ones. After 3 loops, the workflow stops and reports unresolved issues for human decision.

## Agent Specifications

### PO (Product Owner)

| Attribute   | Value                                         |
|-------------|-----------------------------------------------|
| Model       | Opus                                          |
| Scope       | All implementation work                       |
| Inputs      | Approved plan (Gate 1) or issue list (loops)  |
| Outputs     | Change summary + full diff                    |
| Prohibited  | Running tests, self-review, skipping feedback |

### Reviewer

| Attribute   | Value                                         |
|-------------|-----------------------------------------------|
| Model       | Opus                                          |
| Scope       | All verification work                         |
| Inputs      | User request (Gate 1) or full diff (Gate 2)   |
| Outputs     | Approved plan or verdict + issue list          |
| Prohibited  | Writing code, installing deps, changing config |

## Workflow State Machine

```
          START
            |
            | user request
            v
         GATE_1     Reviewer: direction review
            |
            | approved plan
            v
          BUILD      PO: implementation
            |
            | diff + summary
            v
    +---> GATE_2     Reviewer: result review
    |       |
    |   +---+---+
    |   v       v
    | FAIL    PASS
    |   |       |
    |   v       v
    | loop<3?  DONE
    | YES  NO
    |  |    |
    +--+    v
          DONE (with unresolved)
```

## Context Flow

Each handoff between agents carries specific data:

| Transition        | Data Passed                         |
|-------------------|-------------------------------------|
| User -> Reviewer  | Raw user request                    |
| Reviewer -> PO    | Approved plan with scope boundary   |
| PO -> Reviewer    | Full git diff + change summary      |
| Reviewer -> PO    | Structured issue list with locations |
| Final -> Terminal  | Formatted report                   |

The full diff (not a summary) is always passed from PO to Reviewer. This ensures the Reviewer can catch issues the PO might omit from a summary.

## File Structure

```
dual-claude/
├── CLAUDE.md               # Root skill — Claude Code reads this first
├── commands/
│   ├── workflow.md          # /workflow — full pipeline
│   ├── po.md                # /po — builder only
│   └── review.md            # /review — reviewer only
├── docs/
│   ├── ARCHITECTURE.md      # This file
│   └── CUSTOMIZATION.md     # Tuning guide
├── README.md
└── LICENSE
```