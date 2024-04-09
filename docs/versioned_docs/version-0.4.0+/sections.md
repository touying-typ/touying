---
sidebar_position: 3
---

# Sections and Subsections

## Structure

Similar to Beamer, Touying also has the concept of sections and subsections.

Generally, level 1, level 2, and level 3 headings correspond to section, subsection, and title, respectively, as in the dewdrop theme.

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.dewdrop.register()
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Section

== Subsection

=== Title

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/1574e74d-25c1-418f-a84f-b974f42edae5)

However, often we don't need subsections, and we can use level 1 and level 2 headings to correspond to section and title, as in the university theme.

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.university.register()
#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

= Section

== Title

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/9dd77c98-9c08-4811-872e-092bbdebf394)

In fact, we can control this behavior through the `slide-level` parameter of the `slides` function. `slide-level` represents the complexity of the nested structure, starting from 0. For example, `#show: slides.with(slide-level: 2)` is equivalent to the section, subsection, and title structure; while `#show: slides.with(slide-level: 1)` is equivalent to the section and title structure.

## Numbering

To add numbering to sections and subsections, we simply use:

```typst
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")
```

This sets the default numbering to `1.1`, with the section corresponding to `1.`.

## Table of Contents

Displaying a table of contents in Touying is straightforward:

```typst
#import "@preview/touying:0.4.0": *

#let s = themes.simple.register()
#let (init, slides, alert, touying-outline) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides.with(slide-level: 2)

= Section

== Subsection

=== Title

==== Table of contents

#touying-outline()
```

![image](https://github.com/touying-typ/touying/assets/34951714/3cc09550-d3cc-40c2-a315-22ca8173798f)

Where the definition of `touying-outline()` is:

```typst
#let touying-outline(enum-args: (:), padding: 0pt) = { .. }
```

You can modify the parameters of the internal enum through `enum-args`.

If you have complex custom requirements for the table of contents, you can use:

```typst
#states.touying-final-sections(sections => ..)
```

As done in the dewdrop theme.