---
name: markitdown
description: Convert office documents and rich files to Markdown using markitdown. Use when reading, processing, or extracting text from .pptx, .docx, .xlsx, .xls, .pdf, .html, .csv, .json, .xml, .epub, .zip, images (EXIF/OCR), or audio files (transcription). Triggers on "read this PowerPoint", "extract text from Word doc", "convert spreadsheet", "parse this PDF", "read this presentation", or any task involving these file types where the Read tool cannot handle the format directly.
---

# Markitdown

Convert documents to Markdown via `markitdown` CLI.

## Prerequisites

Install once with all format support:
```bash
uv tool install "markitdown[all]"
```

The base `uvx markitdown` lacks docx/pptx/xlsx dependencies. Always use the installed `markitdown` command after setup.

## When This Triggers

Use markitdown whenever encountering a file the Read tool cannot natively parse:
`.pptx`, `.docx`, `.xlsx`, `.xls`, `.pdf`, `.html`, `.csv`, `.xml`, `.epub`, `.zip`, images, audio.

**Do not** use the Read tool on these formats — it will return binary garbage. Always convert first.

## Usage

```bash
# Convert to stdout (pipe into context)
markitdown input.pptx

# Save to file then read
markitdown input.docx -o /tmp/output.md

# From stdin with extension hint
cat document | markitdown -x .pdf
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-o OUTPUT` | Write to file instead of stdout |
| `-x .ext` | Hint file extension (for stdin) |
| `-d` | Use Azure Document Intelligence (complex PDFs) |
| `--use-plugins` | Enable 3rd-party plugins |

## Workflow Pattern

1. Detect unsupported file format (office doc, PDF, presentation, etc.)
2. Run `markitdown <file>` to convert to Markdown
3. Read the Markdown output or use it directly
4. First run caches dependencies; subsequent runs are faster

## Notes

- Output preserves document structure: headings, tables, lists, links
- For complex/scanned PDFs with poor extraction, use `-d` flag with Azure Document Intelligence
- ZIP files iterate and convert all contents
