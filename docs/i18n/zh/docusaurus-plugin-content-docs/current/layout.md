---
sidebar_position: 3
---

# 排篇布局

为了更好地掌管 slides 里的每一处细节，并得到更好的渲染结果，就像 Beamer 一样，Touying 不得不引入了一些 Touying 特有的概念。这能帮助您更好地维护全局信息，以及让您可以在不同的主题之间方便地切换。

## 全局信息

你可以通过

```typst
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
```

分别设置 slides 的标题、副标题、作者、日期和机构信息。

其中 `date` 可以接收 `datetime` 格式和 `content` 格式，并且 `datetime` 格式的日期显示格式，可以通过

```typst
#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")
```

的方式更改。

:::tip[原理]

在这里，我们会稍微引入一点 Touying 的 OOP 概念。

您应该知道，Typst 是一个支持增量渲染的排版语言，也就是说，Typst 会缓存之前的函数调用结果，这就要求 Typst 里只有纯函数，即无法改变外部变量的函数。因此我们很难真正意义上地像 LaTeX 那样修改一个全局变量。即使是使用 `state` 或 `counter`，也需要使用 `locate` 与回调函数来获取里面的值，且实际上这种方式会对性能有很大的影响。

Touying 并没有使用 `state` 和 `counter`，也没有违反 Typst 纯函数的原则，而是使用了一种巧妙的方式，并以面向对象风格的代码，维护了一个全局单例 `s`。在 Touying 中，一个对象指拥有自己的成员变量和方法的 Typst 字典，并且我们约定方法均有一个命名参数 `self` 用于传入对象自身，并且方法均放在 `.methods` 域里。有了这个理念，我们就不难写出更新 `info` 的方法了：

```
#let s = (
  info: (:),
  methods: (
    // update info
    info: (self: none, ..args) => {
      self.info += args.named()
      self
    },
  )
)

#let s = (s.methods.info)(self: s, title: [title])

Title is #s.info.title
```

这样，你也能够理解 `utils.methods()` 函数的用途了：将 `self` 绑定到 `s` 的所有方法上并返回，并通过解包语法简化后续的使用。

```typst
#let (init, slide, slides) = utils.methods(s)
```
:::


## 节与小节

与 Beamer 相同，Touying 同样有着 section 和 subsection 的概念。

在 `#show: slides` 模式下，section 和 subsection 分别对应着一级标题和二级标题，例如

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, slides) = utils.methods(s)
#show: init

#show: slides

= Section

== Subsection

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/600876bb-941d-4841-af5c-27137bb04c54)

不过二级标题并非总是对应 subsection，具体的映射方式因主题而异。

而在更通用的 `#slide[..]` 模式下，section 和 subsection 分别作为参数传入 `slide` 函数中，例如

```typst
#slide(section: [Let's start a new section!])[..]

#slide(subsection: [Let's start a new subsection!])[..]
```

会分别新建一个 section 和一个 subsection。当然，这种变化默认只会影响到 Touying 内部的 `sections` state，默认是不会显示在 slide 上的，具体的显示方式依主题而异。

注意，`slide` 的 `section` 和 `subsection` 参数，既能接收内容块，也能接收形如 `([title], [short-title])` 格式的数组，或 `(title: [title], short-title: [short-title])` 格式的字典。其中 `short-title` 会在一些特殊场景下用到，例如 `dewdrop` 主题的 navigation 中将会用到。


## 目录

在 Touying 中显示目录很简单：

```typst
#import "@preview/touying:0.2.1": *

#let (init, slide, touying-outline) = utils.methods(s)
#show: init

#slide[
  == Table of contents

  #touying-outline()
]
```

其中 `touying-oultine()` 的定义为：

```typst
#let touying-outline(enum-args: (:), padding: 0pt) = { .. }
```

你可以通过 `enum-args` 修改内部 enum 的参数。

如果你对目录有着复杂的自定义需求，你可以使用

```typst
#slide[
  == Table of contents

  #states.touying-final-sections(sections => ..)
]
```

## 页面管理

由于 Typst 中使用 `set page(..)` 命令，会导致创建一个新的页面，而不能修改当前页面，因此 Touying 选择在单例 `s` 中维护一个 `s.page-args` 成员变量，只在创建新 slide 时才会应用这些参数。

:::warning[警告]

因此，你不应该自己使用 `set page(..)` 命令，而是应该修改 `s` 内部的 `s.page-args` 成员变量。

:::

通过这种方式，我们可以通过 `s.page-args` 实时查询当前页面的参数，这对一些需要获取页边距或当前页面背景颜色的函数很有用，例如 `transparent-cover`。


## 页面分栏

如果你需要将页面分为两栏或三栏，你可以使用 Touying `slide` 函数默认提供的 `compose` 功能，最简单的示例如下：

```typst
#slide[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/a39f88a2-f1ba-4420-8f78-6a0fc644704e)

如果你需要更改分栏的方式，可以修改 `slide` 的 `composer` 参数，其中默认的参数是 `utils.with.side-by-side(columns: auto, gutter: 1em)`，如果我们要让左边那一栏占据剩余宽度，可以使用

```typst
#slide(composer: utils.side-by-side.with(columns: (1fr, auto), gutter: 1em))[
  First column.
][
  Second column.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/aa84192a-4082-495d-9773-b06df32ab8dc)

