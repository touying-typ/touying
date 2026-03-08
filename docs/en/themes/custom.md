---
sidebar_position: 7
---

# Custom Theme

If none of the built-in themes quite fits your needs, you have two options:

1. **Extend an existing theme** — copy a theme file locally and modify it.
2. **Build a new theme from scratch** — implement your own `xxx-theme` function.

Both approaches are described in detail in the [Build Your Own Theme](../tutorials/build-your-own-theme.md) tutorial.

## Quick Modifications

For minor adjustments to an existing theme, you do not need to create a separate theme file. You can override individual settings inline:

```example
#import "@preview/touying:0.6.2": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  // Override the primary color
  config-colors(primary: rgb("#1a6b8a")),
  // Change the footer content
  footer: self => self.info.author,
  config-info(
    title: [My Presentation],
    author: [Author Name],
    date: datetime.today(),
  ),
)

#title-slide()

= Section

== Slide

Content with the custom color.
```

## Copying a Theme Locally

To make deeper structural changes, copy the theme source file to your project:

1. Download the relevant file from `themes/` in the Touying repository (e.g., `themes/metropolis.typ`).
2. Change the import at the top from `#import "../src/exports.typ": *` to `#import "@preview/touying:0.6.2": *`.
3. Import the local copy instead of the built-in theme.

```typst
#import "@preview/touying:0.6.2": *
#import "metropolis.typ": *   // your local copy

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Title]),
)
```

You can now freely edit `metropolis.typ` without affecting other projects.
