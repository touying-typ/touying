---
sidebar_position: 6
---

# Stargazer Theme

The Stargazer theme, originally created by [Coekjan](https://github.com/Coekjan/) for the [touying-buaa](https://github.com/Coekjan/touying-buaa) project, is an aesthetically pleasing and versatile theme suitable for everyday use.

## Initialization

You can initialize the theme with the following code:

```typst
#import "@preview/touying:0.7.4": *
#import themes.stargazer: *

#import "@preview/numbly:0.1.0": numbly

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Stargazer in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()
```

The `stargazer-theme` accepts the following parameters:

- `aspect-ratio`: The aspect ratio of the slides, either "16-9" or "4-3", with a default of "16-9".
- `align`: The alignment of the slides, with a default of `horizon`.
- `alpha`: The transparency of the covered (not-yet-reached) headings in the outlines, with a default of `20%`.
- `title`: The content displayed in the header, with a default of `self => utils.display-current-heading(depth: self.slide-level)`, or you can pass a function like `self => self.info.title`.
- `header-right`: The content displayed on the right side of the header's navigation bar, with a default of `self => self.info.logo`.
- `progress-bar`: Whether to display a progress bar at the bottom of the slide, with a default of `true`.
- `footer-columns`: The widths of the four footer columns, with a default of `(25%, 25%, 1fr, 5em)`.
- `footer-a`: The first column, with a default of `self => self.info.author`.
- `footer-b`: The second column, with a default of `self => utils.display-info-date(self)`.
- `footer-c`: The third column, with a default of `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
- `footer-d`: The fourth column, with a default of `context utils.slide-counter.display() + " / " + utils.last-slide-number`.

## Color Theme

The Stargazer theme uses the following color scheme by default:

```typc
config-colors(
  primary: rgb("#005bac"),
  primary-dark: rgb("#004078"),
  secondary: rgb("#ffffff"),
  tertiary: rgb("#005bac"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

You can modify this color scheme using `config-colors()`.

## Slide Function Family

The Stargazer theme offers a variety of custom slide functions:

```typst
#title-slide(config: (:), extra: none, ..args)
```

`title-slide` reads information from `self.info` for display, and you can also pass an `extra` parameter for additional information.

---

```typst
#slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
)[
  ...
]
```

A standard slide function with a title and a footer. `title`, `header`, `footer` and `align` all default to `auto`, meaning they follow the theme-level settings; giving a non-`auto` value overrides the corresponding `self.store` field for that one slide.

---

```typst
#outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  numbered: true,
  level: none,
  ..args,
)
```

Used to add a table of contents slide. The `..args` are forwarded to [`components.custom-progressive-outline`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline).

The outline slide places an invisible heading with `place(hide(heading(..)))`, so that both the slide header and the speaker-note panel can pick the title up through `utils.display-current-heading`; it no longer overwrites `self.store.title`.

---

```typst
#focus-slide[
  ...
]
```

Used to draw the audience's attention. The background color is `self.colors.primary`.

---

```typst
#new-section-slide(
  config: (:),
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
  body,
)
```

Start a new section with the given title; it is implemented by delegating to `outline-slide`. It is already registered through `config-common(new-section-slide-fn: ..)`, so it is normally triggered by writing `= Title` and does not need to be called by hand.

---

```typst
#ending-slide(config: (:), title: none, body)
```

Used for the closing slide. When a `title` is given it is shown in a block filled with `self.colors.tertiary`, and an invisible heading is placed alongside it so that the slide header and the speaker-note panel can pick the title up.

---

```typst
#tblock(title: none, it)
```

Stargazer's own theorem block: the title bar uses `self.colors.primary-dark` and the body a lightened `self.colors.primary`. It is built on `touying-fn-wrapper-raw`, so it works normally together with animation functions such as `#pause` and `#uncover`.

## Speaker Notes

Stargazer defines its own `notes` function and registers it with `config-common(notes-fn: notes)`, so the notes panel on a second screen and in the only-notes view follows the theme's colors. It is built on top of `touying-notes`, and you can override it with your own implementation:

```typst
#show: stargazer-theme.with(
  config-common(notes-fn: my-notes),
)
```

See [Speaker Notes](../tutorials/speaker-notes.md) for details.

## Example

```example
#import "@preview/touying:0.7.4": *
#import themes.stargazer: *

#import "@preview/numbly:0.1.0": numbly

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Stargazer in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()

= Section A

== Subsection A.1

#tblock(title: [Theorem])[
  A simple theorem.

  $ x_(n+1) = (x_n + a / x_n) / 2 $
]

== Subsection A.2

A slide without a title but with *important* information.

= Section B

== Subsection B.1

#lorem(80)

#focus-slide[
  Wake up!
]

== Subsection B.2

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#show: appendix

= Appendix

== Appendix

Please pay attention to the current slide number.
```
