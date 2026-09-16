---
sidebar_position: 1
---

# Tylina

[Tylina](https://tylina.github.io/) is the recommended AI-native, document-first, WYSIWYG editor and presenter for Touying. It runs in the browser or as a desktop app while keeping ordinary `.typ` files as the canonical source.

> [Open Touying's simple example in Tylina Web](https://tylina.github.io/app/?repo=https%3A%2F%2Fgithub.com%2Ftouying-typ%2Ftouying&provider=github&ref=main&load=dependencies&main=examples%2Fsimple.typ&file=examples%2Fsimple.typ&view=slides)

This link imports the GitHub repository, fetches dependencies as the compiler requests them, selects `examples/simple.typ`, and opens Slides view. The web app compiles locally with WebAssembly and keeps its working copy in the browser.

## Why use Tylina with Touying?

- Edit directly on the typeset page, or use Source Lens and Split for source-level control.
- Manage slide thumbnails and speaker notes, reorder pages, and present from the same workspace.
- Open complete GitHub/GitLab repositories or load only the dependencies needed by the current file.
- Work with document-aware AI: connect your own model in the Web editor or an ACP agent on desktop, then use shared tools to edit, compile, and check the workspace.
- Browse templates and export PDF or PowerPoint without leaving the editor.

## Editable PowerPoint export

Open Tylina's Export tool, choose **PPTX**, then choose the mode that matches your goal. Both modes preserve speaker notes.

| Mode | Best for | Trade-off |
| --- | --- | --- |
| **Editable (experimental)** | Continuing work in PowerPoint. Text, simple inline math, supported images and shapes, and supported external or slide links become native PowerPoint objects. | Complex content stays in ordered vector fallback layers. Font substitution and PowerPoint text metrics can change line wrapping, so the result is not pixel-identical and not every element is editable. |
| **Visual fidelity** | Presenting with the closest match to the Typst layout. | Each slide is a rendered image, so its text and individual elements are not editable. |

For a landscape deck, Tylina Web can also show a direct **Export as PPTX** action; use the full Export tool when you want to select the mode or inspect its conversion summary.

## Reuse the web link

The example URL uses `repo` and `ref` to select a repository revision, `main` as the compilation entry point, `file` as the file initially shown, and `view=slides` to enter Slides view. Keep `load=dependencies` for a fast, on-demand import, or use `load=all` when you need the complete repository and Git workflow.

[Gistd](./gistd.md) remains useful for a lightweight, read-only link. Choose Tylina when viewers need a complete editable workspace, presenting tools, or PowerPoint export.
