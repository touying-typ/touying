---
sidebar_position: 1
---

# Touying Counters

The utils of Touying are placed under the `utils` namespace, including all counters.

## Slide Counter

You can access the slide counter using `utils.slide-counter` and display the current slide number with `utils.slide-counter.display()`.

## Last-Slide Counter

In some cases, we may need to add an appendix to slides, leading to the requirement to freeze the last-slide counter. Therefore, a second counter is maintained here.

You can use `utils.last-slide-number` to display the number of the last slide before the appendix.

## Progress

You can use

```typst
#utils.touying-progress(ratio => ..)
```

to show the current progress.

## Appendix

You can use

```typst
#show: appendix

= Appendix

appendix
```

syntax to enter the appendix.

Additionally, label `<touying:unoutlined>` can be used to hide the appendix section from the outline.