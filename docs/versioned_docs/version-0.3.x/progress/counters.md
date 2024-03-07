---
sidebar_position: 1
---

# Touying Counters

The states of Touying are placed under the `states` namespace, including all counters.

## Slide Counter

You can access the slide counter using `states.slide-counter` and display the current slide number with `states.slide-counter.display()`.

## Last-Slide Counter

In some cases, we may need to add an appendix to slides, leading to the requirement to freeze the last-slide counter. Therefore, a second counter is maintained here.

You can use `states.last-slide-number` to display the number of the last slide before the appendix.

## Progress

You can use

```typst
#states.touying-progress(ratio => ..)
```

to show the current progress.

## Appendix

You can use

```typst
// appendix by freezing last-slide-number
#let s = (s.methods.appendix)(self: s)
#let (slide,) = utils.methods(s)

#slide[
  appendix
]
```

syntax to enter the appendix.

Additionally, `#let s = (s.methods.appendix-in-outline)(self: s, false)` can be used to hide the appendix section from the outline.