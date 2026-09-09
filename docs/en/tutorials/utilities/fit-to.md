---
sidebar_position: 1
---

# Fit to Height / Width

Thanks to [ntjess](https://github.com/ntjess) for the code.

## Fit to Height

If you need to make an image fill the remaining slide height, you can try the `fit-to-height` function:

```typst
#utils.fit-to-height(1fr)[BIG]
```

Function definition:

```typst
#let fit-to-height(
  height: 1fr,
  width: auto,
  prescale-width: none,
  grow: true,
  shrink: true,
  reflow: true,
  force-height: false,
  body,
  ..args,
) = { .. }
```

Parameters:

- `height`: The height to fit the content to, default is `1fr`, i.e. fill the remaining available height. Can be a `length`, `fraction` or `relative`, e.g. `height: 50%` takes half of the slide height.
- `width`: If specified, this will determine the width of the content after scaling. So, if you want the scaled content to fill half of the slide width, you can use `width: 50%`. Default is `auto`.
- `prescale-width`: This parameter allows you to make Typst's layout assume that the given content is to be laid out in a container of a certain width before scaling. For example, you can use `prescale-width: 200%` assuming the slide's width is twice the original.
- `grow`: Whether the content is scaled up when it is smaller than the available height, default is `true`.
- `shrink`: Whether the content is scaled down when it is larger than the available height, default is `true`.
- `reflow`: Whether to allow text to be re-broken into lines while scaling, default is `true`. Only takes effect when `width` is `auto` and the body contains text.
- `force-height`: Whether to force the content to occupy the full height instead of letting it fill the available width, default is `false`. Only matters when `reflow` is `true` and `width` is `auto`. Once text is reflowed, using as much width as possible is usually the better choice: line counts are discrete, so the usable scaling factors are discrete too, and forcing the height may leave the text not filling the available width.
- `body`: The specific content.
- `..args`: For compatibility with older versions, passing the height as a positional argument is still supported, e.g. `#utils.fit-to-height(1fr)[BIG]`.

## Fit to Width

If you need to limit the title width to exactly fill the slide width, you can try the `fit-to-width` function:

```typst
#utils.fit-to-width(1fr)[#lorem(20)]
```

Function definition:

```typst
#let fit-to-width(width: 1fr, grow: true, shrink: true, body, ..args) = { .. }
```

Parameters:

- `width`: The width to fit the content to, default is `1fr`, i.e. fill the remaining available width. Can be a `length`, `fraction` or `relative`, e.g. `width: 50%` takes half of the slide width.
- `grow`: Whether the content is scaled up when it is smaller than the available width, default is `true`.
- `shrink`: Whether the content is scaled down when it is larger than the available width, default is `true`.
- `body`: The specific content.
- `..args`: For compatibility with older versions, passing the width as a positional argument is still supported, e.g. `#utils.fit-to-width(1fr)[#lorem(20)]`.

## Practical Example: Fitting a Table to the Slide

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-height(1fr)[
    #table(
      columns: (1fr, 1fr, 1fr),
      [A], [B], [C],
      [1], [2], [3],
      [4], [5], [6],
    )
  ]
]
```

## Fitting a Heading to Full Width

```example
>>> #import "@preview/touying:0.7.4": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #utils.fit-to-width(1fr)[
    #text(weight: "bold")[A Very Long Presentation Title That Should Fill the Entire Slide Width]
  ]
]
```
