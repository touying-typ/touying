---
sidebar_position: 1
---

# Simple Theme

This theme originates from [Polylux](https://polylux.dev/book/themes/gallery/simple.html), created by Andreas Kröpelin.

Considered a relatively straightforward theme, you can use it to create simple slides and freely incorporate features you like.

## Initialization

You can initialize it using the following code:

```typst
#import "@preview/touying:0.7.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)
```

The `register` function in the theme accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, which can be "16-9" or "4-3", with a default of "16-9".
- `header`: The content displayed in the header, with a default of `utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%))`. You can also pass a function like `self => self.info.title`.
- `header-right`: The content displayed on the right side of the header, with a default of `self => self.info.logo`.
- `footer`: The content displayed in the footer, with a default of `[]` (empty). You can also pass a function like `self => self.info.author`.
- `footer-right`: The content displayed on the right side of the footer, with a default of `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
- `primary`: The primary color of the theme, with a default of `aqua.darken(50%)`.
- `subslide-preamble`: By default, it adds the subsection title to the current slide.


## Slide Function Family

The Simple theme provides a variety of custom slide functions:

```typst
#centered-slide(section: ..)[
  ...
]
```

A slide with content centered, and the `section` parameter can be used to create a new section.

---

```typst
#title-slide[
  ...
]
```

Similar to `centered-slide`, this is provided for consistency with Polylux syntax.

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: cols,
)[
  ...
]
```

A default slide with headers and footers, where the header corresponds to the current section, and the footer is what you set.

---

```typst
#focus-slide(foreground: ..., background: ...)[
  ...
]
```

Used to draw attention, it optionally accepts a foreground color (defaulting to `white`) and a background color (defaulting to `auto`, i.e., `self.colors.primary`).


## Example

```example
#import "@preview/touying:0.7.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

== First slide

#lorem(20)

#focus-slide[
  _Focus!_

  This is very important.
]

= Let's start a new section!

== Dynamic slide

Did you know that...

#pause

...you can see the current section at the top of the slide?
```

