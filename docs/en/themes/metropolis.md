---
sidebar_position: 2
---

# Metropolis Theme

This theme draws inspiration from Matthias Vogelgesang's [Metropolis beamer](https://github.com/matze/mtheme) theme and has been modified by [Enivex](https://github.com/Enivex).

The Metropolis theme is elegant and suitable for everyday use. It is recommended to have Fira Sans and Fira Math fonts installed on your computer for the best results.

## Initialization

You can initialize it using the following code:

```typst
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#import "@preview/numbly:0.1.0": numbly

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.city,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
```

The `metropolis-theme` function accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, which can be "16-9" or "4-3", with a default of "16-9".
- `align`: The alignment of the content within the slides, with a default of `horizon`.
- `header`: The content displayed in the header of the slides, with a default of `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`, which displays the current heading fitted to the width. Alternatively, you can provide a function like `self => self.info.title` to customize the header content.
- `header-right`: The content displayed on the right side of the header, with a default of `self => self.info.logo`.
- `footer`: The content displayed in the footer of the slides, with a default of `none`. You can customize it with a function, for example, to display the author's information: `self => self.info.author`.
- `footer-right`: The content displayed on the right side of the footer, with a default that shows the slide number and the total number of slides (`context utils.slide-counter.display() + " / " + utils.last-slide-number`).
- `footer-progress`: A boolean value indicating whether to display a progress bar at the bottom of the slides, with a default of `true`.

Additionally, the Metropolis theme provides a `#alert[..]` function, which you can use with the `#show strong: alert` syntax to emphasize text within your slides.


## Color Theme

Metropolis uses the following default color theme:

```typc
config-colors(
  primary: rgb("#eb811b"),
  primary-light: rgb("#d6c6b7"),
  secondary: rgb("#23373b"),
  neutral-lightest: rgb("#fafafa"),
  neutral-dark: rgb("#23373b"),
  neutral-darkest: rgb("#23373b"),
)
```

You can modify this color theme using `config-colors()`.

## Slide Function Family

The Metropolis theme provides a variety of custom slide functions:

```typst
#title-slide(config: (:), extra: none, ..args)
```

`title-slide` reads information from `self.info` for display, and you can also pass in an `extra` parameter to display additional information.

---

```typst
#slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
)[
  ...
]
```

A default slide with a header and a footer. `title` defaults to `auto`, meaning it displays the heading of the current slide level; `align` defaults to `auto`, meaning it follows the theme's `align` parameter (`horizon` by default). The footer can only be set at the theme level through the `footer` / `footer-right` parameters — `#slide` itself has no `footer` parameter.

---

```typst
#outline-slide(
  config: (:),
  level: auto,
  title: [Outline],
  spacing: 2em,
  ..args,
)
```

Display an outline slide. `level` defaults to `auto`, which uses the slide level configured in `config-common`; `..args` are forwarded to [`components.custom-progressive-outline`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline), where `indent`, `vspace`, `numbered` and `numbering` already have defaults matching the Metropolis style.

The outline slide places an invisible heading with `place(hide(heading(..)))`, so that both the slide header and the speaker-note panel can pick the title up through `utils.display-current-heading`.

---

```typst
#focus-slide[
  ...
]
```

Used to draw attention, with the background color set to `self.colors.neutral-dark` (Metropolis does not define a `primary-dark`).

---

```typst
#new-section-slide(config: (:), level: 1, numbered: true, body)
```

Creates a new section with the given title. It is already registered through `config-common(new-section-slide-fn: ..)`, so it is normally triggered by writing `= Title` and does not need to be called by hand.

## Speaker Notes

Metropolis defines its own `notes` function and registers it with `config-common(notes-fn: notes)`, so the notes panel on a second screen and in the only-notes view follows the theme's colors. It is built on top of `touying-notes`, and you can override it with your own implementation:

```typst
#show: metropolis-theme.with(
  config-common(notes-fn: my-notes),
)
```

See [Speaker Notes](../tutorials/speaker-notes.md) for details.

## Example

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#import "@preview/numbly:0.1.0": numbly

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.city,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 1)

= First Section

---

A slide without a title but with some *important* information.

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

=== sdfsdf

A slide with equation:

$ x_(n+1) = (x_n + a/x_n) / 2 $

#lorem(200)

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

We can use `#pause` to #pause display something later.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]

#show: appendix

= Appendix

---

Please pay attention to the current slide number.
```
