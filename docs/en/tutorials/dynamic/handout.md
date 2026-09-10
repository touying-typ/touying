---
sidebar_position: 6
---

# Handout Mode

Handout mode collapses all animation subslides into a single page per logical slide, making it easy to produce a printable or distributable version of your presentation.

## Enabling Handout Mode

```typst
config-common(handout: true)
```

Place this inside your theme setup:

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: true),
)

= Title

== Animated Slide

First item.

#pause

Second item (won't generate a separate page in handout mode).

#pause

Third item.
```

By default, handout mode keeps only the **last** subslide of each slide.

## Choosing Which Subslide to Keep

You can choose a specific subslide (or a set of subslides) to keep in handout output with `handout-subslides`:

```typst
// Keep only the first subslide (useful for "before" snapshots)
config-common(handout: true, handout-subslides: 1)

// Keep the first and last subslides
config-common(handout: true, handout-subslides: (1, -1))

// Keep a range expressed as a string (same syntax as `only`/`uncover`)
config-common(handout: true, handout-subslides: "1-2")
```

## Handout-only Slides

Use the `<touying:handout>` label to create slides that appear **only** in handout mode and are hidden during normal presentation:

```typst
== Extra Notes for Handout <touying:handout>

This slide is included when `handout: true` but invisible otherwise.
```

## Mode-only Content

The `<touying:handout>` label works on a whole slide. To control which mode a *piece* of content appears in, use these three inline markers:

| Marker | Appears in |
|---|---|
| `#handout-only[..]` | handout mode only |
| `#presentation-only[..]` | presentation mode only (i.e. `handout: false`) |
| `#slides-only[..]` | both handout and presentation mode, but not in article mode |

```typst
#handout-only[This paragraph only shows up in the handout.]

#presentation-only[This paragraph only shows up while presenting.]

#slides-only[_Live demo here — see the code repository._]
```

When hidden, the content is removed entirely; no space is reserved for it. The body of these markers may itself contain slide-breaking elements (a heading, `#pagebreak()`, a bare `---`), and in whichever mode the content is actually visible they behave exactly as if the wrapper were not there — a heading inside `#handout-only[..]` really does start a new slide in handout mode.

In article mode all three are stripped, `#handout-only` and `#presentation-only` included, regardless of the `handout` flag.

### Around a Slide, Not Inside It

These markers wrap *document content*, so put them **around** a call to a slide function, never inside its body:

```typst
#slides-only(title-slide[Only in the slide deck])   // correct
#title-slide[#slides-only[..]]                      // panics
```

A slide function does not lay its body out where you wrote it — it hands touying a description of the slide, and the body is rendered later, from inside that slide. A mode marker in there is never reached by the walk over the document that is supposed to strip it, and the compile ends with `Unsupported mark 'touying-slides-only'`. (`#pause` and friends are different: those are read by the parser, which *does* look inside a slide body.)

`#slides-only(title-slide(..))` is worth knowing for its own sake. A plain `#title-slide[..]` still renders in article mode, inline and right after the article theme's own title block, so the title material appears twice.

## Workflow Tip

A common workflow is to keep `handout: false` (the default) while presenting, then switch to `handout: true` when exporting a PDF to share with your audience:

```typst
// During presentation
#show: my-theme.with(config-common(handout: false))

// When building the handout PDF
#show: my-theme.with(config-common(handout: true))
```
