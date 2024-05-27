---
sidebar_position: 7
---

# Multi-File Architecture

Touying features a syntax as concise as native Typst documents, along with numerous customizable configuration options, yet it still maintains real-time incremental compilation performance, making it suitable for writing large-scale slides.

If you need to write a large set of slides, such as a course manual spanning tens or hundreds of pages, you can also try Touying's multi-file architecture.

## Configuration and Content Separation

A simple Touying multi-file architecture consists of three files: a global configuration file `globals.typ`, a main entry file `main.typ`, and a content file `content.typ` for storing the actual content.

These three files are separated to allow both `main.typ` and `content.typ` to import `globals.typ` without causing circular references.

`globals.typ` can be used to store some global custom functions and initialize Touying themes:

```typst
// globals.typ
#import "@preview/touying:0.4.2": *

#let s = themes.university.register(aspect-ratio: "16-9")
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#let (slide, empty-slide, title-slide, focus-slide, matrix-slide) = utils.slides(s)

// as well as some utility functions
```

`main.typ`, as the main entry point of the project, applies show rules by importing `globals.typ` and includes `content.typ` using `#include`:

```typst
// main.typ
#import "/globals.typ": *

#show: init
#show strong: alert
#show: slides

#include "content.typ"
```

`content.typ` is where you write the actual content:

```typst
// content.typ
#import "/globals.typ": *

= The Section

== Slide Title

Hello, Touying!

#focus-slide[
  Focus on me.
]
```

## Multiple Sections

Implementing multiple sections is also straightforward. You only need to create a `sections` directory and move the `content.typ` file to the `sections.typ` directory, for example:

```typst
// main.typ
#import "/globals.typ": *

#show: init
#show strong: alert
#show: slides

#include "sections/content.typ"
// #include "sections/another-section.typ"
```

And

```typst
// sections/content.typ
#import "/globals.typ": *

= The Section

== Slide Title

Hello, Touying!

#focus-slide[
  Focus on me.
]
```

Now, you have learned how to use Touying to achieve a multi-file architecture for large-scale slides.