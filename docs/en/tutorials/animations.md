---
sidebar_position: 2
---

# Animations

Touying's animation system creates multiple *subslides* from a single slide definition. Each subslide is a separate PDF page, and a PDF viewer or presenter tool animates the sequence by flipping through pages.

## `#pause` — Step-by-Step Reveal

`#pause` is the simplest animation tool. Everything after a `#pause` marker is hidden on earlier subslides and revealed on the next one:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Step 1.

  #pause

  Step 2.

  #pause

  Step 3.
]
```

`#pause` also works inline:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  I know #pause the answer #pause is 42.
]
```

### `#pause` in Lists

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  - Item A
  #pause
  - Item B
  #pause
  - Item C
]
```

### `#pause` in Math

Use `pause` (without `#`) inside `$…$` math expressions:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  $
    f(x) &= pause x^2 + 2x + 1 \
         &= pause (x + 1)^2
  $
]
```

## `#meanwhile` — Parallel Tracks

`#meanwhile` resets the subslide counter for content that should appear in sync with a `#pause` sequence elsewhere on the slide. Think of it as two columns that animate together:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Left: A

  #pause

  Left: B

  #meanwhile

  Right: 1

  #pause

  Right: 2
]
```

Both "Left: A / Right: 1" appear together on subslide 1, and "Left: B / Right: 2" appear together on subslide 2.

## `#uncover` — Reserve Space

`#uncover(subslides, body)` shows `body` only on the specified subslides. On other subslides the content is *covered* (invisible but still occupying space):

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Always visible.

  #uncover("2-")[Visible from subslide 2 onward.]

  #uncover("2-3")[Visible on subslides 2 and 3.]

  #uncover(2)[Visible only on subslide 2.]
]
```

**Subslide selector syntax:**

| Selector | Meaning |
|----------|---------|
| `1` | Only subslide 1 |
| `"2-"` | Subslide 2 and later |
| `"2-4"` | Subslides 2 through 4 |
| `"1,3"` | Subslides 1 and 3 |

## `#only` — Remove Space

`#only(subslides, body)` shows `body` only on specified subslides, but does **not** reserve space on other subslides — the content physically disappears from the layout:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  Always here.

  #only("2-")[This takes no space on subslide 1.]
]
```

## `#alternatives` — Swap Content

`#alternatives[…][…][…]` displays a different block on each subslide, automatically sizing to fit the widest/tallest variant:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (alternatives,) = utils.methods(self)

  The answer is #alternatives[maybe][probably][definitely] correct.
])
```

Additional parameters: `start: 2` (start from subslide 2), `repeat-last: true` (repeat last item), `position: center + horizon` (alignment).

## Callback Style — Full Control

Mark-style functions (`#uncover`, `#only`, `#alternatives`) have a limitation: they cannot be nested inside certain Typst layout contexts. The **callback style** works everywhere.

Pass a function `self => …` as the slide body. Then extract methods from `self`:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  Subslide #self.subslide of 3.

  #uncover("2-")[Uncovered from slide 2.]

  #only(3)[Only on slide 3.]

  The winner is #alternatives[Alice][Bob][Carol].
])
```

:::info

You must set `repeat: N` manually when using callback style because Touying cannot infer how many subslides are needed.

:::

## Cover Function

When `#pause` or `#uncover` hides content, it uses a *cover function* to do so. The default is Typst's built-in `hide`, which preserves layout space. You can change it:

```typst
// Use a semi-transparent overlay instead
config-methods(cover: utils.semi-transparent-cover.with(alpha: 85%))
```

```typst
// Useful workaround for hiding list/enum markers
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```

## `#effect` — Apply a Style on a Range

`#effect` applies a Typst function to content on specified subslides:

```typst
#effect(text.with(fill: red), "2-")[This text turns red from subslide 2 onward.]
```

## `#item-by-item` — Animate List Items

`#item-by-item` progressively reveals list or enum items:

```example
>>> #import "@preview/touying:0.6.2": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #item-by-item[
    - First item
    - Second item
    - Third item
  ]
]
```

## Handout Mode

Handout mode renders only the *last* subslide of each animated slide, producing a clean single-page-per-slide document suitable for distribution:

```typst
#show: my-theme.with(
  config-common(handout: true),
)
```

You can also control which subslide is shown in handout mode:

```typst
// Show the first subslide instead of the last
config-common(handout-subslides: 1)

// Show subslides 1 and 3
config-common(handout-subslides: (1, 3))
```

## `touying-recall` — Reuse a Slide

Replay any previously defined slide anywhere in the document:

```typst
== Original Slide <my-slide>

Some content with #pause animations.

// Later…
== Recall

#touying-recall(<my-slide>)
```
