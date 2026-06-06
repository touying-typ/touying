---
sidebar_position: 3
---

# Section Utilities

Touying injects invisible headings into each slide so that you can query the current section at any time using Typst's `query()` function.

## Displaying the Current Heading

`utils.display-current-heading(level: N)` returns the text of the most recent heading at the given level. It is used by most themes to populate the header:

```typst
// Show the current section (level 1) in the header
utils.display-current-heading(level: 1)

// Show the current subsection (level 2)
utils.display-current-heading(level: 2)
```

`utils.display-current-short-heading(level: N)` is a shorter variant that strips numbering:

```typst
utils.display-current-short-heading(level: 2)
```

## Custom Header with Section Name

You can use these utilities in a custom header:

```example
#import "@preview/touying:0.7.4": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    header: [
      #text(gray, utils.display-current-heading(level: 2))
      #h(1fr)
      #context utils.slide-counter.display()
    ],
  ),
)

= My Section

== First Slide

Header shows "First Slide" on the right side.

== Second Slide

Header updates automatically.
```

## Progressive Outlines

Touying has a couple of progressive outline utilities. The easiest one is the following.

### Progressive Outline (Default)

[`components.progressive-outline()`](https://touying-typ.github.io/docs/reference/components/progressive-outline) renders an outline that highlights the current section and grays out the rest — a common pattern in themed presentations:

```example
#import "@preview/touying:0.7.4": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Introduction

== Overview <touying:hidden>

#components.progressive-outline()

= Background

== Slide

Content.
```

[`components.adaptive-columns(outline(...))`](https://touying-typ.github.io/docs/reference/components/adaptive-columns) is another variant that wraps a standard [`outline()`](https://typst.app/docs/reference/model/outline/) in an appropriate number of columns so it fits on one page.

### Custom Progressive Outline

[`components.custom-progressive-outline()`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline) allows you to specify all sorts of styling rules for the progressive outline. This makes it much more versatile, but you need to specify everything yourself. 

```example
#import "@preview/touying:0.7.0": *
#import themes.dewdrop: *

#show: dewdrop-theme.with(aspect-ratio: "16-9")

= Introduction

== Overview <touying:hidden>

#components.custom-progressive-outline(
  level: 1,
  show-past: (true, false),
  show-future: (true, false),
  show-current: (true, true, false),
  vspace: (.5em, .0em),
  numbering: ("1.1",),
  numbered: (true,true),
  title: none,
)

= Background

== Slide

Content.
```

Notice that we had to specify everything ourselves, there are no pretty defaults. An some parameters are automatically repeated, while others are not. If you don't like this you can also just adapt the outline entries directly with a `set` rule. For this purpose we provide you with a helper to get the current section context.

### Section Relationship Helper

The utility [`utils.section-relationship()`](https://touying-typ.github.io/docs/reference/utils/section-relationship) allows you to get the relationship of the current section you are in to some given outline entries. It returns an integer that can be of of (-2, -1, 0, 1, 2).

Negative numbers are headings declared earlier in the document, positive values are headings declared later in the document. Only the current heading **and**  its children have relationship `0`.

The values -1 and 1 are reserved for other headings under the same top-level heading that the current section falls under. Together with the actual `outline.entry.level` this should be enough to construct any outline you like.

You can e.g. use like so
```example
>>>#import "@preview/touying:0.7.4": *
>>>#import themes.simple: *
>>>#show: simple-theme
>>>#set heading(numbering: "1.1")

= Start
== Start Sub
#lorem(5)
= My content
== My heading
#lorem(5)
---
#{// displays all top levels and all levels of the current top-level normally,
  // with future siblings and other top levels semi-transparent
  // the current entry bold and all others red.

  show outline.entry: it => {
    let relationship = utils.section-relationship(it)
    let current = utils.current-heading()
    let alpha = if relationship == -2 or relationship > 0 { 40% } else { 100% }
    let weight = if relationship == 0 and current.level == it.level {
      "bold"
    } else { "regular" }
    if it.level > 1 and calc.abs(relationship) > 1 {
      text(fill: red, it) //normally you put `none` here.
    } else {
      text(fill: utils.update-alpha(text.fill, alpha), weight: weight, it)
    }
  }
  outline(title: none)
}
---
=== Subsubheading
#lorem(3)

== Another heading
#lorem(5)

= Next Top Level

== Subsection
#lorem(5)
```
