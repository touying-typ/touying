---
sidebar_position: 6
---

# FAQ

Common questions and answers collected from GitHub issues, the Typst forum, and day-to-day usage.

## General

### What is Touying? How is it different from Polylux or Beamer?

Touying is a Typst presentation package similar to LaTeX Beamer.

- Compared to **Polylux** — Touying provides `#pause` and `#meanwhile` without relying on `counter` or `locate`, giving better compilation performance. Touying also offers global configuration via `config-*` functions, making theme creation easier.
- Compared to **Beamer** — Touying compiles in milliseconds instead of seconds, and the syntax is far more concise.
- Compared to **Markdown slides** — Touying (via Typst) has full typesetting control: custom headers, footers, layouts, math, code blocks, and more.

### Which Typst version does Touying require?

Touying 0.6.2 requires **Typst 0.12.0** or later (see `typst.toml`). Always use the matching version when compiling locally.

### How do I install Touying?

No installation needed! Just add the import at the top of your `.typ` file:

```typst
#import "@preview/touying:0.6.2": *
#import themes.simple: *
```

The Typst CLI or web app downloads the package automatically.

---

## Animations

### `#pause` creates an extra blank page — what's wrong?

This usually happens when `#pause` appears at the very end of a slide's content. The engine tries to split on the marker but finds nothing after it, generating an empty last subslide. Solution: remove the trailing `#pause`, or make sure there is content after every `#pause`.

### `#pause` doesn't work inside a `grid` or `table`

Touying supports `#pause` inside `grid` and `table`. Make sure you are on Touying 0.5.0 or later. If you still have trouble, switch to callback style:

```typst
#slide(repeat: 3, self => [
  #let (uncover,) = utils.methods(self)
  #grid(
    columns: 2,
    [Left],
    uncover("2-")[Right appears on slide 2],
  )
])
```

### `#meanwhile` doesn't work inside CeTZ

This was a bug fixed in v0.6.2. Update to the latest version:

```typst
#import "@preview/touying:0.6.2": *
```

### List/enum markers are still visible after `#pause`

The default `cover` function uses Typst's `hide`, which preserves text layout — including list markers. Enable the marker-hiding workaround:

```typst
config-common(show-hide-set-list-marker-none: true)
```

Or replace the cover function entirely:

```typst
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```

### How do I animate inside CeTZ / Fletcher?

Use the `touying-reducer` binding:

```typst
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)
```

Then use `(pause,)` tuples inside the drawing commands:

```typst
#cetz-canvas({
  import cetz.draw: *
  rect((0, 0), (5, 5))
  (pause,)
  circle((2.5, 2.5), radius: 1)
})
```

### How do I use `#only` and `#uncover` inside CeTZ?

You need callback style and must override the cover method:

```typst
#slide(repeat: 2, self => [
  #cetz.canvas({
    import cetz.draw: *
    let self = utils.merge-dicts(
      self,
      config-methods(cover: utils.method-wrapper(hide.with(bounds: true))),
    )
    let (uncover,) = utils.methods(self)
    rect((0, 0), (5, 5))
    uncover("2-", circle((2.5, 2.5), radius: 1))
  })
])
```

### Theorem numbers change between subslides

This is because Touying re-renders each subslide separately and theorem counters reset. Fix it with `frozen-counters`:

```typst
// For theorion package:
config-common(frozen-counters: (theorem-counter,))
```

### Can I make only one subslide appear in handout mode?

Yes:

```typst
config-common(handout: true, handout-subslides: 1)  // first subslide
config-common(handout: true, handout-subslides: (1, 3))  // subslides 1 and 3
```

---

## Layout and Styling

### How do I change the slide background color?

For all slides, use `config-page(fill: …)`:

```typst
#show: my-theme.with(
  config-page(fill: rgb("#1e1e2e")),
)
```

For a single slide:

```typst
#slide(config: config-page(fill: blue.lighten(80%)))[
  Blue background.
]
```

### How do I change the font?

Use standard Typst `set text` rules before or after the theme call:

```typst
#show: metropolis-theme.with(…)
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
```

Or use `config-methods(init: …)` to access theme colors:

```typst
config-methods(
  init: (self: none, body) => {
    set text(font: "Libertinus Serif", fill: self.colors.neutral-darkest)
    body
  },
)
```

### How do I center slide content vertically?

```typst
// For a single slide (metropolis theme has an `align` param):
#slide(align: center + horizon)[Centered content.]

// For all slides, use the init method:
config-methods(
  init: (self: none, body) => {
    show: std.align.with(center + horizon)
    body
  },
)

// Or globally:
#show: my-theme.with(…)
#set align(center + horizon)
```

### How do I remove the header/footer?

```typst
// Remove header only
config-page(header: none)

// Remove footer only
config-page(footer: none)

// For one slide
#slide(config: utils.merge-dicts(
  config-page(header: none, footer: none),
))[…]
```

### How do I hide the slide number on the title page?

Title slide functions in most themes set `freeze-slide-counter: true`, which means the title page doesn't count toward the slide number. The footer counter is typically not shown on special slides. If you're seeing it, check whether your custom footer accesses `utils.slide-counter.display()` and guard it:

```typst
footer: self => if not self.freeze-slide-counter {
  context utils.slide-counter.display() + " / " + utils.last-slide-number
}
```

### How do I make full-width headers/footers?

Most themes enable this automatically with `zero-margin-header: true`. If you're building a custom theme, add:

```typst
config-common(zero-margin-header: true, zero-margin-footer: true)
```

### How do I add columns to a slide?

```typst
#slide(composer: (1fr, 1fr))[Left][Right]
#slide(composer: (2fr, 1fr))[Wide left][Narrow right]
#slide(composer: (auto, 1fr))[Auto-width][Flexible]
```

### Content overflows off the slide — how do I fix it?

Options:
- Reduce font size: `set text(size: 18pt)` inside the slide.
- Use `utils.fit-to-width` or `utils.fit-to-height` to scale content.
- Split the slide across multiple pages with `---` or `#pagebreak()`.
- Adjust margins: `config-page(margin: (x: 1em, y: 1em))`.

### Relative sizes (e.g., `50%`) don't work inside animations

Typst relative lengths need a container to resolve against. Inside callback-style animations the layout context can be missing. Workaround: use `layout(size => …)` to get the available size:

```typst
#slide(repeat: 2, self => layout(size => [
  #let (uncover,) = utils.methods(self)
  #rect(width: size.width * 50%)
  #uncover(2)[More]
]))
```

---

## Themes

### How do I change the primary color of a theme?

```typst
#show: metropolis-theme.with(
  config-colors(primary: rgb("#005bac")),
)
```

### How do I add a logo to slides?

```typst
config-info(logo: image("logo.png", width: 2cm))
// or an emoji:
config-info(logo: emoji.school)
```

### How do I modify the header/footer of a built-in theme?

Pass your own content or function to the `header`/`footer` parameters:

```typst
#show: simple-theme.with(
  header: self => text(fill: blue)[My Custom Header],
  footer: self => [© 2025 My Company],
)
```

### How do I show the section and subsection in the header?

```typst
header: self => [
  #utils.display-current-heading(level: 1)   // section
  #h(1em) — #h(1em)
  #utils.display-current-heading(level: 2)   // subsection
]
```

### How do I use short section titles in navigation?

Add a label with the short title to the heading:

```typst
= A Very Long Section Title About Quantum Computing <sec:quantum>
```

Then reference the short form with `utils.short-heading`:

```typst
utils.short-heading(<sec:quantum>)
```

### The Dewdrop outline slide appears even when I didn't ask for it

This happens when `config-common(new-section-slide-fn: new-section-slide)` is the default. Disable it:

```typst
#show: dewdrop-theme.with(
  config-common(new-section-slide-fn: none),
)
```

Or skip a specific section's auto-slide:

```typst
= My Section <touying:skip>
```

### Slide titles in the University theme break when the bibliography has an empty title

Use a non-empty title or pass `title: none` to the bibliography:

```typst
#bibliography(title: [References], "refs.bib")
```

### Stargazer theme: what does `<touying:skip>` do?

`<touying:skip>` suppresses the automatic new-section slide that would be triggered by a first-level heading. Useful when you want a section heading in the outline without generating a dedicated section slide.

---

## Speaker Notes and Export

### How do I export speaker notes to pdfpc?

```sh
typst query --root . my-slides.typ --field value --one "<pdfpc-file>" > my-slides.pdfpc
```

Then open `my-slides.pdf` with `pdfpc --notes my-slides.pdfpc`.

### Pympress isn't displaying speaker notes correctly

Make sure you are using Touying 0.5.5 or later. If notes still don't show, check that `#speaker-note[…]` content is inside a `#slide[…]` block (not outside it).

### How do I show notes on a second screen?

```typst
config-common(show-notes-on-second-screen: right)
```

Supported values: `right`, `bottom`, `none`.

---

## Packages and Integration

### How do I use Codly with Touying?

Initialize Codly in `config-common(preamble: …)`:

```typst
#import "@preview/codly:1.0.0": *
#show: codly-init.with()

#show: my-theme.with(
  config-common(preamble: {
    codly(languages: (rust: (name: "Rust", color: rgb("#CE412B"))))
  }),
)
```

### How do I use Theorion theorems with `#pause`?

The theorem counter resets between subslides by default. Freeze it:

```typst
config-common(frozen-counters: (theorem-counter,))
```

### How do I use `#bibliography` in Touying?

A bug in Typst 0.14 broke bibliography in some contexts. Touying 0.6.2 includes a fix. Update your import version to `0.6.2`.

For footnote-style references:

```typst
config-common(
  bibliography-as-footnote: bibliography(title: none, "refs.bib"),
)
```

### How do I place an equation with `#pause` inside a slide?

Use `pause` (no `#`) inside the math block:

```typst
$
  f(x) &= pause x^2 + 1 \
       &= pause (x + 1)(x - 1) + 2
$
```

---

## Multi-File and Advanced

### How do I use Touying in a multi-file project?

Create a `globals.typ` that imports Touying and your theme, then import it in every file:

```typst
// globals.typ
#import "@preview/touying:0.6.2": *
#import themes.university: *
```

```typst
// main.typ
#import "/globals.typ": *
#show: university-theme.with(…)
#include "content.typ"
```

```typst
// content.typ
#import "/globals.typ": *

= Section
== Slide
Content.
```

### How do I stop the slide counter from increasing in the appendix?

Use `#show: appendix`:

```typst
#show: appendix

= Appendix

== Extra Slide

This won't affect the total count shown in the footer.
```

### Can I use `set` and `show` rules anywhere in a Touying document?

Yes, since Touying 0.5.0. Place `set` and `show` rules anywhere — before or after the theme `#show:` call, or inside slides. They will be scoped appropriately.

### How do I change how a specific slide function receives its body?

Use `config-common(receive-body-for-new-section-slide-fn: true)` if you want the section body (content after the heading, before the next heading) passed to `new-section-slide-fn`. This lets you do:

```typst
= Section Title
Speaker note only for this section slide. #speaker-note[Remind audience of X.]
---
Content starts here.
```
