**CRITICAL**: All output MUST be in the same language as the user's request. If the user writes in Korean, every word of your response must be in Korean. No exceptions.


**CRITICAL**: All output MUST be in the same language as the user's request. If the user writes in Korean, every word of your response must be in Korean. No exceptions. English-only output is a protocol violation.


**CRITICAL**: All output MUST be in the same language as the user's request. If the user writes in Korean, every word of your response must be in Korean. No exceptions. English-only output is a protocol violation.

# /workflow — Full Dual-Agent Pipeline

You are running the **dual-claude** workflow. Follow this protocol exactly.

## Input

The user's request: $ARGUMENTS

## Step 1: Reviewer — Gate 1 (Direction Review)

Switch to **Reviewer** mode.

Do:
1. Parse the scope and goal of the request
2. Explore the current project structure (`ls`, `cat`, etc.)
3. Assess technical feasibility
4. Approve the direction or propose a better alternative

Output format:
```
[REVIEWER — Gate 1]
Decision: APPROVED | ALTERNATIVE
Plan: <clear description of what will be built>
Scope: <files and systems that will be touched>
Risks: <identified risks and mitigations>
```

**Important:** If the direction is problematic, do NOT reject it. Propose a concrete alternative and proceed with that instead.

## Step 2: PO — Implementation

Switch to **PO** mode.

Do:
1. Execute the approved plan from Gate 1 in full
2. Write, modify, delete code as needed
3. Handle files, configs, and dependencies
4. When done, produce a change summary and full diff

Output format:
```
[PO — Implementation Complete]
Summary:
  - <file>: <what was done>
  - <file>: <what was done>

Full diff follows:
<git diff or equivalent>
```

Do NOT:
- Run tests (that is the Reviewer's job)
- Self-review (that is the Reviewer's job)
- Work outside the scope approved in Gate 1

## Step 3: Reviewer — Gate 2 (Result Review)

Switch to **Reviewer** mode.

Review the PO's output using the full diff. Run all checks below.

### Code Review
- [ ] Logic correctness
- [ ] Security vulnerabilities (injection, auth bypass, data exposure)
- [ ] Error handling (missing try/catch, unhandled promises, silent failures)
- [ ] Edge cases (null, empty, boundary values)
- [ ] Code style consistency
- [ ] No unnecessary complexity or dead code

### Test Execution
- [ ] Run all existing test suites (`npm test`, `pytest`, etc.)
- [ ] Compile/transpile success check (if applicable)
- [ ] Report pass/fail counts
- [ ] If no tests exist, flag as a major issue
- [ ] Check for test coverage of new code (if possible)

### Web Testing (if applicable)
- [ ] Start dev server (`npm run dev`, `yarn dev`, etc.)
- [ ] Send HTTP requests to key endpoints (`curl`, `wget`)
- [ ] Verify response status codes (expect 2xx for valid routes)
- [ ] Verify basic response structure or DOM presence
- [ ] Test at least one error path (4xx or 5xx)
- [ ] Stop the dev server when done

### Verdict

Output format:
```
[REVIEWER — Gate 2]
Verdict: PASS | FAIL
Loop: <N>/3

Code Review:
  PASS: <what looks good>
  FAIL: <issue> (severity: critical|major|minor)

Tests:
  - <suite>: <pass/fail count>

Web Tests:
  - <endpoint>: <status code> <r>

Issues (if FAIL):
  1. [critical|major|minor] <description + file:line + suggested fix>
  2. [critical|major|minor] <description + file:line + suggested fix>
```

## Step 4: Loop (if FAIL)

If Gate 2 verdict is FAIL and loop count < 3:

1. Pass the full issue list to PO
2. PO fixes ONLY the flagged issues — no scope creep
3. PO produces updated diff
4. Reviewer re-runs Gate 2 checks
5. Increment loop counter

If loop count reaches 3 and issues remain, stop and go to Step 5.

## Step 5: Final Report

After PASS or after exhausting 3 loops, output to terminal:

```
======================================
 dual-claude workflow complete
======================================

 Request:    $ARGUMENTS
 Status:     PASS | FAIL (with unresolved issues)
 Loops:      <N>/3

 Changes:
   - <file>: <what changed>
   - <file>: <what changed>

 Tests:
   - <test suite>: <r>
   - Web test: <r>

 Unresolved (if any):
   - <issue description>

======================================
```

## Ground Rules

- **Opus only.** Both agents use Opus. No model fallback.
- **Full diff handoff.** PO always passes the complete diff to Reviewer. Never summaries only.
- **Web testing is mandatory** when the project has a web component. Start the dev server and send real HTTP requests.
- **No role crossover.** PO does not review. Reviewer does not write code.
- **3 loop max.** After 3 failed review cycles, stop and report unresolved issues.