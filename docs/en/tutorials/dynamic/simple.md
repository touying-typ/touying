---
sidebar_position: 1
---

# Simple Animations

Touying provides two markers for simple animation effects: `#pause` and `#meanwhile`.

## pause

The purpose of `#pause` is straightforward – it separates the subsequent content into the next subslide. You can use multiple `#pause` to create multiple subslides. Here's a simple example:

```example
>>> #import "@preview/touying:0.6.3": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  First #pause Second

  #pause

  Third
]
```

This example will create three subslides, gradually revealing the content.

As you can see, `#pause` can be used inline or on a separate line.

## meanwhile

In some cases, you may need to display additional content simultaneously with `#pause`. In such cases, you can use `#meanwhile`.

```example
>>> #import "@preview/touying:0.6.3": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  First
  
  #pause
  
  Second

  #meanwhile

  Third

  #pause

  Fourth
]
```

This example will create only two subslides, with "First" and "Third" displayed simultaneously, and "Second" and "Fourth" displayed simultaneously.