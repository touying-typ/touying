---
sidebar_position: 1
---

# Slide Counters and Progress

Touying provides a set of counters and utilities for tracking and displaying presentation progress.

## Slide Counter

`utils.slide-counter` is the primary Typst counter that increments on every slide.

```typst
// Display the current slide number
#context utils.slide-counter.display()
```

Note the use of `.display()` rather than `.get()`: `.get()` returns the counter in its **array** form, so putting it into content directly renders as `(1,)`.

Use it in a custom footer:

```example
#import "@preview/touying:0.7.4": *
#import themes.default: *

#show: default-theme.with(
  aspect-ratio: "16-9",
  config-page(
    footer: context [Slide #utils.slide-counter.display()],
  ),
)

= Section

== First Slide

Content here.

== Second Slide

More content.
```

## Total Slide Number

`utils.last-slide-number` holds the number of the last slide **before the appendix**. This is what you typically want to show as the denominator in a "slide X of Y" footer:

```typst
#context [#utils.slide-counter.display() / #utils.last-slide-number]
```

The `#context` here must be followed by a content block. Written as `#context utils.slide-counter.display() + " / " + utils.last-slide-number`, the `#context` in markup binds only to the first expression, and the rest is output verbatim as text.

## Progress Bar

`utils.touying-progress` provides a ratio (0.0–1.0) representing how far through the presentation you are:

```typst
#utils.touying-progress(ratio => {
  // ratio is a float between 0.0 and 1.0
  box(width: ratio * 100%, height: 4pt, fill: primary)
})
```

`#components.progress-bar(primary, secondary, height: 2pt)` is a ready-made wrapper around it; this is how the metropolis, university and stargazer themes draw their progress bars.

## Appendix and Freezing the Counter

The `appendix` show rule freezes only the **denominator** — `utils.last-slide-number`, the total slide count — so appendix slides do not change the total shown in the footer. The slide counter `utils.slide-counter` keeps advancing, so a footer in the appendix reads something like `5 / 3`:

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme

= Main Section

== Introduction

The slide count increments normally here.

== Second Slide

Still counting.

#show: appendix

= Appendix

== Backup Slide

The denominator still shows the count from the last main slide,
while the slide number itself keeps advancing.
```

If you want a slide to stay out of the counting entirely (neither the slide number nor the total advances), use `config-common(freeze-slide-counter: true)`. This is exactly how the bundled themes keep slides such as `title-slide`, `outline-slide` and `focus-slide` from taking up a slide number:

```typst
#slide(config: config-common(freeze-slide-counter: true))[
  This slide does not advance the slide counter.
]
```
