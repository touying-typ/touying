---
sidebar_position: 4
---

# Frequently Asked Questions

## Themes and Configuration

### How do I choose or switch themes?

Import a theme and apply it with `#show`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
= Section

== Slide

This uses the simple theme.
```

Available themes: `simple`, `default`, `metropolis`, `aqua`, `dewdrop`, `stargazer`, `university`.

### How do I customize theme colors?

Pass a `config-colors(...)` argument to your theme:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-colors(primary: rgb("#d94f00")),
  config-info(title: [Custom Color], author: [Author]),
)

= Section

== Slide

The header now uses the custom primary color.
```

---

## Layout and Columns

### How do I create a two-column layout?

Use `slide` with a `composer` argument to split content into columns:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide(composer: (1fr, 1fr))[
  == Left Column

  Some text on the left side.
][
  == Right Column

  Some text on the right side.
]
```

For unequal widths, adjust the fractions, e.g. `(2fr, 1fr)`.

### How do I place content at an absolute position?

Use Typst's `place` function for absolute positioning:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  Main slide content here.

  #place(bottom + right, dx: -1em, dy: -1em)[
    #rect(fill: blue.lighten(80%), inset: 0.5em)[Note]
  ]
]
```

### How do I fit content to fill the remaining slide height or width?

Use `utils.fit-to-height` or `utils.fit-to-width`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  #utils.fit-to-width(1fr)[
    == This heading fills the slide width
  ]

  Some content below.
]
```

---

## Table of Contents

### How do I display a table of contents?

Use `components.adaptive-columns` wrapping Typst's built-in `outline`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= First Section

== Introduction

Hello, Touying!

= Second Section

== Details

More content here.
```

The `<touying:hidden>` label hides the outline slide from the outline itself.

### How do I add numbering to sections in the outline?

Use the `numbly` package together with `#set heading(numbering: ...)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#import "@preview/numbly:0.1.0": numbly

#set heading(numbering: numbly("{1}.", default: "1.1"))

#show: simple-theme.with(aspect-ratio: "16-9")

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= First Section

== First Slide

= Second Section

== Second Slide
```

### How do I show a progressive/highlighted outline?

Use `components.progressive-outline` to highlight the current section:

```example
#import "@preview/touying:0.7.0": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= First Section

== Outline

#components.progressive-outline()

= Second Section

== Slide
```

---

## Bibliography and Citations

### How do I show citations as footnotes?

Pass a `bibliography(...)` value to `config-common(show-bibliography-as-footnote: ...)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#let bib = bytes(
  "@book{knuth,
    title={The Art of Computer Programming},
    author={Donald E. Knuth},
    year={1968},
    publisher={Addison-Wesley},
  }",
)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-bibliography-as-footnote: bibliography(bib)),
)

= Citations

== Footnote Example

This is a famous book. @knuth
```

### How do I add a bibliography slide at the end?

Use `magic.bibliography(...)` to display a references slide:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#let bib = bytes(
  "@book{knuth,
    title={The Art of Computer Programming},
    author={Donald E. Knuth},
    year={1968},
    publisher={Addison-Wesley},
  }",
)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-bibliography-as-footnote: bibliography(bib)),
)

= Intro

== Slide

Some cited content. @knuth

== References

#magic.bibliography(title: none)
```

---

## Speaker Notes

### How do I add speaker notes to a slide?

Use the `#speaker-note[...]` function anywhere in a slide:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  == My Slide

  Visible content here.

  #speaker-note[
    - Remind the audience of the previous topic.
    - Emphasize the key takeaway.
    - Time check: should be at 10 min mark.
  ]
]
```

Speaker notes do not appear in the slide output by default.

### How do I show speaker notes on a second screen?

Use `config-common(show-notes-on-second-screen: right)` to show notes beside the slides:

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(show-notes-on-second-screen: right),
)
```

This is compatible with presenter tools like [pdfpc](https://pdfpc.github.io/) and [pympress](https://github.com/Cimbali/pympress).

---

## Slide Numbering and Appendix

### How do I display slide numbers in the footer?

Use `utils.slide-counter.display()` for the current slide number and `utils.last-slide-number` for the total:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-page(
    footer: context [
      #utils.slide-counter.display() / #utils.last-slide-number
    ],
  ),
)

= Section

== First Slide

The footer shows the slide number.

== Second Slide

Still counting.
```

### How do I mark a slide as unnumbered?

Add the `<touying:unnumbered>` label to the heading:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
= Title Slide <touying:unnumbered>

== Welcome

This slide is not counted.

== Normal Slide

This slide is counted.
```

### How do I use an appendix so it doesn't affect the slide count?

Apply `#show: appendix` after your main content. Slides after this point do not increment the slide counter:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Main Content

== Introduction

This is slide 1.

== Results

This is slide 2.

#show: appendix

= Appendix

== Extra Material

This slide is in the appendix and does not increment the main counter.
```

---

## Animations and Dynamic Content

### How do I use `#pause` to reveal content step by step?

Place `#pause` between content blocks within a `#slide`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  First point.

  #pause

  Second point revealed on click.

  #pause

  Third point revealed on second click.
]
```

### How do I show content only on specific subslides?

Use `#only("...")` to show content on particular subslides, or `#uncover("...")` to show it while reserving its space:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  #only("1")[Shown on subslide 1 only.]
  #only("2-")[Shown from subslide 2 onward.]
  #uncover("3-")[Revealed on subslide 3, space reserved before.]
]
```

### Why doesn't `#pause` work inside a `context` expression?

`#pause` uses metadata injection that does not work inside `context { ... }` blocks. Use the callback-style `slide` instead to access `self.subslide`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide(self => {
  let (uncover, only) = utils.methods(self)
  [First content.]
  linebreak()
  uncover("2-")[Revealed on subslide 2.]
  linebreak()
  only("3")[Only on subslide 3.]
})
```

### How do I use `#pause` inside a CeTZ drawing?

Use `touying-reducer` to wrap CeTZ canvas so Touying can animate it:

```typst
#import "@preview/cetz:0.4.2"

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#slide[
  #cetz-canvas({
    import cetz.draw: *
    rect((0, 0), (4, 3))
    (pause,)
    circle((2, 1.5), radius: 1)
  })
]
```

### How do I use `#pause` inside a Fletcher diagram?

Use `touying-reducer` to wrap Fletcher diagrams:

```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#slide[
  #fletcher-diagram(
    node((0, 0), [A]),
    edge("->"),
    (pause,),
    node((1, 0), [B]),
  )
]
```

### How do I show alternative content across subslides?

Use `#alternatives` to swap between different content versions:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  The answer is: #alternatives[42][*forty-two*][_the ultimate answer_].
]
```

### How do I enable handout mode (no animations)?

Set `config-common(handout: true)` in your theme setup:

```typst
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: true),
)
```

In handout mode, only the final subslide of each slide is output.

---

## Fonts and Text

### How do I change the font for my presentation?

Use a `#set text(...)` rule before or after your theme setup:

```example
#import "@preview/touying:0.7.0": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Custom Font]),
)

#set text(font: "New Computer Modern", size: 22pt)

= Section

== Slide

Text now uses the custom font.
```

For math, also set the math font:

```typst
#show math.equation: set text(font: "New Computer Modern Math")
```

### How do I justify paragraph text?

Use `#set par(justify: true)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#set par(justify: true)

#slide[
  == Justified Text

  #lorem(40)
]
```

---

## Headings and Sections

### How do I disable automatic section slides?

Set `config-common(new-section-slide-fn: none)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
  config-info(title: [No Auto Sections]),
)

= Section

== Slide

No automatic section slide was created for the `= Section` heading.
```

### How do I write content for sections that have section slides?

Use `pagebreak()` or `---` to force a new page for that section and write there.

```example
>>>#import "@preview/touying:0.7.0": *
>>>#import themes.metropolis: *
>>>
>>>#show: metropolis-theme.with(
>>>  aspect-ratio: "16-9",
>>>  config-info(title: [content slides next to section slides]),
>>>)

= Section
---
Here is my content for this section.

== Slide
And this works normally.
```

You may also set `config-common(receive-body-for-new-section-slide-fn: false)`. This however will prevent you from writing speaker-notes for the section slide.

### How do I hide a slide from the presentation output entirely?

Add the `<touying:hidden>` label to the slide heading:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
== Visible Slide

This slide appears in the output.

== Hidden Slide <touying:hidden>

This slide is hidden and does not appear in the output or outline.

== Another Visible Slide

Back to normal.
```

### How do I exclude a slide from the outline but still show it?

Use the `<touying:unoutlined>` label:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Section

== Normal Slide

Appears in the outline.

== Interstitial Slide <touying:unoutlined>

This slide shows but is not listed in the outline.

== Another Normal Slide

Also appears in the outline.
```

### How do I control which heading level creates a new slide?

Use `config-common(slide-level: ...)`. The default varies by theme:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(slide-level: 2),
)

= Section

This text is part of the section slide.

== Subsection Slide

Each `==` heading creates a new slide.

=== Sub-subheading

Sub-subheadings do not create new slides.
```

### How do I add a custom header or footer?

Use `config-page(header: ..., footer: ...)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    header: text(gray)[My Custom Header],
    footer: context align(right, text(gray)[
      Slide #utils.slide-counter.display()
    ]),
  ),
)

= Section

== Slide

Slide with a custom header and footer.
```

---

## config-common Reference

### How do I prevent slide content from overflowing to the next page?

Use `config-common(breakable: false)` to prevent slide content from automatically overflowing to the next page. By default (`breakable: true`), content that exceeds the slide height creates new pages. When set to `false`, content is constrained to a single page using a non-breakable block, which is useful for ensuring a strict one-to-one mapping between source slides and output pages — especially in agentic workflows where an agent needs to reason about slide boundaries.

Related parameters:

- **`clip`** (default `false`): When `true`, content that exceeds the slide height is visually truncated.
- **`detect-overflow`** (default `true`): When `true`, a layout measurement is performed and `panic()` is called if the content height exceeds the available slide height, making it easy to catch overflow early. Set to `false` to avoid the extra layout overhead.

```typst
// Prevent overflow, panic on overflow (default behavior when breakable: false)
#show: simple-theme.with(
  config-common(breakable: false),
)

// Prevent overflow and visually clip overflowing content
#show: simple-theme.with(
  config-common(breakable: false, clip: true),
)

// Prevent overflow, disable overflow detection (performance-first)
#show: simple-theme.with(
  config-common(breakable: false, detect-overflow: false),
)
```

You can also switch these settings mid-presentation using `touying-set-config`:

```typst
== This slide's overflow will be clipped

// Enable clipping for a specific slide
#show: touying-set-config.with(config-common(clip: true))

#lorem(500)
```

### How do I use a semi-transparent cover instead of fully hiding content?

Use `config-methods(cover: utils.semi-transparent-cover)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-methods(cover: utils.semi-transparent-cover),
)

= Section

== Slide

#pause
This content is shown with a semi-transparent cover.
```

### How do I use preamble to insert content before every slide?

Use `config-common(preamble: ...)` and `subslide-preamble`:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(
    preamble: text(gray)[This appears before every slide],
    subslide-preamble: (2: [Special prelude for subslide 2]),
  ),
)

= Section

== Slide

Content here.

#pause

More content.
```

### How do I use `---` to separate slides?

Set `horizontal-line-to-pagebreak: true` (default) and use `---` to create page breaks:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(horizontal-line-to-pagebreak: true),
)

= First Section

== Slide One

Content here.

---

== Slide Two

Separated by horizontal rule.
```

---

## Testing and Development

### How do I run Touying's test suite?

Touying uses the [tytanic](https://github.com/Myriad-Dreamin/tytanic) test framework. Install it with:

```bash
cargo binstall tytanic
```

Run tests with:

```bash
tt run
```

Tests are organized in the `tests/` directory:

- `features/` — Feature tests for core functionality
- `themes/` — Theme-specific tests
- `integration/` — Third-party package integration tests (cetz, fletcher, pinit, theorion, codly, mitex)
- `issues/` — Regression tests for reported issues
- `examples/` — Example tests from the documentation

### How do I contribute to Touying?

To contribute to Touying:

1. Fork the repository on GitHub
2. Create a new branch for your changes
3. Make your changes following the existing code style
4. Format your code with [typstyle](https://github.com/Myriad-Dreamin/typstyle)
5. Run `tt run` to ensure all tests pass
6. Submit a pull request with a clear description of your changes

---

## Miscellaneous

### How do I set the presentation title, author, and date?

Use `config-info(...)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [My Presentation],
    subtitle: [A Subtitle],
    author: [Jane Doe],
    date: datetime.today(),
    institution: [My University],
  ),
)

#title-slide()

= Introduction

== First Slide

Content here.
```

### How do I override the config for a single slide?

Use `touying-set-config` around the content you want to change:

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *
#show: simple-theme
#slide[
  Normal slide.
]

#touying-set-config(config-page(fill: rgb("#fff3cd")))[
  #slide[
    This slide has a yellow background.
  ]
]

#slide[
  Back to normal.
]
```

### How do I create a multi-file presentation?

Import `lib.typ` from the main entry file and use `include` for sections:

```typst
// main.typ
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

#include "intro.typ"
#include "methods.typ"
#include "results.typ"
```

Each included file uses headings normally — no extra imports needed in each file.

### How do I display the current section name in the header or footer?

Use `utils.display-current-heading(...)` or `utils.display-current-short-heading(...)`:

```example
#import "@preview/touying:0.7.0": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    header: context text(gray)[
      #utils.display-current-heading(level: 1)
    ],
  ),
)

= My Section

== Slide

The header shows the current section name.
```

### How do I use Touying with the `pinit` package for pin annotations?

Import both packages and use `#pin`/`#pinit-highlight` inside slides as normal:

```typst
#import "@preview/touying:0.7.0": *
#import "@preview/pinit:0.2.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

#slide[
  A #pin(1)key term#pin(2) to highlight.

  #pinit-highlight(1, 2)
]
```

For animated pin reveals, use the callback-style slide so `#pause` interacts correctly with pinit.

### How do I freeze counters (figures, equations) across subslides?

Use `config-common(frozen-counters: true)` to prevent counters from advancing between subslides:

```typst
#show: simple-theme.with(
  config-common(frozen-counters: true),
)
```
