---
sidebar_position: 4
---

# University Theme

![image](https://github.com/touying-typ/touying/assets/34951714/a9023bb3-0ef2-45eb-b23c-f94cc68a6fdd)

This theme is courtesy of [Pol Dellaiera](https://github.com/drupol).

## Initialization

You can initialize it with the following code:

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.university.register(s, aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)
#show: init
```

The `register` function takes the following parameters for initialization:

- `aspect-ratio`: Sets the aspect ratio of the slides to "16-9" or "4-3," with the default being "16-9."
- `progress-bar`: Determines whether to display the progress bar at the top of the slides, with the default value of `true`.

Additionally, the University theme provides an `#alert[..]` function that you can use with `#show strong: alert` using the `*alert text*` syntax.

## Color Themes

University theme defaults to using:

```typst
#let s = (s.methods.colors)(
  self: s,
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
  neutral-lightest: rgb("#FBFEF9"),
)
```

You can modify the color theme by using `#let s = (s.methods.colors)(self: s, ..)`.

## Slide Function Family

The University theme provides a series of custom slide functions:

```typst
#title-slide(logo: none, authors: none, ..args)
```

The `title-slide` reads information from `self.info` for display, and you can pass in the `logo` parameter and an array-type `authors` parameter.

---

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
  margin: (top: 2em, bottom: 1em, x: 0em),
  padding: (x: 2em, y: .5em),
)[
  ...
]
```
The default ordinary slide function with a title and footer, where `title` defaults to the current section title, and the footer is set by you.

---

```typst
#focus-slide(background-img: ..., background-color: ...)[
  ...
]
```
Used to capture the audience's attention, with the default background color being `self.colors.primary`.

---

```typst
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```
You can refer to the [documentation](https://polylux.dev/book/themes/gallery/university.html).

## `slides` Function

The `slides` function has the parameter:

- `title-slide`: Defaults to `true`.

You can set it using `#show: slides.with(..)`.

```typst
#import "@preview/touying:0.2.1": *

#let s = themes.university.register(s, aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)
#show: init

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
#import "@preview/touying:0.2.1": *

#let s = themes.university.register(s, aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slide, slides, title-slide, focus-slide, matrix-slide, touying-outline, alert) = utils.methods(s)
#show: init

#title-slide(authors: ("Author A", "Author B"))

#slide(title: [Slide title], section: [The section])[
  #lorem(40)
]

#slide(title: [Slide title], subtitle: emph[What is the problem?])[
  #lorem(40)
]

#focus-slide[
  *Another variant with an image in background...*
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

