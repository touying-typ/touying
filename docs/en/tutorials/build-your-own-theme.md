---
sidebar_position: 7
---

# Build Your Own Theme

Touying's architecture makes it straightforward to create reusable, configurable themes. This tutorial builds a complete "Bamboo" theme from scratch and explains every step. You can use it as a template for your own theme.

## Theme Architecture

A Touying theme is a normal Typst file that:

1. Imports Touying's public API.
2. Defines slide functions (`slide`, `title-slide`, `focus-slide`, …).
3. Exposes a single `xxx-theme` function that users call with `#show: xxx-theme.with(…)`.

The `xxx-theme` function internally calls `touying-slides.with(…)` to register all configuration.

## Modifying an Existing Theme

The quickest way to get a custom look is to copy an existing theme and tweak it:

1. Copy the relevant file from the [themes directory](https://github.com/touying-typ/touying/tree/main/themes) — for example `themes/university.typ` — to your project as `university.typ`.
2. Change the first import from `#import "../src/exports.typ": *` to `#import "@preview/touying:0.6.2": *`.
3. Import your local copy instead of the built-in theme:

```typst
#import "@preview/touying:0.6.2": *
#import "university.typ": *

#show: university-theme.with(…)
```

## Building the Bamboo Theme

### File Setup

```typst
// bamboo.typ
#import "@preview/touying:0.6.2": *
```

If you want the theme to ship inside the Touying repository (e.g., as a contribution), change the import to:

```typst
#import "../src/exports.typ": *
```

And add a line in `themes/themes.typ`:

```typst
#import "bamboo.typ"
```

### Step 1 — The `slide` Function

Every theme needs a default `slide` function. It wraps `touying-slide-wrapper` so Touying can inject `self` automatically:

```typst
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // Build header and footer using self.store and self.colors
  let header(self) = align(top + left,
    pad(x: 1em, y: 0.5em,
      text(fill: self.colors.neutral-darkest, weight: "bold",
        utils.display-current-heading(depth: self.slide-level),
      )
    )
  )
  let footer(self) = align(bottom,
    pad(x: 1em, y: 0.5em,
      grid(
        columns: (1fr, auto),
        utils.call-or-display(self, self.store.footer),
        context utils.slide-counter.display() + " / " + utils.last-slide-number,
      )
    )
  )
  let self = utils.merge-dicts(
    self,
    config-page(header: header, footer: footer),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})
```

### Step 2 — Special Slide Functions

```typst
/// Title slide. Freezes slide counter so it doesn't count.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary),
    config,
  )
  let info = self.info + args.named()
  touying-slide(self: self,
    align(center + horizon,
      text(fill: white, {
        text(size: 1.5em, weight: "bold", info.title)
        if info.subtitle != none { linebreak(); text(0.9em, info.subtitle) }
        v(1em)
        text(0.8em, info.author)
      })
    )
  )
})

/// Focus slide with contrasting background.
#let focus-slide(config: (:), background: auto, foreground: white, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: if background == auto { self.colors.primary } else { background }),
    config,
  )
  set text(fill: foreground, size: 1.5em)
  touying-slide(self: self, align(center + horizon, body))
})
```

### Step 3 — The Theme Registration Function

The `bamboo-theme` function is what users call. It uses `touying-slides.with(…)` to merge all configuration and then applies the Typst show rule:

```typst
/// Bamboo theme.
///
/// - aspect-ratio (string): `"16-9"` or `"4-3"`. Default is `"16-9"`.
/// - footer (content, function): Footer content.
/// - primary (color): Primary accent color.
#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  primary: rgb("#5c7a4e"),
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (top: 3em, bottom: 2em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, fill: self.colors.neutral-darkest)
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: primary,
      neutral-lightest: rgb("#fafafa"),
      neutral-darkest: rgb("#1a1a1a"),
    ),
    config-store(footer: footer),
    ..args,
  )
  body
}
```

### Step 4 — Testing the Theme

```example
// bamboo.typ is shown above — paste it into the example or import it

#import "@preview/touying:0.6.2": *
#import themes.simple: *   // using simple as a stand-in; replace with bamboo

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Bamboo Conf 2025],
  config-info(title: [Bamboo Theme Demo], author: [Your Name]),
)

#title-slide[= Bamboo Theme Demo]

= Section One

== First Slide

This is a content slide.

#pause

Revealed on the second subslide.

#focus-slide[
  Focus on the key idea.
]
```

## Key Concepts

### `config-store`

Themes often need to store user-supplied values (like `footer`) for later use inside slide functions. `config-store(key: value, …)` saves arbitrary values; access them as `self.store.key`:

```typst
config-store(footer: footer)
// later inside a slide function:
utils.call-or-display(self, self.store.footer)
```

### `utils.call-or-display`

Accepts either a static value or a function `self => content`. This lets users pass either a string/content or a dynamic function:

```typst
// Static
footer: [My Conference]

// Dynamic (access current slide info)
footer: self => self.info.institution
```

### `utils.display-current-heading`

Returns the current heading content, useful for dynamic headers:

```typst
utils.display-current-heading(level: 1)         // section heading
utils.display-current-heading(depth: self.slide-level) // nearest heading
```

### Slide Counter

```typst
context utils.slide-counter.display()  // current slide number
utils.last-slide-number                // total slide count
```

### Progress Bar

```typst
components.progress-bar(
  height: 3pt,
  self.colors.primary,
  self.colors.primary.lighten(60%),
)
```

### Navigation Mini-Slides

```typst
components.mini-slides(
  display-section: true,
  display-subsection: false,
)
```

## Adding Document Comments

Touying themes use `///` docstrings so Tinymist can display inline help. Follow this pattern for every exported function:

```typst
/// Default slide function.
///
/// Example:
/// ```typst
/// #slide[Content]
/// ```
///
/// - config (dictionary): Per-slide configuration.
/// - repeat (int, auto): Number of subslides. Use `auto` normally.
/// - composer (function, array): Column layout.
/// - bodies (array): Slide content blocks.
#let slide(config: (:), repeat: auto, composer: auto, ..bodies) = …
```

## Contributing a Theme to Touying

If you'd like your theme included in Touying:

1. Place it in `themes/your-theme.typ`.
2. Add `#import "your-theme.typ"` in `themes/themes.typ`.
3. Change the import at the top to `#import "../src/exports.typ": *`.
4. Add a test under `tests/themes/your-theme/`.
5. Add documentation under `docs/en/themes/your-theme.md` (and the Chinese translation).
6. Open a pull request on GitHub.
