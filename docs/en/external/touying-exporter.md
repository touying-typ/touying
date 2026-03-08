---
sidebar_position: 4
---

# Touying Exporter

[touying-exporter](https://github.com/touying-typ/touying-exporter) is a command-line tool that exports Touying presentations to video formats (MP4, GIF, WebM) by rendering each subslide and assembling them into an animation.

## Installation

```sh
cargo install touying-exporter
```

Or download a pre-built binary from the [releases page](https://github.com/touying-typ/touying-exporter/releases).

## Basic Usage

Given a Touying `.typ` file, run:

```sh
touying-exporter slides.typ --output slides.mp4
```

This compiles each page (subslide) of the presentation and encodes them into a video at the default frame rate.

### Common Options

| Flag | Description |
|------|-------------|
| `--output <PATH>` | Output file path. The format is inferred from the extension (`.mp4`, `.gif`, `.webm`). |
| `--fps <N>` | Frames per second for the exported video (default: `24`). |
| `--duration <SECS>` | Duration in seconds to hold each slide before transitioning (default: `1`). |
| `--root <PATH>` | Root path for the Typst compiler, equivalent to `typst compile --root`. |
| `--font-path <PATH>` | Additional font search path. |

### Example: export to GIF

```sh
touying-exporter slides.typ --output slides.gif --fps 2 --duration 2
```

This produces a GIF that advances one subslide every 2 seconds at 2 fps — suitable for embedding animated demos in websites or README files.

### Example: export to MP4

```sh
touying-exporter slides.typ --output slides.mp4 --fps 30 --duration 3
```

## Tips

- **Handout mode** — Before exporting, consider whether you want the full animated version or a static handout. For a static export, pass `config-common(handout: true)` in your document.
- **Font paths** — If your system fonts are not automatically detected, add `--font-path /path/to/fonts`.
- **CI/automation** — `touying-exporter` can be integrated into CI pipelines to automatically produce demo GIFs for your slides repository.
