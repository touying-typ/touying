---
sidebar_position: 1
---

# Slide Structure

In Touying, you build presentations the same way you write any Typst document — using headings, text, and function calls. This tutorial explains how headings create slides, the two coding styles you can choose from, and how to control pagination and sectioning.

## Headings Create Slides

Touying automatically converts Typst headings into slides. The depth at which a heading triggers a new slide depends on the theme's `slide-level` setting.

Most themes use `slide-level: 2` by default, meaning:

| Heading level | Role |
|--------------|------|
| `= …` | Creates a new **section slide** |
| `== …` | Creates a new **content slide** |
| `=== …` | Creates a **sub-title** inside the current slide |

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Section One

== First Slide

Hello, Touying!

== Second Slide

Hello again!
```

Some themes (like Dewdrop) use three heading levels. You can always override this with:

```typst
#show: some-theme.with(config-common(slide-level: 3))
```

## Simple Style vs Block Style

Touying supports two ways to write slide content.

### Simple Style

Write content directly under a heading. `#pause` and other animation markers work anywhere in the content flow:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== Slide

First line.

#pause

Second line, revealed later.
```

### Block Style

Wrap slide content in `#slide[…]`. This gives access to extra parameters and special slide types:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== Slide

#slide[
  First line.

  #pause

  Second line, revealed later.
]
```

**Why use block style?**

1. Access theme-specific slide functions like `#focus-slide`, `#title-slide`, `#centered-slide`.
2. Use extra parameters (`composer`, `repeat`, `config`, …).
3. Write callback-style animation with `self => …` (required for `#only` and `#uncover`).
4. Makes paginations explicit and easy to read.

## Splitting Pages with `---`

Within simple style, use `---` on its own line to insert a `#pagebreak()` and start a new slide while keeping the current heading active:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== Long Slide

First page of this slide.

---

Second page of this slide (same heading).
```

## Empty Slides

`#empty-slide[]` creates a slide with no header or footer — useful for full-screen images or blank interludes:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== Normal Slide

Regular content.

#empty-slide[
  #align(center + horizon)[
    #text(size: 2em)[Full-screen interlude]
  ]
]
```

## Special Heading Labels

You can attach special labels to headings to control how they behave:

| Label | Effect |
|-------|--------|
| `<touying:hidden>` | Slide is completely invisible (not rendered) |
| `<touying:skip>` | Skip the automatic section slide for this heading |
| `<touying:unnumbered>` | Omit from slide numbering |
| `<touying:unoutlined>` | Exclude from `outline()` |
| `<touying:unbookmarked>` | No PDF bookmark |
| `<touying:handout>` | Only shown in handout mode |

Example — a hidden outline slide so the outline doesn't count as a numbered slide:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))
#show: simple-theme.with(aspect-ratio: "16-9")

= Introduction

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

== Motivation

Some motivating content.
```

## Sections and Navigation

### Slide Level

The `slide-level` config controls how many heading levels create new slides:

```typst
// All three heading levels create slides
#show: my-theme.with(config-common(slide-level: 3))
```

### Table of Contents

Display a table of contents using native Typst `outline()`. Wrap it in `components.adaptive-columns` to avoid overflow on long outlines:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))
#show: simple-theme.with(aspect-ratio: "16-9")

= First Section

== Outline <touying:hidden>

#components.adaptive-columns(outline(indent: 1em))

== First Slide

Some content.

= Second Section

== Another Slide

More content.
```

### Progressive Outline

Some themes support a progressive outline that highlights the current section:

```typst
// Available in themes that support it (e.g., dewdrop)
#components.progressive-outline()

// Customisable variant
#components.custom-progressive-outline(
  alpha: 60%,
  level: 2,
)
```

### Heading Numbering

Add numbering to headings with the standard Typst `set heading` rule. The `numbly` package makes mixed-format numbering easy:

```typst
#import "@preview/numbly:0.1.0": numbly
#set heading(numbering: numbly("{1}.", default: "1.1"))
```

This renders first-level headings as `1.`, `2.`, … and nested headings as `1.1`, `1.2`, …

## Disabling Auto Section Slides

By default many themes call a `new-section-slide-fn` when a first-level heading is encountered, creating a dedicated section title slide. To disable this:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
)

= Section (no auto slide)

== First Slide

Content.
```

To register a custom section slide function:

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: section => {
    touying-slide-wrapper(self => {
      touying-slide(
        self: self,
        {
          set align(center + horizon)
          set text(size: 2em, fill: self.colors.primary, style: "italic", weight: "bold")
          utils.display-current-heading(level: 1)
        },
      )
    })
  }),
)

= Custom Section

== First Slide

Content.
```

## Appendix

Mark the beginning of an appendix with `#show: appendix`. This freezes the slide counter so appendix slides don't inflate the total count shown in footers:

```typst
#show: appendix

= Appendix

== Extra Material

These slides won't affect the "X / Y" slide counter.
```
