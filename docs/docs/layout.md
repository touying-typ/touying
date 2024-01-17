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

`title` 和 `subtitle` 既能接受内容块，也能接收形如 `([title], [short-title])` 格式的数组或 `(title: [title], short-title: [short-title])` 格式的字典。`short-title` 会在一些特殊场景下用到，例如会在 `dewdrop` 主题的 navigation 中用到。

`date` 可以接收 `datetime` 格式和 `content` 格式，并且 `datetime` 格式的日期显示格式，可以通过 `#let s = (s.methods.datetime-format)(self: s, "[year]-[month]-[day]")` 方式更改。

:::tip[原理]

在这里，我们会稍微引入一点 Touying 的 OOP 概念。

您应该知道，Typst 是一个支持增量渲染的排版语言，也就是说，Typst 会缓存之前的函数调用结果，这就要求 Typst 里只有纯函数，因此我们很难真正意义上地像 LaTeX 那样修改一个全局变量。即使是使用 `state` 或 `counter`，也需要使用 `locate` 与回调函数来获取里面的值，实际上这会对性能有很大的影响。

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

:::

