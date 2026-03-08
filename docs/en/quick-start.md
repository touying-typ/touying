---
sidebar_position: 1
---

# Quick Start

## What is Touying?

[Touying](https://github.com/touying-typ/touying) is a powerful presentation package for [Typst](https://typst.app/), inspired by LaTeX Beamer. It lets you write slides in plain text with a clean, concise syntax — no drag-and-drop required. With Touying you get:

- **Fast compilation** — incremental rendering keeps feedback in milliseconds, not seconds.
- **Content/style separation** — write content in Typst markup; themes handle the look.
- **Rich animations** — `#pause`, `#meanwhile`, `#uncover`, `#only`, and more.
- **Built-in themes** — six polished themes ready to use out of the box.
- **Extensible** — integrate CeTZ, Fletcher, Codly, Pinit, and other Typst packages seamlessly.

> **Terminology:** In this documentation *slides* refers to a slideshow, *slide* refers to a single slide, and *subslide* refers to one step in an animated slide.

## Setting Up Your Environment

You can write Touying presentations in the browser or locally.

### Option 1 — Typst Web App (no install)

Go to [typst.app](https://typst.app/), create a new project, and start typing. Touying is available directly from the Typst Universe package registry — no installation needed.

### Option 2 — VS Code with Tinymist (recommended for local work)

1. Install [VS Code](https://code.visualstudio.com/).
2. Install the [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension from the VS Code Marketplace.
3. Open or create a `.typ` file. Tinymist provides live preview, auto-completion, and hover documentation for Touying functions.

### Option 3 — Typst CLI

Install the [Typst CLI](https://github.com/typst/typst/releases) and compile from the command line:

```sh
typst compile slides.typ
```

Use `typst watch slides.typ` for live recompilation on save.

## Your First Presentation

Add the following to a new `.typ` file:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= My First Talk

== Introduction

Hello, Touying!

#pause

Hello, Typst!
```

That's it — you just created a two-slide presentation with an animated reveal! 🎉

**What's happening here?**

| Line | What it does |
|------|-------------|
| `#import "@preview/touying:0.6.2": *` | Imports the Touying package |
| `#import themes.simple: *` | Imports the Simple theme |
| `#show: simple-theme.with(...)` | Activates the theme and its default settings |
| `= My First Talk` | Creates a section slide (first-level heading) |
| `== Introduction` | Creates a content slide (second-level heading) |
| `#pause` | Splits the content into two subslides (animated reveal) |

## A More Complete Example

Here is a richer presentation using the University theme that showcases animations, multi-column layouts, CeTZ diagrams, and theorems:

```example
#import "@preview/touying:0.6.2": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion

// bind CeTZ and Fletcher to Touying's animation engine
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: [My Talk],
    subtitle: [A subtitle],
    author: [Author],
    date: datetime.today(),
    institution: [University],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Animations

== Pause and Meanwhile

Use `#pause` to reveal content step by step.

#pause

This appears on the second subslide.

#meanwhile

This column starts over with `#meanwhile`.

#pause

And this on the second subslide of the right column.

= Theorems

== Euclid's Theorem

#theorem(title: "Euclid")[
  There are infinitely many primes.
]

#pause

#proof[
  Suppose finitely many primes $p_1, dots, p_n$. Then $p_1 dots p_n + 1$ has a prime factor not in the list — contradiction.
]

= Layout

== Two Columns

#slide(composer: (1fr, 1fr))[
  Left column content.

  - Point A
  - Point B
][
  Right column content.

  - Point C
  - Point D
]
```

## Choosing a Theme

Touying ships with six built-in themes:

| Theme | Style |
|-------|-------|
| `simple` | Clean, minimal |
| `metropolis` | Inspired by the popular Beamer Metropolis theme |
| `dewdrop` | Navigation-bar style |
| `university` | Academic with institution branding |
| `aqua` | Bright and modern |
| `stargazer` | Dark/colorful academic style |

Each theme is imported and activated the same way:

```typst
#import "@preview/touying:0.6.2": *
#import themes.metropolis: *   // ← change the theme name here

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [My Talk], author: [Me]),
)

#title-slide()
```

See the [Themes](./themes/) section for detailed documentation on each theme.

## What's Next?

Continue with the **[Tutorials](./tutorials/)** to learn:

- How to use headings, sections, and slide structure
- How to create animations with `#pause`, `#uncover`, `#only`, and more
- How to configure fonts, colors, and global settings
- How to use speaker notes and handout mode
- How to integrate third-party packages
- How to build your own custom theme
