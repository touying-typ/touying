---
sidebar_position: 7
---

# Article Mode

Article mode renders the same source file as a flowing prose document instead of a slide deck.

```bash
typst compile talk.typ talk.pdf                            # slides
typst compile --input export-mode=article talk.typ talk.pdf   # article
```

`--input export-mode=article` wins over whatever the file says, so the same source builds both outputs without editing it. If you prefer to fix the mode in the file, set it in the config:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== A Section

The page belongs to the article theme now, not to the slide theme.
```

`export-mode` takes `"slides"`, `"presentation"`, `"handout"` or `"article"`. See [Output Modes](../tutorials/output-modes) for how they relate.

## What changes

- **No page breaks between slides.** Content flows, and a heading starts a section rather than a slide.
- **Animations collapse.** Each slide is rendered at its final subslide, so `#pause` and `#uncover` leave their content in place and covered content appears as it does at the end.
- **The page belongs to the article theme**, not to the slide theme. Slide-level styling such as the header, the footer and the 16:9 page is dropped.

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== A Section

Ordinary content. #pause This appears on a second subslide in the deck, and inline here.
```

## Choosing an article theme

Touying ships a plain article theme and uses it by default. Any theme that takes a body works, including document themes from Universe:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#import "@preview/arkheion:0.1.0": arkheion

#show: simple-theme.with(
  config-common(export-mode: "article", article-theme: arkheion),
)

== A Section

Rendered by arkheion rather than by touying's own article theme.
```

The theme is a function applied to the whole article, so configure it with `.with(..)` when you name it:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#import themes.article: article-theme

#show: simple-theme.with(
  config-common(
    export-mode: "article",
    article-theme: article-theme.with(numbering: "1.1"),
  ),
)

= A Part

== A Section

Numbered by the article theme.
```

### Passing your slide metadata to it

An article theme usually wants a title and an author of its own. `config-article(available-fields: ..)` maps entries from your touying config onto the theme's parameters, so you write them once in `config-info` or elsewhere:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#import "@preview/arkheion:0.1.0": arkheion

#show: simple-theme.with(
  config-info(title: [Projection], author: [A. Author]),
  config-common(export-mode: "article", article-theme: arkheion),
  config-article(available-fields: (title: "info.title")),
)

== A Section

The title above came from `config-info`.
```

The key is the theme's parameter name, the value is a path into the touying config. Only list fields the theme accepts, and only where the types line up: arkheion's `authors` wants an array of dictionaries, so handing it `config-info`'s `author` fails with `element text has no method map`. Check the theme's signature first.

If the theme has no title block of its own, either give `config-article(title-block-fn: ..)` a function that returns one, or write one yourself in an `#article-only[..]` block before the first slide.

## Writing for both outputs

Because you may want to write slightly different things for each ouput target you may select what goes in which via 3 functions. They are covered in full in [Output Modes](../tutorials/output-modes); in short:

- `#article-only[..]` adds content that exists only in the article. Even slide-breaking elements like headings or "---" can be used in here.
- `#slides-only[..]` shows content only when outputting slides.
- `#article-text[..]` **replaces** the slide it is written in with prose. One per slide.

`#article-text` is the interesting one. Bullet points that work on a slide usually read badly in a document, so write the prose version next to them and let each output take what it needs:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== Why This Matters

- terse
- bullet
- points

#article-text[
  In the article this paragraph stands in for the bullet points above, which
  never reach the page.
]
```

It replaces the whole slide it is written in, so it works the same whether the slide came from a heading or from an explicit `#slide[..]` call. Where you write it does not matter: above the content it replaces, below it, or in the middle. Write only one per slide, since a second one is ignored with a warning.

A bare `---` is a slide separator, so it is dropped from the article; only a real `#pagebreak()` breaks a page there. Inside `#article-text[..]` or `#article-only[..]` a `---` is kept, because nothing in those bodies can break a slide.

## Recalling animated content

An animated diagram is one slide with several subslides, and the article renders only the last. When the intermediate stages carry the argument, `#touying-recall` puts a chosen one back into the prose:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme.with(config-common(export-mode: "article"))
#import "@preview/cetz:0.4.2"
#let canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

== The Construction
#canvas(label: "fig", {
  import cetz.draw: *
  rect((0, 0), (4, 3))
  (pause,)
  circle((2, 1.5), radius: 0.8)
}, length: 20pt)

#article-text[
  First the frame is fixed:
  #touying-recall(<fig>, subslides: 1)

  Then the inscribed circle follows:
  #touying-recall(<fig>, subslides: 2)
]
```

`subslides` picks the stage. Pass `base:` when the recall is not the first thing on its slide, since the stage numbers are counted from the enclosing flow.
See the documentation of the function for more details. Another similar function is `touying-render` which takes in content and renders it at a subslide.

## Floating images to the side

A full-width image that suits a slide wastes a page in an article. Touying can float images onto one side and wrap the text around them:

```typst
#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(
    wrap-images: true,          // raw images, on by default
    wrap-image-figures: true,   // images with a caption
    wrap-other-figures: false,  // other captioned blocks
    wrap-other: false,          // tables, canvases, ...
    wrap-align-direction: right,
    wrap-width: 50%,        // how much of the text width a float takes
  ),
)
```

Article mode linearizes the deck rather than carrying its layout over, so a float takes `wrap-width` of the text width, 50% by default, whatever width the element was given for the slide. An image is scaled to fill that. Whether you wrote it in a composer column or on its own line makes no difference.

Wrapping is done with [meander](https://typst.app/universe/package/meander), which is only loaded for sections that really have something to wrap.

## Things worth knowing

**A title slide renders inline.** `#title-slide(..)` is a slide like any other, so in the article it appears as well and the title material shows up twice. Wrap the call to keep it out:

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme.with(config-common(export-mode: "article"))
#slides-only(title-slide[])

== A Section

No duplicated title block above this.
```

**Marks must be reachable.** `#pause`, `#article-text` and the rest are resolved by walking the document before anything is laid out. One nested inside a `#context` block or a container that is measured is never reached, and the compile ends with `Unsupported mark`. Do not wrap them in self-counting animation functions or other `#context` expressions.

**Speaker notes do not appear.** `#speaker-note[..]` is for the presenter view. Use `#article-only[..]` for an aside that belongs in the document.
