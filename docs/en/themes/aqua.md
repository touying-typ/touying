---
sidebar_position: 5
---

# Aqua Theme

This theme is created by [@pride7](https://github.com/pride7), featuring beautiful backgrounds made with Typst's visualization capabilities.

## Initialization

You can initialize it with the following code:

```typst
#import "@preview/touying:0.7.1": *
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

The `register` function in the Aqua theme accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, which can be "16-9" or "4-3", with a default of "16-9".
- `header`: The content displayed in the header of the slides, with a default of `utils.display-current-heading()`. You can also provide a function like `self => self.info.title` to customize the header content.
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
#title-slide(..args)
```

`title-slide` will read information from `self.info` for display.

---

```typst
#let outline-slide(self: none, enum-args: (:), leading: 50pt)
```

Display an outline slide.

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: cols,
  // Aqua theme
  title: auto,
)[
  ...
]
```

A default ordinary slide function with title and footer, where `title` defaults to the current section title.

---

```typst
#focus-slide[
  ...
]
```

Used to draw the audience's attention. The background color is `self.colors.primary`.

---

```typst
#new-section-slide(title)
```

Start a new section with the given title.


## Example

```example
#import "@preview/touying:0.7.1": *
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