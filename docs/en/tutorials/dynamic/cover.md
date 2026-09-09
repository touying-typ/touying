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

If your custom method genuinely hides its content (footnotes included), set `config-common(cover-hides-footnote: true)`. See [Footnotes and the Cover Function](#footnotes-and-the-cover-function) below for why this matters.

## Alpha-Changing Cover Function

Touying supports a semi-transparent cover function, which can be enabled by adding:

```typst
config-methods(cover: utils.alpha-changing-cover)
```

You can adjust the transparency through the `alpha: ..` parameter.


:::tip[Internals]

The `utils.alpha-changing-cover` method works by changing all colors it encounters to have a lower alpha value. This can be costly because we need to access typst's context at every level of nested style or context.

If you notice your project compiling slowly you can try switching to `utils.color-changing-cover` which just makes everything grey.

Both methods cannot change all colors displayed. Some contents like images or tilings cannot be interfered with. As such both methods utilize a fallback hide which aims to mimic the same effect by overlaying the content with a grey semi-transparent rectangle via `utils.semi-transparent-rect`. Using that function as default is no longer recommended as it has multiple not to be fixed bugs. 

:::


## Footnotes and the Cover Function

`cover-hides-footnote` defaults to `auto`: only touying's own default `cover` method is treated as genuinely hiding its content, and every other method is treated as visual-only. This decides how a footnote covered by `#pause` is rendered:

- A genuinely-hiding cover method must not create a real footnote at all. The entry would show up under the separator line while the content it belongs to is still hidden, so touying draws a placeholder marker instead, reserving the same width.
- A visual-only cover method (`utils.alpha-changing-cover`, `utils.color-changing-cover`) does create the real footnote; it is merely recolored or de-emphasized along with the rest of the covered content.

Typst cannot inspect what an arbitrary `cover` function does, so `auto` can only recognize touying's own default method **by identity**: it compares `self.methods.cover` against `utils.hiding-cover`. A hand-written wrapper such as `(self: none, body) => hide(body)` is a different function value even though it behaves identically, so `auto` classifies it as visual-only, and footnotes inside covered content become real footnotes that appear before the reveal. Either use `utils.hiding-cover` itself, or say so explicitly:

```typst
config-common(cover-hides-footnote: true)
```

`false` forces the opposite, so a hiding cover method will emit real footnotes anyway.

If you want to customize how footnote markers look, use `config-common(footnote-style: ..)`, i.e. the function you would otherwise pass to `show footnote: ..`. Touying installs it as `show footnote: footnote-style` and also uses it to draw the placeholder marker described above, so real footnotes and placeholders stay visually consistent. A `show footnote: it => ..` rule you write yourself would only reach real, revealed footnotes, not the placeholder.
