---
sidebar_position: 2
---

# Complex Animations

Thanks to the syntax provided by [Polylux](https://polylux.dev/book/dynamic/syntax.html), we can also use `only`, `uncover`, and `alternatives` in Touying.

## Callback-Style Functions

To overcome the limitations of `styled` and `layout` mentioned earlier, Touying cleverly implements always-effective `only`, `uncover`, and `alternatives` using callback functions. Specifically, you need to introduce these three functions as follows:

```typst
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  In subslide #self.subslide,

  test #uncover("2-")[uncover] function,

  and test #only("2-")[only] function,

  #pause

  and paused text.
])
```

![image](https://github.com/touying-typ/touying/assets/34951714/e9a6b8c5-daf0-4cf2-8d39-1a768ce1dfea)

Notice that we no longer pass a content block but instead pass a callback function with a `self` parameter. Later, we extract `only`, `uncover`, and `alternatives` functions from `self` using:

```typst
#let (uncover, only, alternatives) = utils.methods(self)
```

We then call these functions in subsequent steps.

Here's an interesting fact: the `self.subslide` of type int indicates the current subslide index, and in fact, the `only`, `uncover`, and `alternatives` functions rely on `self.subslide` to determine the current subslide index.

:::warning[Warning]

We manually specify the `repeat: 3` parameter, indicating the display of 3 subslides. We need to do this manually because Touying cannot infer how many subslides `only`, `uncover`, and `alternatives` should display.

:::

## only

The `only` function means it "appears" only on selected subslides. If it doesn't appear, it completely disappears and doesn't occupy any space. In other words, `#only(index, body)` is either `body` or `none`.

The index can be an int type or a str type like `"2-"` or `"2-3"`. For more usage, refer to [Polylux](https://polylux.dev/book/dynamic/complex.html).

## uncover

The `uncover` function means it "displays" only on selected subslides; otherwise, it will be covered by the `cover` function but still occupies the original space. In other words, `#uncover(index, body)` is either `body` or `cover(body)`.

The index can be an int type or a str type like `"2-"` or `"2-3"`. For more usage, refer to [Polylux](https://polylux.dev/book/dynamic/complex.html).

You may also have noticed that `#pause` actually uses the `cover` function, providing a more convenient syntax. In reality, their effects are almost identical.

## alternatives

The `alternatives` function displays a series of different content in different subslides. For example:

```typst
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #alternatives[Ann][Bob][Christopher]
  likes
  #alternatives[chocolate][strawberry][vanilla]
  ice cream.
])
```

![image](https://github.com/touying-typ/touying/assets/34951714/392707ea-0bcd-426b-b232-5bc63b9a13a3)

As you can see, `alternatives` can automatically expand to the most suitable width and height, a capability that `only` and `uncover` lack. In fact, `alternatives` has other parameters, such as `start: 2`, `repeat-last: true`, and `position: center + horizon`. For more usage, refer to [Polylux](https://polylux.dev/book/dynamic/alternatives.html).