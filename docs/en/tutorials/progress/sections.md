---
sidebar_position: 2
---

# Section Utilities

Touying injects invisible headings into each slide so that you can query the current section at any time using Typst's `query()` function.

## Displaying the Current Heading

`utils.display-current-heading(level: N)` returns the text of the most recent heading at the given level. It is used by most themes to populate the header:

```typst
// Show the current section (level 1) in the header
utils.display-current-heading(level: 1)

// Show the current subsection (level 2)
utils.display-current-heading(level: 2)
```

`utils.display-current-short-heading(level: N)` is a shorter variant that strips numbering:

```typst
utils.display-current-short-heading(level: 2)
```

## Custom Header with Section Name

You can use these utilities in a custom header:

```example
#import "@preview/touying:0.7.0": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    header: [
      #text(gray, utils.display-current-heading(level: 2))
      #h(1fr)
      #context utils.slide-counter.display()
    ],
  ),
)

= My Section

== First Slide

Header shows "First Slide" on the right side.

== Second Slide

Header updates automatically.
```

## Progressive Outline

`components.progressive-outline()` renders an outline that highlights the current section and grays out the rest — a common pattern in themed presentations:

```example
#import "@preview/touying:0.7.0": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Introduction

== Overview <touying:hidden>

#components.progressive-outline()

= Background

== Slide

Content.
```

`components.adaptive-columns(outline(...))` is another variant that wraps a standard `outline()` in an appropriate number of columns so it fits on one page.
