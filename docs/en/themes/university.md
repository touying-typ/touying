---
sidebar_position: 4
---

# University Theme

This aesthetically pleasing theme is courtesy of [Pol Dellaiera](https://github.com/drupol).

## Initialization

You can initialize the theme with the following code:

```typst
#import "@preview/touying:0.7.4": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
```

The `university-theme` function accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3", with a default of "16-9".
- `align`: The alignment of the slides, with a default of `top`.
- `progress-bar`: Whether to display a progress bar at the top of the slide, with a default of `true`.
- `header`: The content displayed in the header, with a default of `utils.display-current-heading(level: 2, style: auto)`, or you can pass a function like `self => self.info.title`.
- `header-right`: The content displayed on the right side of the header, with a default of `self => box(utils.display-current-heading(level: 1)) + h(.3em) + self.info.logo`, i.e. the current level-1 heading followed by the logo.
- `footer-columns`: The widths of the three columns in the footer, with a default of `(25%, 1fr, 25%)`.
- `footer-a`: The first column, with a default of `self => self.info.author`.
- `footer-b`: The second column, with a default of `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
- `footer-c`: The third column, with a default of

```typst
self => {
  h(1fr)
  utils.display-info-date(self)
  h(1fr)
  context utils.slide-counter.display() + " / " + utils.last-slide-number
  h(1fr)
}
```

## Color Theme

The University theme uses the following color scheme by default:

```typc
config-colors(
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

You can modify this color scheme using `config-colors()`.

## Slide Function Family

The University theme provides a series of custom slide functions:

```typst
#title-slide(config: (:), extra: none, ..args)
```

The `title-slide` function reads information from `self.info` for display, and you can also pass an `extra` parameter to show additional information. Named arguments in `..args` override the fields of the same name in `self.info`, so you can also pass a `logo` or an array-typed `authors` directly.

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
)[
  ...
]
```

A standard slide function with a header and a footer. `#slide` itself has no `title` parameter: the header is decided by the theme's `header` parameter, and shows the current level-2 heading by default. `align` defaults to `auto`, meaning it follows the theme's `align` parameter (`top` by default).

---

```typst
#new-section-slide(config: (:), level: 1, numbered: true, body)
```

Start a new section with the given title. It is already registered through `config-common(new-section-slide-fn: ..)`, so it is normally triggered by writing `= Title` and does not need to be called by hand.

### Focus Slide

```typst
#focus-slide(background-img: ..., background-color: ...)[
  ...
]
```

Used to capture the audience's attention. `background-color` and `background-img` both default to `none`, in which case the background color is `self.colors.primary`.

### Matrix Slide

```typst
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```

Refer to the [documentation](https://polylux.dev/book/themes/gallery/university.html).

## Speaker Notes

University defines its own `notes` function and registers it with `config-common(notes-fn: notes)`, so the notes panel on a second screen and in the only-notes view follows the theme's colors. It is built on top of `touying-notes`, and you can override it with your own implementation:

```typst
#show: university-theme.with(
  config-common(notes-fn: my-notes),
)
```

See [Speaker Notes](../tutorials/speaker-notes.md) for details.

## Example

```example
#import "@preview/touying:0.7.4": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide(authors: ([Author A], [Author B]))

= The Section

== Slide Title

#lorem(40)

#focus-slide[
  Another variant with primary color in background...
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
