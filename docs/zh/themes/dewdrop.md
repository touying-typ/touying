---
sidebar_position: 3
---

# Dewdrop 主题

这个主题的灵感来自 Zhibo Wang 创作的 [BeamerTheme](https://github.com/zbowang/BeamerTheme)，由 [OrangeX4](https://github.com/OrangeX4) 改造而来。

这个主题拥有优雅美观的 navigation，包括 `sidebar` 和 `mini-slides` 两种模式。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.4": *
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

其中 `dewdrop-theme` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `navigation`: 导航栏样式，可以是 `"sidebar"`、`"mini-slides"` 和 `none`，默认为 `"sidebar"`。
- `sidebar`: 侧边导航栏设置，默认为 `(width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true)`。
- `mini-slides`: mini-slides 设置，默认为 `(height: 4em, x: 2em, display-section: false, display-subsection: true, linebreaks: true, short-heading: true)`。
  - `height`: mini-slides 高度，默认为 `4em`。
  - `x`: mini-slides 的 x 轴 padding，默认为 `2em`。
  - `display-section`: 是否显示 section 之后、subsection 之前的 slides，默认为 `false`。
  - `display-subsection`: 是否显示 subsection 中的 slides，默认为 `true`。
  - `linebreaks`: 是否在 section 与 subsection 的链接之间换行，默认为 `true`。
  - `short-heading`: 是否使用标题的短版本，默认为 `true`。
  - `inline`: 圆点是否与 section/subsection 标签排在同一行，默认为 `false`。
- `footer`: 展示在页脚的内容，默认为 `none`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。
- `primary`: primary 颜色，默认为 `rgb("#0c4842")`。
- `alpha`: 大纲中未激活（已覆盖）标题的透明度，默认为 `60%`。
- `subslide-preamble`: 每一页正文之前插入的内容，默认为 `self => block(text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level, style: auto)))`，即当前 slide-level 的标题；传入 `none` 可以去掉它。

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
  composer: auto,
)[
  ...
]
```
默认拥有导航栏和页脚的普通 slide 函数，页脚为您设置的页脚。

---

```typst
#outline-slide(config: (:), title: utils.i18n-outline-title, ..args)
```
显示一个大纲页，`..args` 会转发给内置的 `outline`。

大纲页会用 `place(hide(heading(..)))` 放置一个不可见的标题，这样页眉和演讲者备注面板都能通过 `utils.display-current-heading` 取到这一页的标题。

---

```typst
#new-section-slide(config: (:), title: utils.i18n-outline-title, ..args, body)
```
用给定标题开启一个新的 section，显示一个高亮当前 section 的渐进式大纲。它已通过 `config-common(new-section-slide-fn: ..)` 注册，因此通常由 `= 标题` 自动触发，无需手动调用。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary`。

## 演讲者备注

Dewdrop 定义了自己的 `notes` 函数，并通过 `config-common(notes-fn: notes)` 注册，因此第二屏幕和 only-notes 视图中的备注面板会沿用主题的配色。它建立在 `touying-notes` 之上，你也可以传入自己的实现来覆盖它：

```typst
#show: dewdrop-theme.with(
  config-common(notes-fn: my-notes),
)
```

详见[演讲者备注](../tutorials/speaker-notes.md)。

## 示例

```example
#import "@preview/touying:0.7.4": *
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

