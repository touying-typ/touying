---
sidebar_position: 2
---

# Sections and Subsections

## Structure

Like Beamer, Touying also has the concept of sections and subsections.

Generally, first-level, second-level, and third-level headings correspond to sections, subsections, and subsubsections, respectively, such as in the dewdrop theme.

```example
#import "@preview/touying:0.6.3": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Section

== Subsection

=== Title

Hello, Touying!
```

However, there are many times when we do not need subsections, so we also use first-level and second-level headings to correspond to sections and titles, respectively, such as in the university theme.

```example
#import "@preview/touying:0.6.3": *
#import themes.university: *

#show: university-theme.with(aspect-ratio: "16-9")

= Section

== Title

Hello, Touying!
```

In fact, we can control this behavior through the `slide-level` parameter of the `config-common` function. `slide-level` represents the complexity of the nesting structure, starting from 0. For example, `#show: university-theme.with(config-common(slide-level: 2))` is equivalent to both `section` and `subsection` creating new slides; while `#show: university-theme.with(config-common(slide-level: 3))` is equivalent to `section`, `subsection`, and `subsubsection` all creating new slides.

## Numbering

To add numbering to sections and subsections, we simply use

```typst
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")
```

This sets the default numbering to `1.1`, and the section corresponds to the numbering `1.`.

## Table of Contents

Displaying a table of contents in Touying is straightforward:

```example
#import "@preview/touying:0.6.3": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: simple-theme.with(aspect-ratio: "16-9")

= Section

== Subsection

#components.adaptive-columns(outline(indent: 1em))
```

The `outline(indent: 1em)` is a native Typst function for the table of contents. The `#components.adaptive-columns()` function ensures that the table of contents occupies only one page, adapting by setting `#columns(1, body)` or `#columns(2, body)`, and so on.

If you need a `outline` function that can display the current progress, you might consider using `#components.progressive-outline()` or `#components.custom-progressive-outline()`, as seen in the dewdrop theme.

## Special Heading Labels

Touying recognises special labels on headings to control slide behavior:

| Label | Effect |
|-------|--------|
| `<touying:hidden>` | The slide is not rendered at all (content and page are suppressed). |
| `<touying:skip>` | The heading does not create a new-section slide. |
| `<touying:unnumbered>` | The slide is not counted in the slide counter. |
| `<touying:unoutlined>` | The heading is excluded from the `outline()`. |
| `<touying:unbookmarked>` | No PDF bookmark is generated for this heading. |
| `<touying:handout>` | The slide is shown only in handout mode. |

Example — a hidden outline slide that does not appear in the final PDF:

```example
#import "@preview/touying:0.6.3": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: simple-theme.with(aspect-ratio: "16-9")

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= First Section

== Slide One

Content.
```

## Appendix

The `appendix` function stops the slide counter so appendix slides do not affect the total count displayed in the footer.

```example
#import "@preview/touying:0.6.3": *
#import themes.simple: *

#show: simple-theme

= Main Section

== Introduction

Main content here. Check the slide number in the footer.

#show: appendix

= Appendix

== Appendix Slide

The slide number is frozen at the last main-section slide.
```
