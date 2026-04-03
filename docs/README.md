# Touying Docs Authoring Guide

This directory contains the source documentation for Touying.
The docs are written in Markdown and are consumed by the website repository.

## Scope

- `docs/en/`: English source docs.
- `docs/zh/`: Chinese source docs.
- `docs/README.md`: This guide for contributors.

## Key Writing Conventions

### 1) Use `example` fences for executable examples

Use fenced code blocks with the `example` info string when the snippet is intended to be rendered and validated as a runnable example by docs tooling.

Example:

````markdown
```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title
== First Slide
Hello, Touying!
```
````

Use regular fences like `typst`, `md`, or `bash` for non-executable snippets.

### 2) `>>>` lines are setup-only prelude lines

Inside an `example` block, lines prefixed with `>>> ` are used as prelude/setup content.
This is typically used to inject common Touying bootstrap code (imports and theme setup) for snippet execution without repeating full boilerplate in the visible demo body.

Typical prelude:

```typst
>>> #import "@preview/touying:0.7.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
```

Use this pattern when the snippet body starts directly from feature usage such as `#slide[...]`, `#pause`, `#meanwhile`, `#only`, or `#uncover`.

### 3) `<<<` lines are display-oriented helper lines

Inside an `example` block, `<<< ` is used for lines that should be treated differently from normal runnable body lines by docs tooling.
In this docs set, it is mainly used in multi-file tutorial snippets (for example `main.typ` portions) to keep the instructional text accurate while preserving example processing behavior.

Keep `<<<` usage minimal and only for cases that need this distinction.

## Localization and Publishing Paths

Content from this repository is published in `touying-typ/touying-typ.github.io`.

- English docs (`docs/en/**`) are placed under `docs/**`.
- Chinese docs (`docs/zh/**`) are placed under `i18n/zh/docusaurus-plugin-content-docs/current/**`.

When updating docs, keep `en` and `zh` aligned in structure and topic coverage whenever possible.

## Contributor Checklist

- Use `example` fences for runnable demos.
- Add `>>>` prelude lines when a snippet needs Touying bootstrap setup.
- Keep `<<<` only where multi-file or special display/execution behavior is required.
- Preserve heading structure and frontmatter consistency across `en` and `zh`.
- Verify links and package versions in examples.
