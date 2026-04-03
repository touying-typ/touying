---
sidebar_position: 3
---

# Settings and Config

## Global Styles

For Touying, global styles refer to set rules or show rules that need to be applied everywhere, such as `#set text(size: 20pt)`.

Themes in Touying encapsulate some of their own global styles, which are placed in `#self.methods.init`. For example, the simple theme encapsulates:

```typst
config-methods(
  init: (self: none, body) => {
    set text(fill: self.colors.neutral-darkest, size: 25pt)
    show footnote.entry: set text(size: .6em)
    show strong: self.methods.alert.with(self: self)
    show heading.where(level: self.slide-level + 1): set text(1.4em)

    body
  },
)
```

If you are not a theme creator but simply want to add some of your own global styles to your slides, you can easily place them before or after `#show: xxx-theme.with()`. For example, the metropolis theme recommends that you add the following global styles yourself:

```typst
#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 100)
#set par(justify: true)
```

## Global Information

Like Beamer, Touying helps you better maintain global information through a unified API design, allowing you to easily switch between different themes. Global information is a typical example of this.

You can set the title, subtitle, author, date, and institution information of your slides with:

```typc
config-info(
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
```

Later on, you can access them through `self.info`.

This information is generally used in the theme's `title-slide`, `header`, and `footer`, such as `#show: metropolis-theme.with(aspect-ratio: "16-9", footer: self => self.info.institution)`.

The `date` can accept `datetime` format and `content` format, and the date display format of the `datetime` format can be changed with:

```typc
config-common(datetime-format: "[year]-[month]-[day]")
```

## Preamble

The `config-common(preamble: ...)` option lets you run setup code on every slide without repeating it manually. This is useful when integrating packages like `codly`:

```typst
#show: simple-theme.with(
  config-common(preamble: {
    codly(languages: codly-languages)
  }),
)
```
However you may also set this locally for individual slides, see below.

## Show-Rule Config Overrides

You can override any configuration for all following slides and the current one, using `#show: touying-set-config.with(...)`, just like you would write a `show`/`set`-rule normally.

```example
#import "@preview/touying:0.7.0": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

== Normal Slide

This slide uses the default settings.



== Blue Background Slide
#show: touying-set-config.with(config-page(fill: blue.lighten(80%)))
This slide has a blue background applied via `touying-set-config`.

== Red Accent Slide
#show: touying-set-config.with(config-colors(primary: red))
This slide uses a red primary color, e.g. in `#alert` boxes.

#alert[This is an alert box with red accent color.]

== Changed Cover
#show: touying-set-config.with(config-methods(
  cover: utils.semi-transparent-cover,
))
Initial Content.

#pause

Content that appears with a semi-transparent cover effect.
```

## Local Config Overrides
If you want to affect only one specific slide, you can set the config locally via `#slide(config: ...)[...]`.
```example
>>> #import "../lib.typ": *
>>> #import themes.simple: *

>>> #show: simple-theme.with(aspect-ratio: "16-9")
== Local Config 
#slide(config:config-page(fill: purple.lighten(90%)))[
Only this slide has a light purple background, but the next slide goes back being light blue.
]
```

## Deferred Config Show Rules
You may even defer a config change to the beginning of the next slide.
This is also how `show: appendix` works, but also useful for setting a custom preamble or similar that affects not just the slide's content. (Note that config-common has no effect, you can also write your config dict without it.)

```example
>>> #import "../lib.typ": *
>>> #import themes.simple: *

>>> #show: simple-theme.with(aspect-ratio: "16-9")
== Content Slide
Some content.
#show: touying-set-config.with(defer:true, config-common(appendix:true))
// you can just write `show: appendix`
== Appendix
Page counter does no longer increase.
#show: touying-set-config.with(defer:true, (preamble:{codly(languages: codly-languages)}))
== Deferred Config Change
Now we have codly available.
```

## Frozen Counters

When using animation, figure and theorem counters inside a single slide keep advancing per subslide by default. To freeze a counter (so it does not change between subslides), use:

```typst
config-common(frozen-counters: (figure.where(kind: image),))
```

This is especially useful when working with the [Theorion](../integration/theorion.md) package:

```typst
config-common(frozen-counters: (theorem-counter,))
```


## Accessing Config Information

As of touying 0.7.1, you may use `touying-get-config` to access a the stored config for a slide. This will be the global config up to the overrides you made for that slide.

Note that it is evaluated at `context` time and parsed into the document flow where you request it, thus it is only available as content.

```typst
touying-get-config("info.date")
```

