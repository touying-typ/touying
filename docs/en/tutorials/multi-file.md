---
sidebar_position: 6
---

# Multi-File Architecture

For small presentations, a single `.typ` file works perfectly. For longer talks — course materials, lecture series, or conference proceedings — Touying's concise syntax and incremental compilation make a multi-file layout attractive and practical.

## The Three-File Pattern

The most common multi-file layout separates concerns across three files:

```
globals.typ   ← imports, custom helpers, theme registration
main.typ      ← show rules, document metadata, #include content
content.typ   ← actual slide content
```

### `globals.typ`

Houses everything that both `main.typ` and `content.typ` need without causing circular imports:

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly

// custom helper
#let emph-box(body) = box(
  stroke: 1pt + blue,
  inset: 0.5em,
  radius: 0.25em,
  body,
)
```

### `main.typ`

The entry point. Applies the show rule and includes content:

```typst
// main.typ
#import "/globals.typ": *

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [My Course],
    subtitle: [Lecture 1],
    author: [Dr. Smith],
    date: datetime.today(),
    institution: [State University],
    logo: emoji.school,
  ),
)

#include "content.typ"
```

### `content.typ`

Pure content — no theme boilerplate:

```typst
// content.typ
#import "/globals.typ": *

#title-slide()

= Introduction

== Motivation

#lorem(40)

#emph-box[This is an important note.]

#focus-slide[
  Key Idea
]
```

## Multiple Section Files

For a course with many chapters, split content into one file per section:

```
main.typ
globals.typ
sections/
  intro.typ
  methods.typ
  results.typ
  conclusion.typ
```

`main.typ` includes them in order:

```typst
// main.typ
#import "/globals.typ": *

#show: university-theme.with(…)

#include "sections/intro.typ"
#include "sections/methods.typ"
#include "sections/results.typ"
#include "sections/conclusion.typ"
```

Each section file follows the same pattern as `content.typ`.

## Shared Configuration

If multiple entry files need the same settings (e.g., a presentation file and a handout file), put the configuration in `globals.typ` and import it:

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *

#let base-config = (
  aspect-ratio: "16-9",
  config-info(title: [My Talk], author: [Alice]),
)
```

```typst
// handout.typ
#import "/globals.typ": *

#show: university-theme.with(..base-config, config-common(handout: true))
#include "content.typ"
```

## Absolute Import Paths

When using `#import` or `#include` inside deeply nested files, use absolute paths anchored to the project root to avoid path-resolution issues:

```typst
// Works from any file depth
#import "/globals.typ": *
```

The Typst CLI and Tinymist both resolve `/` as the `--root` directory. Set the root with:

```sh
typst compile --root . main.typ
```

## Tips for Large Slide Decks

- Keep `globals.typ` lean — it is imported by every file and parsed on every recompile.
- Avoid `counter` and heavy `context` computations in shared helpers; Touying's animation engine already manages subslide counters efficiently.
- Use `#pagebreak(weak: true)` instead of a hard pagebreak when you want optional page breaks that collapse at the start or end of a section.
