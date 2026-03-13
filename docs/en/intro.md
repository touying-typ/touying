---
sidebar_position: 1
---

# Introduction to Touying

[Touying](https://github.com/touying-typ/touying) is a powerful slide/presentation package for [Typst](https://typst.app/). It is similar to LaTeX Beamer but benefits from Typst's modern syntax and fast compilation. Throughout this documentation we use **slides** to refer to the whole slideshow, **slide** for a single page, and **subslide** for a sub-page produced by an animation step.

## Why Use Touying?

- **vs. PowerPoint** — Touying follows a "content and style separation" philosophy. You write plain text with lightweight markup, and themes handle the visual design automatically. This is especially productive for research-heavy presentations with code blocks, mathematical formulas, and theorem environments.
- **vs. Markdown Slides** — Typst gives you fine-grained typesetting control (headers, footers, custom layouts, and first-class math support) that Markdown-based tools struggle to provide. Touying adds `#pause` and `#meanwhile` for incremental animations that feel natural in a code-first workflow.
- **vs. Beamer** — Touying compiles in milliseconds instead of seconds (or tens of seconds). Its syntax is far more concise, and creating or modifying a theme is straightforward. Feature parity with Beamer is high, plus Touying offers extras like `touying-reducer` for animated CeTZ/Fletcher diagrams.
- **vs. Polylux** — Touying does not rely on `counter` and `locate` to implement `#pause`, so it avoids the performance penalty those primitives incur. It also provides a richer set of theme utilities and a unified config API that lets you switch themes with minimal changes to your document.

## About the Name

"Touying" (投影, tóuyǐng) means "projection" in Chinese — just as the German word *Beamer* means projector in LaTeX's world.

## Where to Write Your Slides

You have two main options:

| Option | Description |
|--------|-------------|
| **[Typst Web App](https://typst.app/)** | Browser-based editor. No installation needed; just open `typst.app`, create a new project, and start writing. Supports real-time preview and collaboration. |
| **[Tinymist for VS Code](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)** | A full-featured Typst LSP extension for VS Code. Provides syntax highlighting, autocomplete, error diagnostics, and a built-in slide preview panel. |

Both options automatically download Touying from the Typst package registry — no separate installation step is required.

## Universe

Tired of [built-in themes](https://touying-typ.github.io/themes/)?

[Typst Universe](https://typst.app/universe/search/?q=touying) has a wide variety of themes uploaded by touying users, take a look, maybe you'll like it.


## Gallery

Touying provides [a gallery](https://github.com/touying-typ/touying/wiki) where community members share their slides. You are encouraged to contribute your own work!

## Contribution

Touying is free, open-source, and community-driven. Visit [GitHub](https://github.com/touying-typ/touying) to open issues, submit pull requests, or join the [touying-typ](https://github.com/touying-typ) organization.

## License

Touying is released under the [MIT license](https://github.com/touying-typ/touying/blob/main/LICENSE).