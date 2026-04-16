---
sidebar_position: 3
---

# Dewdrop 主题

这个主题的灵感来自 Zhibo Wang 创作的 [BeamerTheme](https://github.com/zbowang/BeamerTheme)，由 [OrangeX4](https://github.com/OrangeX4) 改造而来。

这个主题拥有优雅美观的 navigation，包括 `sidebar` 和 `mini-slides` 两种模式。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.1": *
#import themes.dewdrop: *

#import "@preview/numbly:0.1.0": numbly

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
  ),
)

#title-slide()

#outline-slide()
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `navigation`: 导航栏样式，可以是 `"sidebar"`、`"mini-slides"` 和 `none`，默认为 `"sidebar"`。
- `sidebar`: 侧边导航栏设置，默认为 `(width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true)`。
- `mini-slides`: mini-slides 设置，默认为 `(height: 4em, x: 2em, display-section: false, display-subsection: true, short-heading: true)`。
  - `height`: mini-slides 高度，默认为 `2em`。
  - `x`: mini-slides 的 x 轴 padding，默认为 `2em`。
  - `section`: 是否显示 section 之后，subsection 之前的 slides，默认为 `false`。
  - `subsection`: 是否根据 subsection 分割 mini-slides，设置为 `false` 挤压为一行，默认为 `true`。
- `footer`: 展示在页脚的内容，默认为 `[]`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。
- `primary`: primary 颜色，默认为 `rgb("#0c4842")`。
- `alpha`: 透明度，默认为 `70%`。

并且 Dewdrop 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Dewdrop 默认使用了

```typc
config-colors(
  neutral-darkest: rgb("#000000"),
  neutral-dark: rgb("#202020"),
  neutral-light: rgb("#f3f3f3"),
  neutral-lightest: rgb("#ffffff"),
  primary: primary,
)
```

颜色主题，你可以通过 `config-colors()` 对其进行修改。

## slide 函数族

Dewdrop 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(extra: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `extra` 参数，显示额外的信息。

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: cols,
)[
  ...
]
```
默认拥有导航栏和页脚的普通 slide 函数，页脚为您设置的页脚。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary`。

## 示例

```example
#import "@preview/touying:0.7.1": *
#import themes.dewdrop: *

#import "@preview/numbly:0.1.0": numbly

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()

= Section A

== Subsection A.1

$ x_(n+1) = (x_n + a/x_n) / 2 $

== Subsection A.2

A slide without a title but with *important* infos

= Section B

== Subsection B.1

#lorem(80)

#focus-slide[
  Wake up!
]

== Subsection B.2

We can use `#pause` to #pause display something later.

#pause

Just like this.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to #pause display other content synchronously.

#show: appendix

= Appendix

== Appendix

Please pay attention to the current slide number.
```

