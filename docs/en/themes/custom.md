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
#import "@preview/touying:0.7.4": *
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
2. Change the import at the top from `#import "../src/exports.typ": *` to `#import "@preview/touying:0.7.4": *`.
3. Import the local copy instead of the built-in theme.

```typst
#import "@preview/touying:0.7.4": *
#import "metropolis.typ": *   // your local copy

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Title]),
)
```

You can now freely edit `metropolis.typ` without affecting other projects.


## Customizing the Speaker-Note Panel

A theme decides not only what the slides look like, but also what the [speaker-note](../tutorials/speaker-notes.md) panel looks like — both the second screen and the only-notes view are drawn by the function given to `config-common(notes-fn: ..)`. Since Touying 0.8.0 every bundled theme writes its own `notes` function and registers it, so the notes panel matches the rest of the theme.

When you write one yourself, build it on top of `touying-notes`, which handles the layout and leaves the styling to you:

- `header`: The strip at the top of the panel. It sizes to its content, and passing `none` drops it entirely.
- `header-fill`: The fill behind the strip — a color, but also a `rect` or an `image`.
- `fill`: The fill behind the rest of the panel.
- `note-setting`: A setting function applied to the note body, the panel's main content.
- `preview-setting`: A setting function applied to the shrunken slide preview shown in `show-only-notes` mode.

The notes panel does not use `config-page(..)`: pass backgrounds to `fill` and `header-fill` directly.

For a fuller walkthrough, see [Build Your Own Theme · Customizing the Notes](../tutorials/build-your-own-theme.md#customizing-the-notes).

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let my-notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(1em, text(
    fill: self.colors.neutral-lightest,
    utils.display-current-heading(depth: self.slide-level),
  )),
  header-fill: self.colors.primary,
  fill: self.colors.neutral-lightest,
  note-setting: note => pad(1.5em, text(size: .8em, note)),
  ..args,
)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-common(notes-fn: my-notes, show-notes-on-second-screen: right),
  config-info(title: [My Presentation]),
)

== Slide

Content.

#speaker-note[Remember to slow down here.]
```

## Making a Special Slide's Title Discoverable

The titles in both the slide header and the notes panel are read from the current heading through `utils.display-current-heading`. Special slides such as a title slide, an outline slide or an ending slide often have no real heading, so their title simply "disappears".

What the bundled themes do is place a hidden heading on such slides:

```typst
place(hide(heading(
  level: self.slide-level,
  title,
  bookmarked: false,
  outlined: false,
  numbering: none,
)))
```

`hide` makes it invisible, `place` keeps it from taking up any layout space, and `outlined: false` together with `bookmarked: false` keeps it out of the outline and the PDF bookmarks — but `utils.display-current-heading` still finds it. The `outline-slide` of aqua, dewdrop, metropolis and stargazer, as well as stargazer's `ending-slide`, all use this pattern.

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#let thanks-slide(config: (:), title: [Thanks!]) = touying-slide-wrapper(self => {
  let body = {
    place(hide(heading(
      level: self.slide-level,
      title,
      bookmarked: false,
      outlined: false,
      numbering: none,
    )))
    align(center + horizon, text(2em, weight: "bold", title))
  }
  touying-slide(self: self, config: config, body)
})

#show: simple-theme.with(aspect-ratio: "16-9")

== A Slide

Content.

#thanks-slide()
```

## Helper Functions That Need Access to `self`

Helper components inside a theme — stargazer's `tblock`, for example — often need to read `self.colors`. Prefer `touying-fn-wrapper-raw` for this: like `#alert`, it expands in place and does not break up the animation structure of `#pause` / `#uncover`, so the component you wrap can take part in animations normally.

The first parameter of the callback must be written as `(self: none) => ..`:

```typst
#let _tblock(self: none, title: none, it) = { /* .. */ }

#let tblock(title: none, it) = touying-fn-wrapper-raw(
  _tblock.with(title: title, it),
)
```
