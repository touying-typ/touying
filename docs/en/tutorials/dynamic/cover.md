---
sidebar_position: 4
---

# Cover Function

As you already know, both `uncover` and `#pause` use the `cover` function to conceal content that is not visible. So, what exactly is the `cover` function here?

## Default Cover Function: `hide`

The `cover` function is a method stored in `s.methods.cover`, which is later used by `uncover` and `#pause`.

The default `cover` function is the [hide](https://typst.app/docs/reference/layout/hide/) function. This function makes the internal content invisible without affecting the layout.

## Updating the Cover Function

In some cases, you might want to use your own `cover` function. In that case, you can set your own `cover` function using:

```typst
config-methods(cover: (self: none, body) => hide(body))
```

## hack: handle enum and list

You will find that the existing cover function cannot hide the mark of enum and list, refer to [here](https://github.com/touying-typ/touying/issues/10), so you can hack:

```typst
config-methods(cover: (self: none, body) => box(scale(x: 0%, body)))
```

## Semi-Transparent Cover Function

Touying supports a semi-transparent cover function, which can be enabled by adding:

```typst
config-methods(cover: utils.semi-transparent-cover.with(alpha: 85%))
```

You can adjust the transparency through the `alpha: ..` parameter.

:::warning[Warning]

Note that the `transparent-cover` here does not preserve text layout like `hide` does because it adds an extra layer of `box`, which may disrupt the original structure of the page.

:::

:::tip[Internals]

The `utils.semi-transparent-cover` method is defined as:

```typst
#let semi-transparent-cover(self: none, constructor: rgb, alpha: 85%, body) = {
  cover-with-rect(
    fill: update-alpha(
      constructor: constructor,
      self.page.fill,
      alpha,
    ),
    body,
  )
}
```

It creates a semi-transparent rectangular mask with the same color as the background to simulate the effect of transparent content. Here, `constructor: rgb` and `alpha: 85%` indicate the background color's construction function and transparency level, respectively.

:::