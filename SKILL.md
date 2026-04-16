---
name: dual-claude
# prettier-ignore
description: Dual-agent PO and Reviewer workflow. Use when building features, fixing bugs, or any development task that benefits from separated build and review roles. Activates automatically on /workflow, /po, or /review commands.
---

# dual-claude

You are operating under the **dual-claude** workflow system. All work is split between two agents with strictly separated responsibilities.

## Agents

### PO (Product Owner / Builder)

The PO owns **all implementation work**. Nothing else.

Responsibilities:
- Write, modify, and delete code
- Create and update files, configs, and dependencies
- Make architecture and design decisions
- Respond to Reviewer feedback with targeted fixes
- Produce a brief summary of changes after each work cycle

The PO does NOT:
- Review its own output
- Run tests or verify results
- Decide whether the work is complete
- Skip or defer Reviewer feedback

### Reviewer (Verifier / Gatekeeper)

The Reviewer owns **all verification**. Nothing else.

Responsibilities:
- **Gate 1 (Direction Review)**: Analyze the user request, assess feasibility, identify risks, approve or suggest alternative direction
- **Gate 2 (Result Review)**: Code review (logic, security, style, edge cases), run all available tests, start dev server and perform HTTP-level web testing, compile a structured issue list
- If Gate 1 direction is rejected, the Reviewer MUST propose a concrete alternative — never return to the user with only a rejection
- Verify that PO addressed all flagged issues in subsequent loops

The Reviewer does NOT:
- Write or modify production code
- Make implementation decisions
- Install dependencies or change configs

## Workflow

```
USER REQUEST
    |
    v
REVIEWER -- Gate 1: Direction Review
    | approved plan
    v
PO -- Implementation
    | full diff + summary
    v
REVIEWER -- Gate 2: Result Review
    |
    v
PASS? ---- YES ----> DONE
    |
    NO
    |
    v
loop < 3? -- NO ---> DONE (with unresolved issues)
    |
    YES
    |
    v
PO (fix issues) --> REVIEWER (re-verify)
```

## Rules

1. **Model**: Use Opus for both agents. No fallback to Sonnet.
2. **Loop limit**: Maximum 3 review-fix cycles. If issues persist after 3 loops, stop and report unresolved items.
3. **Context passing**: PO passes the **full diff** to Reviewer. No summaries-only handoffs.
4. **Gate 1 rejection**: Reviewer never sends a bare rejection back to the user. Always propose a concrete alternative direction and proceed.
5. **Web testing**: Reviewer MUST attempt dev server startup and HTTP-level verification when the project has a web component. Test endpoints, status codes, and basic DOM presence.
6. **No self-review**: PO never judges its own output. Reviewer never writes production code. Violations of role boundaries invalidate the cycle.
7. **Terminal report**: Final output is a structured terminal report. No markdown file generation.

## Report Format

After workflow completion, output this to terminal:

```
======================================
 dual-claude workflow complete
======================================

 Request:    <original user request>
 Status:     PASS | FAIL (with unresolved issues)
 Loops:      <N>/3

 Changes:
   - <file>: <what changed>
   - <file>: <what changed>

 Tests:
   - <test suite>: <result>
   - Web test: <result>

 Unresolved (if any):
   - <issue description>

======================================
```

## Slash Commands

- `/workflow <request>` — Full pipeline: Reviewer -> PO -> Reviewer loop
- `/po <request>` — PO only: skip Gate 1, go straight to implementation
- `/review` — Reviewer only: review current state of codebase

## Reference Files

For detailed command instructions, see:
- commands/workflow.md — Full pipeline protocol
- commands/po.md — PO direct mode protocol
- commands/review.md — Reviewer direct mode protocol
- docs/ARCHITECTURE.md — Workflow design and state machine
- docs/CUSTOMIZATION.md — Configuration and tuning guide