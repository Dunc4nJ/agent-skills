---
name: aprx-iterate
description: Runs iterative APRX specification refinement until convergence. Executes APRX rounds, integrates GPT Pro suggestions into spec and README, commits changes, and tracks convergence. Use when user wants to refine a specification through multiple GPT Pro review cycles.
user_invocable: true
---

# APRX Iterate

Automates the full APRX iterative refinement workflow until convergence.

## Headless Mode (Default)

`aprx` runs in headless mode by default - no display or VNC required. This enables:
- Running on servers without X11/display
- Concurrent aprx sessions without browser conflicts
- Running alongside direct Oracle commands

Use `--force` flag with `aprx run` to enable concurrent sessions without Oracle duplicate prompt conflicts.

### Authentication Failures

If a round fails due to authentication:
1. The skill will detect auth errors in Oracle output
2. Prompt user to re-authenticate via VNC with `--headed` flag

## Critical Constraint: File Scope

**ONLY modify the files specified in the workflow configuration:**
- `documents.readme` - The README file
- `documents.spec` - The specification file
- `documents.implementation` - The implementation file (if configured)

**DO NOT:**
- Create new files (even if GPT Pro suggests them)
- Modify any files outside the workflow document paths
- Add directories, configs, CI workflows, or other artifacts

**If GPT Pro suggests creating new files or adding new artifacts:**
1. **Do NOT create the files** - only modify workflow documents
2. **Incorporate the suggestion into the spec** - add the proposed content/structure as planned work in the specification document
3. For example: if GPT Pro suggests creating `docs/ARCHITECTURE.md`, add an "Architecture" section to the spec with that content

This constraint applies to ALL phases: integration, commits, and any other file operations.

## Prerequisites

- APRX must be configured (`aprx setup` already run)
- `.apr/` directory exists with valid workflow
- Oracle installed with ChatGPT session active

## Autonomous Execution

**Do NOT ask for user approval between rounds.** Continue the iteration cycle automatically until:
- Convergence is detected (score >= 0.75), OR
- Maximum rounds reached (15)

This is a fully autonomous workflow. Only stop and notify the user if:
- An error occurs that cannot be recovered
- Authentication is required (VNC login with --headed flag)
- Maximum rounds are reached without convergence

## Workflow

### 1. Validate Setup

```bash
aprx robot status
```

Parse JSON response and check:
- `data.configured == true` - APRX is configured
- `data.oracle_available == true` - Oracle is available
- `data.default_workflow` - Extract workflow name for later use

If not configured, exit with: "APRX not configured. Run `aprx setup` first."

### 2. Get Document Paths

Read workflow YAML to get document paths:

```bash
cat .apr/workflows/<workflow>.yaml
```

Parse YAML to extract:
- `documents.readme` - Path to README file
- `documents.spec` - Path to specification file
- `documents.implementation` - Path to implementation doc (optional)

### 3. Detect Next Round

```bash
aprx robot history
```

Parse JSON response:
- `data.count` - Number of existing rounds
- Next round = `data.count + 1` (or 1 if count == 0)

### 4. Main Loop

Execute rounds until convergence (score >= 0.75) or max 15 rounds.

For each round N:

#### a. Validate Round

```bash
aprx robot validate N
```

Parse JSON response:
- `data.valid == true` - Proceed
- `data.valid == false` - Report `data.errors[]` and exit

#### b. Run APRX Round

```bash
aprx run N --force --wait
```

APRX handles implementation inclusion automatically via `impl_every_n` in workflow YAML.

**On failure**: Retry once after 30 seconds. On second failure, pause and notify user about VNC re-auth.

#### c. Read Round Output

```bash
aprx robot show N
```

Parse JSON response:
- `data.content` - Full GPT Pro output text with suggestions

#### d. Integrate Suggestions

Following [integration-guide.md](integration-guide.md):

1. Read current Spec and README using paths from step 2
2. Parse each suggestion from `data.content`
3. For suggestions that modify spec/readme/impl: apply changes directly
4. For suggestions that propose **new files**: incorporate the content into the spec document as a new section (do NOT create the file)
5. Update README to reflect spec changes
6. If implementation file is configured, update it as needed

**Remember**: Only modify files from `documents.*` in the workflow YAML. New file suggestions become spec content.

#### e. Output Integration Summary

After integrating, output:

```
Round N integration complete.

Changes made:
- [3-5 bullet points of key changes]

Skipped (if any):
- [Suggestions not applied and why]

Files modified: [list]
```

#### f. Commit Changes

Only commit the workflow document files that were modified:

```bash
git add <spec-file> <readme-file> [<impl-file>]
git commit -m "aprx: integrate round N suggestions"
```

**Do not** `git add .` or add any files outside the workflow documents.

#### g. Generate Metrics

```bash
aprx backfill
```

This generates/updates analytics from completed rounds. Required before checking convergence.

#### h. Check Convergence

```bash
aprx robot stats
```

Parse JSON response:
- If `ok: false` with `code: "not_found"`: Metrics need more rounds (continue iterating)
- If `ok: true`: Check `data.convergence`:
  - `confidence`: Score from 0.0-1.0
  - `detected`: Boolean if converged
  - `reason`: "insufficient_rounds" if not enough data

Report:

```
Convergence score: X.XX (LOW/MODERATE/HIGH)
```

- `data.convergence.detected: true` OR `confidence >= 0.75`: Mark converged, exit loop
- `confidence < 0.75`: Continue to next round
- `reason: "insufficient_rounds"`: Continue (need 2+ rounds for meaningful convergence)

### 5. Generate Final Summary

After loop completes (converged or max rounds):

```
APRX Iteration Complete

Rounds completed: N
Final convergence score: X.XX
Status: CONVERGED / MAX_ROUNDS_REACHED

High-level changes from original spec:
- [Architectural changes]
- [Security improvements]
- [Performance additions]
- [API restructuring]
- [Error handling updates]

Files modified:
- <spec-file> (X lines changed)
- <readme-file> (Y lines changed)

All changes committed. Review git log for detailed history.
```

## Error Handling

### Oracle/APRX Failures

1. Wait 30 seconds
2. Retry the failed command once
3. If still fails, check for auth error
4. Notify user with VNC instructions:

```
APRX round failed. ChatGPT session may have expired.

To re-authenticate:
1. SSH tunnel: ssh -L 5901:localhost:5901 user@vps
2. Connect VNC to localhost:5901
3. Run: aprx run N --headed --login --wait
4. Complete ChatGPT login in browser
5. Re-run /aprx-iterate after login succeeds
```

### First Round Special Case

Round 1 may require manual login. If auth fails on round 1:

```
First round requires manual ChatGPT login.

1. SSH tunnel: ssh -L 5901:localhost:5901 user@vps
2. Connect VNC to localhost:5901
3. Run: aprx run 1 --headed --login --wait
4. Complete ChatGPT login in browser
5. Re-run /aprx-iterate after login succeeds
```

## Convergence Interpretation

| Score | Level | Meaning |
|-------|-------|---------|
| 0.00-0.40 | LOW | Major changes still occurring |
| 0.41-0.74 | MODERATE | Refinements stabilizing |
| 0.75-1.00 | HIGH | Converged, safe to stop |

## Reference

- [integration-guide.md](integration-guide.md) - How to integrate GPT suggestions
- [workflow-reference.md](workflow-reference.md) - APRX command reference
