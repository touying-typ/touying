---
sidebar_position: 1
---

# Simple 主题

这个主题来源于 [Polylux](https://polylux.dev/book/themes/gallery/simple.html)，作者是 Andreas Kröpelin。

这个主题被认为是一个相对简单的主题，你可以用它来创建一个简单 slides，并且可以随意加入你喜欢的功能。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.6.3": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Simple slides],
)
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `header`: 显示在页眉的内容，默认为 `utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%))`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉右侧的内容，默认为 `self => self.info.logo`。
- `footer`: 展示在页脚的内容，默认为 `[]`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。
- `primary`: 主题颜色，默认为 `aqua.darken(50%)`。
- `subslide-preamble`: 默认往当前 slide 加入 subsection 的标题。


## slide 函数族

simple 主题提供了一系列自定义 slide 函数：

```typst
#centered-slide(section: ..)[
  ...
]
```
内容位于幻灯片中央的幻灯片，`section` 参数可以用于新建一个 section。

---

```typst
#title-slide[
  ...
]
```

和 `centered-slide` 相同，这里只是为了保持和 Polylux 语法上的一致性。

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: components.side-by-side,
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


## 示例

```example
#import "@preview/touying:0.6.3": *
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

