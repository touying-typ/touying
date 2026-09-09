---
sidebar_position: 1
---

# Simple 主题

这个主题来源于 [Polylux](https://polylux.dev/book/themes/gallery/simple.html)，作者是 Andreas Kröpelin。

这个主题被认为是一个相对简单的主题，你可以用它来创建一个简单 slides，并且可以随意加入你喜欢的功能。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)
```

其中 `simple-theme` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `header`: 显示在页眉的内容，默认为 `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), level: 1, depth: self.slide-level)`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉右侧的内容，默认为 `self => self.info.logo`。
- `footer`: 展示在页脚的内容，默认为 `none`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。
- `primary`: 主题颜色，默认为 `aqua.darken(50%)`。
- `subslide-preamble`: 每一页正文之前插入的内容，默认为 `block(below: 1.5em, text(1.2em, weight: "bold", utils.display-current-heading(level: 2)))`，即往当前 slide 加入 subsection 的标题；传入 `none` 可以去掉它。


## slide 函数族

simple 主题提供了一系列自定义 slide 函数：

```typst
#centered-slide(config: (:), setting: body => body, ..args)[
  ...
]
```
内容位于幻灯片中央的幻灯片。若要新建一个 section，请直接写 `= 标题`，或调用下面的 `#new-section-slide`。

---

```typst
#title-slide(config: (:), body)[
  ...
]
```

和 `centered-slide` 相同（只是额外冻结了页码计数器），这里主要是为了保持和 Polylux 语法上的一致性。

---

```typst
#new-section-slide(config: (:), body)
```

一个居中的 section 分隔页，显示当前一级标题。它已通过 `config-common(new-section-slide-fn: ..)` 注册，因此通常由 `= 标题` 自动触发，无需手动调用。

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
)[
  ...
]
```
默认拥有页眉和页脚的普通 slide 函数，其中页眉为当前 section，页脚为您设置的页脚。

---

```typst
#focus-slide(foreground: ..., background: ...)[
  ...
]
```
用于引起观众的注意力。可选接受一个前景色 (默认为 `white`) 和一个背景色 (默认为 `auto`，即 `self.colors.primary`)。

## 演讲者备注

Simple 定义了自己的 `notes` 函数，并通过 `config-common(notes-fn: notes)` 注册，因此第二屏幕和 only-notes 视图中的备注面板会沿用主题的配色。它建立在 `touying-notes` 之上，你也可以传入自己的实现来覆盖它：

```typst
#show: simple-theme.with(
  config-common(notes-fn: my-notes),
)
```

详见[演讲者备注](../tutorials/speaker-notes.md)。


## 示例

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)
  Bravo #footnote[Uni Bayreuth] #h(1em)
  Charlie #footnote[Uni Chemnitz] #h(1em)

  July 23
]

== First slide

#lorem(20)

#focus-slide[
  _Focus!_

  This is very important.
]

= Let's start a new section!

== Dynamic slide

Did you know that...

#pause

...you can see the current section at the top of the slide?
```

