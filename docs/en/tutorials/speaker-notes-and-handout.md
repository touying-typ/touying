---
sidebar_position: 5
---

# Speaker Notes and Handout Mode

## Speaker Notes

Speaker notes let you attach private reminders or talking points to a slide without displaying them on screen.

### Adding Notes

Use `#speaker-note[…]` anywhere inside a slide:

```typst
== My Slide

Here is the visible content.

#speaker-note[
  + Remind the audience about the previous slide.
  + The key point is X.
  + Ask if there are any questions.
]
```

Notes are not rendered in the main PDF output by default. They are exported to a `.pdfpc` file for use with [pdfpc](https://pdfpc.github.io/) (see the [pdfpc guide](../external/pdfpc)).

### Speaker Notes on a Second Screen

Enable a dual-screen mode where speaker notes appear on a second monitor alongside a preview of the next slide:

```typst
#show: my-theme.with(
  config-common(show-notes-on-second-screen: right),
)
```

Accepted values: `right`, `bottom`, or `none` (default).

### Full-Screen Notes Mode

For a notes-only view with a slide thumbnail:

```typst
#show: my-theme.with(
  config-common(show-only-notes: true),
)
```

This mode is useful for generating a separate presenter PDF.

### Custom Notes Rendering

The notes rendering function is configurable:

```typst
config-methods(
  show-only-notes: (self: none, notes, slide-body) => {
    // notes: the speaker-note content
    // slide-body: a thumbnail of the slide
    layout(size => {
      set page(width: size.width, height: size.height)
      grid(
        columns: (auto, 1fr),
        gutter: 1em,
        slide-body,
        notes,
      )
    })
  }
)
```

## Handout Mode

Handout mode produces a single page per logical slide by rendering only one subslide of each animated slide — ideal for distributing to your audience.

### Enabling Handout Mode

```typst
#show: my-theme.with(
  config-common(handout: true),
)
```

By default this renders the **last** subslide of each slide (showing the fully revealed state).

### Choosing Which Subslide Appears in Handout

```typst
// Always show the first subslide
config-common(handout: true, handout-subslides: 1)

// Show subslide 2 specifically
config-common(handout: true, handout-subslides: 2)

// Show subslides 1 and 3 (both become separate pages)
config-common(handout: true, handout-subslides: (1, 3))

// Use the same range syntax as #only / #uncover
config-common(handout: true, handout-subslides: "1,3")
```

### Handout-Only Slides

Mark a slide to appear **only** in handout mode using the `<touying:handout>` label:

```typst
== Extra Details <touying:handout>

This slide is invisible in the presentation but shows up in the handout.
```

Or use the `#handout-only[…]` function:

```typst
#handout-only[
  This content only appears in the handout.
]
```

## Combining Notes and Handout Mode

A common workflow is to produce two PDFs from a single source file:

1. **Presentation PDF** — normal mode, no config override.
2. **Handout PDF** — add `config-common(handout: true)` to a separate entry file.

```typst
// handout.typ
#import "main.typ": *

// Override just the handout setting
#show: my-theme.with(config-common(handout: true))
#include "content.typ"
```
