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