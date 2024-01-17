---
sidebar_position: 5
---

# Handout Mode

While watching slides and attending lectures, the audience often wishes to have handouts for reviewing challenging concepts. Therefore, it's beneficial for the author to provide handouts for the audience, preferably before the lecture for better preparation.

The handout mode differs from the regular mode as it doesn't require intricate animation effects. It retains only the last subslide of each slide.

Enabling handout mode is simple:

```typst
#let s = (s.methods.enable-handout-mode)(self: s)
```
