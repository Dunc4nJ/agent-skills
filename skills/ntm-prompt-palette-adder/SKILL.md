---
name: ntm-prompt-palette-adder
description: Add a new prompt to the NTM command palette in ~/.config/ntm/config.toml (generates a [[palette]] TOML entry). Use when the user asks to “add a prompt to ntm palette”, “add to NTM command palette”, or “create a palette prompt”.
---

# Add NTM Palette Prompt

Help the user create a well-crafted prompt for the ntm command palette that embodies deep thinking practices.

## Step 1: Gather Information

Ask the user for three pieces of information:

1. **Label**: What should this prompt be called? (e.g., "Deep Code Review", "Architecture Analysis")
2. **Category**: Which category should it appear under?
   - Quick Actions
   - Code Quality
   - Coordination
   - Investigation
   - Or suggest a new category
3. **Intent**: What should this prompt make the agent do? What's the core goal?

## Step 2: Generate the Key

Convert the label to snake_case for the key:
- "Deep Code Review" -> "deep_code_review"
- "Architecture Analysis" -> "architecture_analysis"

## Step 3: Craft the Prompt

Create a prompt that embodies deep thinking principles. Structure it as:

1. **Core Goal** - State the primary objective in clear, imperative language
2. **Reflection Phase** - Add one or more of these reflective elements:
   - "Before taking action, carefully consider the full context and implications..."
   - "Explore the problem space thoroughly - identify constraints, edge cases, and dependencies..."
   - "Question your initial assumptions - what might you be missing?"
   - "Consider alternative approaches and evaluate their trade-offs..."
3. **Verification** - End with: "Before finalizing, verify that your solution addresses the core intent and handles edge cases appropriately."

## Step 4: Show for Approval

Present the complete entry to the user:

```toml
[[palette]]
key = "generated_key"
label = "User's Label"
category = "Category"
prompt = """
[Generated prompt content with deep thinking elements]
"""
```

Ask: "Does this look good? Would you like any changes?"

## Step 5: Append to Config

Once approved, append the entry to `~/.config/ntm/config.toml`.

Use the Edit tool to add the new `[[palette]]` entry at the end of the file, after any existing palette entries.

## Step 6: Confirm Success

Tell the user:
- The prompt was added successfully
- It will appear in `ntm palette` under the specified category
- They can edit it later by modifying `~/.config/ntm/config.toml`

## Example Output

For a user who wants a "Deep Architecture Review" prompt in "Investigation" category:

```toml
[[palette]]
key = "deep_architecture_review"
label = "Deep Architecture Review"
category = "Investigation"
prompt = """
Conduct a thorough architecture review of the codebase.

Before diving in, step back and consider:
- What are the core architectural patterns in use?
- What constraints shaped these design decisions?
- What assumptions might be outdated or incorrect?

Examine:
1. Module boundaries and dependencies
2. Data flow and state management
3. Error handling strategies
4. Performance implications
5. Security considerations

Consider alternative architectures and evaluate trade-offs.

Before finalizing your analysis, verify that your recommendations
are actionable and address real problems, not theoretical concerns."""
```
