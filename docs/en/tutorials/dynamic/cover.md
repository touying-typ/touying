---
sidebar_position: 4
---

# Cover Function

As you already know, both `uncover` and `#pause` use the `cover` function to conceal content that is not visible. So, what exactly is the `cover` function here?

## Default Cover Function: `hide`

The `cover` function is a method stored in `self.methods.cover`, which is later used by `uncover` and `#pause`.

The default `cover` function is the [hide](https://typst.app/docs/reference/layout/hide/) function. This function makes the internal content invisible without affecting the layout. It is written onto the config as detailed below.

## Updating the Cover Function

In some cases, you might want to use your own `cover` function. In that case, you can set your own `cover` function using: 

```typst
config-methods(cover: utils.hiding-cover)
```

See [Writing Your Own Cover Function](#writing-your-own-cover-function) below for what touying expects of a method you write yourself.

## Alpha and Color Changing Cover Function

Touying supports a semi-transparenting cover function, which can be enabled by setting:

```typst
config-methods(cover: utils.alpha-changing-cover)
```

You can adjust the transparency through the `alpha: ..` parameter by adding `.with(alpha: 30%)`.

Or you may try its cousin `utils.color-changing-cover` which changes all colors to the one specified.


:::tip[Internals]

The `utils.alpha-changing-cover` method works by changing all colors it encounters to have a lower alpha value. This can be costly because we need to access typst's context at every level of nested style or context.

If you notice your project compiling slowly you can try switching to `utils.color-changing-cover`.

Both methods cannot change all colors displayed. Some contents like images or tilings cannot be interfered with. As such both methods utilize a `fallback-hide` which aims to mimic the same effect by overlaying the content with a gray semi-transparent rectangle via `utils.semi-transparent-cover`. Using that function as main semi-transparent-cover is no longer recommended as it has multiple not to be fixed bugs. 

:::

### Covering Filled Shapes

An element that paints its own background should usually not be recolored: the shape and the text on top of it would both be forced to the same color, leaving the text unreadable. Imagine an image becoming a gray rectangle.
`utils.color-changing-cover` can therefore hand filled elements to the fallback hide instead, controlled by `fallback-for-filled: true` (the default). Turn it off to recolor them like everything else, so the slide greys uniformly:

```typst
config-methods(cover: utils.color-changing-cover.with(fallback-for-filled: false))
```

`utils.alpha-changing-cover` has no such parameter — lowering alpha dims a shape without flattening it against its content.

## Writing Your Own Cover Function

A cover function takes `self` as a named argument and the content to cover positionally, and returns the covered content:

```typst
#let my-cover(self: none, body) = block(hide(body))

config-methods(cover: my-cover)
```

### Announce what your method does

Touying needs to know whether your method *removes* or *hides* the content it covers or merely *restyles* it, because that changes how a covered footnote has to be rendered:

- A method that removes content must not create a real footnote at all — the entry would appear below the separator line while the content it belongs to is still hidden. Touying draws a placeholder marker instead, reserving the same width.
- A method that only restyles should create the real footnote and let it be dimmed along with everything else.

So answer `utils.cover-kind-query` when you are asked for it:

```typst
#let my-cover(self: none, body) = if self == utils.cover-kind-query {
  "hide"
} else {
  block(hide(body))
}
```

Return `"hide"` if your method removes/hides content, `"recolour"` if it restyles it, or `"paint"` if it draws over it.

Every method touying ships answers this. A method that does not answer is guessed at from what it returns, which recognizes a plain `hide` but not one wrapped in a `block` or `place` — which is why announcing is worth the one line.

### Customizing footnote markers

Use `config-common(footnote-style: ..)`, i.e. the function you would otherwise pass to `show footnote: ..`. Touying installs it as `show footnote: footnote-style` and also uses it to draw the placeholder marker described above, so real footnotes and placeholders stay visually consistent. A `show footnote: it => ..` rule you write yourself would only reach real, revealed footnotes, not the placeholder.
