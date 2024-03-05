---
sidebar_position: 3
---

# Layout Your Contents

To better manage every detail in the slides and achieve better rendering results, like Beamer, Touying has introduced some unique concepts. This helps you maintain global information better and easily switch between different themes.

## Global Information

You can set the title, subtitle, author, date, and institution information for slides using:

```typst
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
```

The `date` parameter can accept `datetime` format and `content` format. The display format of the date in `datetime` format can be changed using:

```typst
#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")
```

:::tip[Internals]

Here, we introduce a bit of the OOP concept in Touying.

You should know that Typst is a typesetting language that supports incremental rendering. That is, Typst caches the results of previous function calls. This requires Typst to have only pure functions, meaning functions that do not change external variables. Therefore, it's challenging to modify a global variable in the true sense, as done in LaTeX. Even if you use `state` or `counter`, you need to use `locate` and callback functions to access their values, and this approach has a significant impact on performance.

Touying does not use `state` and `counter`, nor does it violate the Internals of Typst's pure functions. Instead, it cleverly uses a method in an object-oriented style to maintain a global singleton `s`. In Touying, an object refers to a Typst dictionary with its own member variables and methods. We have a convention that methods have a named parameter `self` to pass the object itself, and all methods are placed in the `.methods` domain. With this concept, it's not difficult to write a method to update `info`:

```typst
#let s = (
  info: (:),
  methods: (
    // update info
    info: (self: none, ..args) => {
      self.info += args.named()
      self
    },
  )
)

#let s = (s.methods.info)(self: s, title: [title])

Title is #s.info.title
```

This way, you can also understand the purpose of the `utils.methods()` function: it binds `self` to all methods of `s` and returns it. It simplifies the subsequent use through unpacking syntax.

```typst
#let (init, slide, slides) = utils.methods(s)
```
:::


## Sections and Subsections

Similar to Beamer, Touying also has the concepts of sections and subsections.

In the `#show: slides` mode, sections and subsections correspond to first-level and second-level titles, respectively. For example:

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, slides) = utils.methods(s)
#show: init

#show: slides

= Section

== Subsection

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/600876bb-941d-4841-af5c-27137bb04c54)

However, the second-level title does not always correspond to the subsection. The specific mapping may vary depending on the theme.

In the more general `#slide[..]` mode, sections and subsections are passed as parameters to the `slide` function, for example:

```typst
#slide(section: [Let's start a new section!])[..]

#slide(subsection: [Let's start a new subsection!])[..]
```

This will create a new section and a new subsection, respectively. However, this change typically only affects the internal `sections` state of Touying and is not displayed on the slide by default. The specific display may vary depending on the theme.

Note that the `section` and `subsection` parameters of `slide` can accept both content blocks and arrays in the format `([title], [short-title])` or dictionaries in the format `(title: [title], short-title: [short-title])`. The `short-title` will be used in some special cases, such as in the navigation of the `dewdrop` theme.


## Table of Contents

Displaying a table of contents in Touying is straightforward:

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, touying-outline) = utils.methods(s)
#show: init

#slide[
  == Table of contents

  #touying-outline()
]
```

The definition of `touying-oultine()` is:

```typst
#let touying-outline(enum-args: (:), padding: 0pt) = { .. }
```

You can modify the internal enum parameters with `enum-args`.

If you have complex custom requirements for the table of contents, you can use:

```typst
#slide[
  == Table of contents

  #states.touying-final-sections(sections => ..)
]
```

## Page Management

Due to the use of the `set page(..)` command in Typst, which creates a new page instead of modifying the current one, Touying chooses to maintain a `s.page-args` member variable in the singleton `s`. These parameters are only applied when creating a new slide.

:::warning[Warning]

Therefore, you should not use the `set page(..)` command yourself. Instead, you should modify the `s.page-args` member variable inside `s`.

:::

This way, we can query the parameters of the current page in real-time using `s.page-args`. This is useful for some functions that need to get page margins or the current page background color, such as `transparent-cover`.


## Page Columns

If you need to divide a page into two or three columns, you can use the default `compose` feature provided by the Touying `slide` function. The simplest examples are:

```typst
#slide[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/a39f88a2-f1ba-4420-8f78-6a0fc644704e)

If you need to change the way columns are composed, you can modify the `composer` parameter of `slide`. The default parameter is `utils.with.side-by-side(columns: auto, gutter: 1em)`. If we want the left column to occupy the remaining width, we can use:

```typst
#slide(composer: utils.side-by-side.with(columns: (1fr, auto), gutter: 1em))[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc)