---
sidebar_position: 5
---

# Aqua Theme

This theme is created by [@pride7](https://github.com/pride7), featuring beautiful backgrounds made with Typst's visualization capabilities.

## Initialization

You can initialize it with the following code:

```typst
#import "@preview/touying:0.7.4": *
#import themes.aqua: *

#show: aqua-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()
```

The `aqua-theme` function accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, which can be "16-9" or "4-3", with a default of "16-9".
- `header`: The content displayed in the header of the slides, with a default of `self => utils.display-current-heading(depth: self.slide-level)`. You can also provide a function like `self => self.info.title` to customize the header content.
- `footer`: The content displayed on the right side of the footer, with a default of `context utils.slide-counter.display()`.

Additionally, the Aqua theme provides a `#alert[..]` function, which you can use with the `#show strong: alert` syntax to emphasize text within your slides.

## Color Theme

The Aqua theme uses the following color scheme by default:

```typst
config-colors(
  primary: rgb("#003F88"),
  primary-light: rgb("#2159A5"),
  primary-lightest: rgb("#F2F4F8"),
  neutral-lightest: rgb("#FFFFFF"),
)
```

You can modify this color scheme using the `config-colors()` function to suit your preferences or to match the branding of your presentation.


## Slide Function Family

Aqua theme offers a series of custom slide functions:

```typst
#title-slide(config: (:), extra: none, ..args)
```

`title-slide` will read information from `self.info` for display. You can also pass an `extra` parameter to show additional information.

---

```typst
#outline-slide(config: (:), leading: 50pt)
```

Display an outline slide, where `leading` controls the spacing between the outline entries.

The outline slide places an invisible heading with `place(hide(heading(..)))`, so that both the slide header and the speaker-note panel can pick the title up through `utils.display-current-heading`.

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
)[
  ...
]
```

A default ordinary slide function with a header and a footer. The header content is decided by the theme's `header` parameter, and defaults to the heading of the current slide level.

---

```typst
#focus-slide[
  ...
]
```

Used to draw the audience's attention. The background color is `self.colors.primary`.

---

```typst
#new-section-slide(config: (:), level: 1, body)
```

Start a new section with the given title. It is already registered through `config-common(new-section-slide-fn: ..)`, so it is normally triggered by writing `= Title` and does not need to be called by hand.

## Speaker Notes

Aqua defines its own `notes` function and registers it with `config-common(notes-fn: notes)`, so the notes panel on a second screen and in the only-notes view follows the theme's colors. It is built on top of `touying-notes`, and you can override it with your own implementation:

```typst
#show: aqua-theme.with(
  config-common(notes-fn: my-notes),
)
```

See [Speaker Notes](../tutorials/speaker-notes.md) for details.


## Example

```example
#import "@preview/touying:0.7.4": *
#import themes.aqua: *

#show: aqua-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

#outline-slide()

= The Section

== Slide Title

#lorem(40)

#focus-slide[
  Another variant with primary color in background...
]

== Summary

#slide(self => [
  #align(center + horizon)[
    #set text(size: 3em, weight: "bold", fill: self.colors.primary)
    THANKS FOR ALL
  ]
])
```
