---
sidebar_position: 2
---

# 复杂动画

得益于 [Polylux](https://polylux.dev/book/dynamic/syntax.html) 提供的语法，我们同样能够在 Touying 中使用 `only`、`uncover` 和 `alternatives`。


## 标记风格的函数

我们可以使用标记风格的函数，用起来十分方便。

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
At subslide #touying-fn-wrapper-raw((self: none) => str(self.subslide)), we can

use #uncover("2-")[`#uncover` function] for reserving space,

use #only("2-")[`#only` function] for not reserving space,

#alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
```

但是这种方式并非在所有情况下都能生效，例如你将 `uncover` 放入 `context` 表达式中，就会报错。


## 在标记风格的函数内部使用动画

上面的例子里，我们用 `touying-fn-wrapper-raw` 在标记风格的写法中取到了 `self`。它的回调必须写成 `(self: none) => ..` 的形式，写成 `(self) => ..` 会报错 the argument `self` is positional。

与 `touying-fn-wrapper` 不同，`touying-fn-wrapper-raw` 不会脱离 pause 流程，它的正文会像普通的幻灯片内容一样被解析。因此 `#pause`、`#meanwhile` 以及 `#only`、`#uncover`、`#effect` 都可以写在它的内部，多个 `touying-fn-wrapper-raw` 之间也可以相互嵌套。基于它实现的函数（例如 `#alert`）同样如此：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #alert[First #pause Second #uncover("3-")[Third]]

  #pause

  Fourth
]
```

这张幻灯片有 4 张 subslides。`touying-fn-wrapper` 的行为则不同：它会把自己的位置参数原样交给被包装的函数，不做任何解析，因此其中的 `#pause` 或嵌套的 `#uncover` 到达那个函数时，只是一个未被解析的 metadata 标记，touying 会报 *Unsupported mark* 而 panic。因此在大多数情况下 `touying-fn-wrapper-raw` 都是更好的选择；只有在你确实需要 `last-subslide` 或 `repetitions` 时，才应该选用 `touying-fn-wrapper`。

:::note[给主题作者的提示]

body 必须作为 `touying-fn-wrapper-raw` 的*位置*参数传入，这一点才会成立。如果你用 `.with(..)` 把它固化进被包装的函数里，解析器就看不到它了，其内部的动画函数会 panic：

```typst
// body 对解析器不可见——其内部的 #pause 和 #uncover 会 panic。
#let my-block(title: none, it) = touying-fn-wrapper-raw(_my-block.with(title: title, it))

// body 会像普通幻灯片内容一样被解析——动画在其内部可以正常工作。
#let my-block(title: none, it) = touying-fn-wrapper-raw(_my-block.with(title: title), it)
```

:::

## 回调风格的函数

为了避免上文提到的布局函数的限制，Touying 利用回调函数巧妙实现了总是能生效的 `only`、`uncover` 和 `alternatives`，具体来说，您要这样引入这三个函数：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  At subslide #self.subslide, we can

  use #uncover("2-")[`#uncover` function] for reserving space,

  use #only("2-")[`#only` function] for not reserving space,

  #alternatives[call `#only` multiple times \u{2717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
])
```

注意到了吗？我们不再是传入一个内容块，而是传入了一个参数为 `self` 的回调函数，随后我们通过

```typst
#let (uncover, only, alternatives) = utils.methods(self)
```

从 `self` 中取出了 `only`、`uncover` 和 `alternatives` 这三个函数，并在后续调用它们。

这里还有一些有趣的事实，例如 int 类型的 `self.subslide` 指示了当前 subslide 索引，而实际上 `only`、`uncover` 和 `alternatives` 函数也正是依赖 `self.subslide` 实现的获取当前 subslide 索引。

:::warning[警告]

我们手动指定了参数 `repeat: 3`，这代表着显示 3 张 subslides，我们需要手动指定是因为 Touying 无法探知回调风格 `only`、`uncover` 和 `alternatives` 需要显示多少张 subslides。

:::

## only

`only` 函数表示只在选定的 subslides 中「出现」，如果不出现，则会完全消失，也不会占据任何空间。也即 `#only(index, body)` 要么为 `body` 要么为 `none`。

其中 index 可以是 int 类型，也可以是 `"2-"` 或 `"2-3"` 这样的 str 类型，更多用法可以参考 [Polylux](https://polylux.dev/book/dynamic/complex.html)。

为方便使用，我们还支持 `auto`，它使用遇到 `only` 时的当前 subslide 位置；`"h"` 也是如此，但它是字符串，以及其派生形式：`"h-"` 和 `"-h"`。
此外，我们还允许通过 `"!"` 进行反转。只需写 `"!h"` 或 `"!2-4"` 即可获取除这些 subslides 外的所有 subslides。与正常索引相反，反转不会增加 subslide 计数。

关于如何使用路标，请参阅关于[路标](./waypoints.md)的专门章节。

## uncover

`uncover` 函数表示只在选定的 subslides 中「显示」，否则会被 `cover` 函数遮挡，但仍会占据原有。也即 `#uncover(index, body)` 要么为 `body` 要么为 `cover(body)`。

其中 index 可以是 int 类型，也可以是 `"2-"` 或 `"2-3"` 这样的 str 类型，更多用法可以参考 [Polylux](https://polylux.dev/book/dynamic/complex.html)。\
但您也可以使用上面为 `only` 展示的其他选项。

您应该也注意到了，事实上 `#pause` 也使用了 `cover` 函数，只是提供了更便利的写法，实际上它们的效果基本上是一致的。


## alternatives

`alternatives` 函数表示在不同的 subslides 中展示一系列不同的内容，例如

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide(repeat: 3, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #alternatives[Ann][Bob][Christopher]
  likes
  #alternatives[chocolate][strawberry][vanilla]
  ice cream.
])
```

如你所见，`alternatives` 能够自动撑开到最合适的宽度和高度，这是 `only` 和 `uncover` 所没有的能力。事实上 `alternatives` 还有着其他参数，例如 `start: 2`、`repeat-last: true` 和 `position: center + horizon` 等，更多用法可以参考 [Polylux](https://polylux.dev/book/dynamic/alternatives.html)。

## animate

`only`、`uncover` 和 `alternatives` 各自只做一件事。`#animate` 则允许你为同一段内容附加多个效果，并指定每个效果分别在哪些子幻灯片上生效。

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #animate(
    [The same words, three ways.],
    effects: (
      (effect: "cover", subslides: 1),
      (effect: (body, ..) => text(fill: blue, body), subslides: 2),
      (effect: (body, ..) => text(fill: red, strong(body)), subslides: "3-"),
    ),
  )
]
```

每个效果都是一个带有三个键的字典。`effect` 是要执行的操作，`subslides` 表示何时生效（用法与 `uncover` 完全相同），`priority` 用来打破平局。`subslides` 默认为 `"1-"`，`priority` 默认为 `1`。

### 两类效果

效果分为两类，它们的组合方式并不相同。

**Placement（位置类）** 决定内容是否出现：字符串 `"cover"`、`"remove"`、`"show"`，以及函数 `swap(..)`。每张子幻灯片上恰好生效一个 placement，因此它们之间不会叠加。**Style（样式类）** 是你传入的任意函数，它们会全部生效，并相互嵌套。

一个 style 函数接受 `(body, ..)` 并返回内容。单纯的 `text.with(fill: red)` 是不够的，因为 touying 调用它时还会传入一个具名的 `self`，以便你根据子幻灯片或其他配置作出判断；请写成 `(body, ..) => text(fill: red, body)`。cover 方法本身可以直接当作 style 使用，因此 `utils.alpha-changing-cover` 就是一个合法的效果。

### 谁会生效

每个 `#animate` 都会隐式地在 priority `0` 处附带一个 `"show"` placement 作为起点，因此只要你自己写了任何一个 placement，就会替换掉它。在某张子幻灯片上生效的所有 placement 里，priority 最高的胜出，平局时以最后写的那个为准。对 style 而言，priority 只决定嵌套顺序：priority 越低越靠内层，同一 priority 内以最后写的那个为最内层，因此它会覆盖两者都设置过的属性。

两类效果遵循同一条规则：**你最后写的那个效果胜出**——对 placement 而言是被采用，对 style 而言是位于最内层。

### animate-hidden 和 animate-removed

`#animate-hidden(..)` 和 `#animate-removed(..)` 就是 `#animate`，只不过在你的效果之下、以 priority `0` 预先垫了一个 `"cover"` 或 `"remove"` placement。如果你只是需要内容一开始被隐藏或移除，这两个是对应的简写形式。

### 空间

`"cover"` 会保留内容占据的空间，`"remove"` 则不保留任何空间，和 `uncover`、`only` 的行为完全一致。

`swap(replacement)` 会把别的内容放在原处，并让版式重新排布。加上 `swap(replacement, stretch: true)` 后，替换内容会改为占据原先保留的空间，这样这个区块在每张子幻灯片上都保持同一个尺寸，效果与 `alternatives` 相同。

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#slide[
  #animate(
    [before],
    effects: ((effect: swap([after], stretch: true), subslides: "2-"),),
  )
]
```

## touying-render

`#touying-render(body, subslides: ..)` 会把一段内容渲染到你选定的某几个动画阶段，无论你把它写在哪里。内容照常带有动画效果，但由你决定哪些帧会出现：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
#let steps = [first #pause second #pause third]

== The Steps
#steps

== Just the Middle
#touying-render(steps, subslides: 2, base: 1)
```

`subslides` 接受和 `uncover` 相同的写法，包括 `"2-4"` 这样的范围以及表示当前位置的 `"h"`，它也可以一次步进整个范围而不只是单个帧。`base:` 设定内容据以计数的子幻灯片起点，`start:` 和 `repeat-last:` 的行为与 `alternatives` 中的同名参数一致。

对于自成一体的内容，请显式传入 `base:`。若使用 `base: auto`，内容会从外层幻灯片自身的动画开始计数，这正是 `"h"` 所需要的行为，但对其他情况而言则很少是你想要的。

`subslides` 中的 waypoint 标签指向被渲染内容自身的 waypoint，这与 `touying-recall` 的行为一致。若想改为指向外层幻灯片的 waypoint，请传入 `use-outer-waypoints: true`。

## touying-recall

`touying-render` 接受的是你存在变量里的内容，而 `#touying-recall(<label>)` 接受的则是文档中已经存在于某处的内容。这个 label 必须挂在一个自身带有子幻灯片的对象上，比如一个内部含有 `#pause` 的带标签代码块，或者一个带标签的 `touying-reducer`：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme
== The Construction
#box[the frame #pause and the inscribed circle]<fig>

== Later
At its first stage that was #touying-recall(<fig>, subslides: 1).
```

`subslides` 用来挑选阶段，`base:` 的含义与上文相同。这正是让一张带动画的图表可以在[文章模式](../../integration/article-mode)中派上用场的原因——否则在文章里就只会留下最后一帧。

## Callback-style variants

当然，所有函数在 `utils` 中都有对应的回调风格版本。如果你无法使用或者不想使用这些自计数的动画函数，可以改用它们。

