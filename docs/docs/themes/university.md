---
sidebar_position: 4
---

# University Theme

![image](https://github.com/touying-typ/touying/assets/34951714/4095163c-0c16-4760-b370-8adc1cdd7e6c)

This aesthetically pleasing theme is courtesy of [Pol Dellaiera](https://github.com/drupol).

## Initialization

You can initialize the University theme using the following code:

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides
```

The `register` function accepts the following parameters:

- `aspect-ratio`: Sets the aspect ratio of the slides to "16-9" or "4-3," with the default being "16-9."
- `progress-bar`: Controls whether the progress bar at the top of each slide is displayed, with the default being `true`.

Additionally, the University theme provides an `#alert[..]` function, which you can use with the `#show strong: alert` syntax for emphasizing text with `*alert text*`.

## Color Theme

The University theme defaults to the following color theme:

```typst
#let store = (store.methods.colors)(
  self: store,
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
)
```

You can modify this color theme using `#let store = (store.methods.colors)(self: store, ..)`.

## Slide Function Family

The University theme provides a series of custom slide functions:

### Title Slide

```typst
#title-slide(logo: none, authors: none, ..args)
```

The `title-slide` function reads information from `self.info` for display. You can also pass the `logo` parameter and an array-type `authors` parameter.

### Regular Slide

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // university theme
  title: none,
  subtitle: none,
  header: none,
  footer: auto,
)[
  ...
]
```

The default slide function with a title and footer. The `title` defaults to the current section title, and the footer is set as per your configuration.

### Focus Slide

```typst
#focus-slide(background-img: ..., background-color: ...)[
  ...
]
```

Used to capture the audience's attention. The default background color is `self.colors.primary`.

### Matrix Slide

```typst
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```

Refer to the [documentation](https://polylux.dev/book/themes/gallery/university.html).

## `slides` Function

The `slides` function has parameters:

- `title-slide`: Defaults to `true`.
- `slide-level`: Defaults to `1`.

You can set these parameters using `#show: slides.with(..)`.

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/58971045-0b0d-46cb-acc2-caf766c2432d)


## Example

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides.with(title-slide: false)

#title-slide(authors: ([Author A], [Author B]))

= The Section

== Slide Title

#slide[
  #lorem(40)
]

#slide(subtitle: emph[What is the problem?])[
  #lorem(40)
]

#focus-slide[
  *Another variant with primary color in background...*
]

#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]

#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)
```

