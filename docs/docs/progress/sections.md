---
sidebar_position: 2
---

# Touying Sections

Touying maintains its own sections state to record the sections and subsections of slides.

## touying-outline

`#touying-outline(enum-args: (:), padding: 0pt)` is used to display a simple outline.

## touying-final-sections

`#states.touying-final-sections(final-sections => ..)` is used to customize the display of the outline.

## touying-progress-with-sections

```typst
#states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)
```

This is the most powerful one, allowing you to build any complex progress display with its functionalities.