#!/usr/bin/env python3
"""Extract text and images from PDFs using pymupdf + pymupdf4llm.

Lightweight (~25MB), instant, no models needed. Produces structured markdown
with headings, tables, and code blocks preserved. Also extracts images with
page-position metadata for accurate figure-to-text mapping.

Usage:
    python extract-pdf-pymupdf.py document.pdf                      # Markdown to stdout
    python extract-pdf-pymupdf.py document.pdf --images /tmp/imgs/  # Also extract images with metadata
    python extract-pdf-pymupdf.py document.pdf --json               # JSON with markdown + images + metadata
    python extract-pdf-pymupdf.py document.pdf --tables             # Extract tables as markdown
    python extract-pdf-pymupdf.py document.pdf --pages 0-4          # Specific page range
    python extract-pdf-pymupdf.py document.pdf --metadata           # PDF metadata only

Output (--json mode):
    {
      "markdown": "# Paper Title\\n\\n## Abstract\\n...",
      "images": [
        {"file": "img-001.png", "page": 3, "width": 800, "height": 600, "bytes": 45230},
        ...
      ],
      "metadata": { "pages": 12, "title": "...", "author": "..." }
    }

Requires: pymupdf pymupdf4llm (pip install pymupdf pymupdf4llm, ~25MB total)
"""
import sys
import os
import json


def extract_markdown(path, pages=None):
    """Extract structured markdown from PDF."""
    import pymupdf4llm
    return pymupdf4llm.to_markdown(path, pages=pages)


def extract_images(path, output_dir, min_size=5120, min_dim=150):
    """Extract images with page-position metadata.
    
    Returns list of dicts with file, page, width, height, bytes.
    Filters out images under min_size bytes or min_dim pixels.
    """
    import pymupdf
    from pathlib import Path
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    doc = pymupdf.open(path)
    images = []
    idx = 0
    
    for page_num in range(len(doc)):
        page = doc[page_num]
        for img_info in page.get_images(full=True):
            xref = img_info[0]
            pix = pymupdf.Pixmap(doc, xref)
            
            # Convert CMYK to RGB
            if pix.n >= 5:
                pix = pymupdf.Pixmap(pymupdf.csRGB, pix)
            
            # Size filter
            img_bytes = len(pix.tobytes("png"))
            if img_bytes < min_size:
                continue
            
            # Dimension filter
            if pix.width < min_dim and pix.height < min_dim:
                continue
            
            idx += 1
            filename = f"img-{idx:03d}.png"
            out_path = os.path.join(output_dir, filename)
            pix.save(out_path)
            
            images.append({
                "file": filename,
                "page": page_num + 1,  # 1-indexed
                "width": pix.width,
                "height": pix.height,
                "bytes": os.path.getsize(out_path),
            })
    
    return images


def extract_tables(path):
    """Extract tables as markdown."""
    import pymupdf
    doc = pymupdf.open(path)
    output = []
    for i, page in enumerate(doc):
        tables = page.find_tables()
        for j, table in enumerate(tables.tables):
            output.append(f"\n--- Page {i+1}, Table {j+1} ---\n")
            df = table.to_pandas()
            output.append(df.to_markdown(index=False))
    return "\n".join(output)


def get_metadata(path):
    """Extract PDF metadata."""
    import pymupdf
    doc = pymupdf.open(path)
    return {
        "pages": len(doc),
        "title": doc.metadata.get("title", ""),
        "author": doc.metadata.get("author", ""),
        "subject": doc.metadata.get("subject", ""),
        "creator": doc.metadata.get("creator", ""),
        "format": doc.metadata.get("format", ""),
    }


def parse_pages(pages_str):
    """Parse page range string like '0-4' or '3'."""
    if "-" in pages_str:
        start, end = pages_str.split("-")
        return list(range(int(start), int(end) + 1))
    return [int(pages_str)]


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        sys.exit(0)

    path = args[0]
    pages = None
    images_dir = None
    output_format = "markdown"

    if "--pages" in args:
        idx = args.index("--pages")
        pages = parse_pages(args[idx + 1])

    if "--images" in args:
        idx = args.index("--images")
        images_dir = args[idx + 1] if idx + 1 < len(args) else "/tmp/pdf-images"

    if "--json" in args:
        output_format = "json"

    if "--metadata" in args:
        print(json.dumps(get_metadata(path), indent=2))
        sys.exit(0)

    if "--tables" in args:
        print(extract_tables(path))
        sys.exit(0)

    # Main extraction
    md = extract_markdown(path, pages=pages)
    image_list = []
    if images_dir:
        image_list = extract_images(path, images_dir)
        print(f"Extracted {len(image_list)} image(s) to {images_dir}/", file=sys.stderr)

    if output_format == "json":
        result = {
            "markdown": md,
            "images": image_list,
            "metadata": get_metadata(path),
        }
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(md)
