---
sidebar_position: 4
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) is a companion command-line tool for Touying that exports presentations to additional formats beyond PDF. It wraps `typst compile` and post-processes the output for use cases such as:

- **PPTX** — Microsoft PowerPoint format.
- **HTML** — Interactive HTML slides with CSS transitions.
- **PNG/SVG per slide** — Individual image files, one per subslide.

## Installation

```sh
# Using cargo (Rust package manager)
cargo install touying-exporter

# Or download a pre-built binary from the releases page
# https://github.com/touying-typ/touying-exporter/releases
```

## Basic Usage

### Export to PNG

Export each slide (subslide) as a separate PNG file:

```sh
touying-exporter png my-slides.typ
```

Output files are named `my-slides-001.png`, `my-slides-002.png`, etc.

### Export to SVG

```sh
touying-exporter svg my-slides.typ
```

### Export to PPTX

```sh
touying-exporter pptx my-slides.typ
```

### Export to HTML

```sh
touying-exporter html my-slides.typ
```

## Options

| Flag | Description |
|------|-------------|
| `--root <path>` | Typst root directory (default: current directory) |
| `--output <path>` | Output file or directory |
| `--ppi <n>` | Pixels per inch for PNG/SVG export (default: 144) |
| `--input <key=value>` | Typst `--input` arguments passed through |

## Working with Multi-File Projects

For multi-file projects, specify the root:

```sh
touying-exporter png --root . main.typ --output ./output/
```

## Generating Per-Slide Images for a Web Gallery

A common use case is generating a slide gallery for a website or README:

```sh
# Export all slides as PNGs at high resolution
touying-exporter png --ppi 200 slides.typ --output ./gallery/
```

## Tips

- The exporter respects Touying's slide counter, so handout-only slides and appendix slides are handled correctly.
- For PDF export, just use `typst compile` directly — the exporter does not add value over the native PDF output.
- SVG export is useful when embedding individual slides in other documents or web pages.
