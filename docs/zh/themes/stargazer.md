---
sidebar_position: 6
---

# Stargazer 主题

这个主题原本来自 [Coekjan](https://github.com/Coekjan/) 创作的 [touying-buaa](https://github.com/Coekjan/touying-buaa) 主题，美观大方，很适合日常使用。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.4": *
#import themes.stargazer: *

#import "@preview/numbly:0.1.0": numbly

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Stargazer in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()
```

其中 `stargazer-theme` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `align`: 幻灯片的对齐方式，默认为 `horizon`。
- `alpha`: 大纲中未激活（已覆盖）标题的透明度，默认为 `20%`。
- `title`: 显示在页眉的内容，默认为 `self => utils.display-current-heading(depth: self.slide-level)`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉导航栏右侧的内容，默认为 `self => self.info.logo`。
- `progress-bar`: 是否显示 slide 底部的进度条，默认为 `true`。
- `footer-columns`: 底部四栏 Footer 的宽度，默认为 `(25%, 25%, 1fr, 5em)`。
- `footer-a`: 第一栏，默认为 `self => self.info.author`。
- `footer-b`: 第二栏，默认为 `self => utils.display-info-date(self)`。
- `footer-c`: 第三栏，默认为 `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`。
- `footer-d`: 第四栏，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。

## 颜色主题

Stargazer 默认使用了

```typc
config-colors(
  primary: rgb("#005bac"),
  primary-dark: rgb("#004078"),
  secondary: rgb("#ffffff"),
  tertiary: rgb("#005bac"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

颜色主题，你可以通过 `config-colors()` 对其进行修改。

## slide 函数族

Stargazer 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(extra: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `extra` 参数，显示额外的信息。

---

```typst
#slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
)[
  ...
]
```
默认拥有标题和页脚的普通 slide 函数。`title`、`header`、`footer`、`align` 默认都是 `auto`，即沿用主题层的设置；给出非 `auto` 的值时会覆盖当前这一页对应的 `self.store` 字段。

---

```typst
#outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  numbered: true,
  level: none,
  ..args,
)
```
用于加入大纲页，`..args` 会转发给 [`components.custom-progressive-outline`](https://touying-typ.github.io/docs/reference/components/custom-progressive-outline)。

大纲页会用 `place(hide(heading(..)))` 放置一个不可见的标题，这样页眉和演讲者备注面板都能通过 `utils.display-current-heading` 取到这一页的标题；它不再改写 `self.store.title`。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary`。

---

```typst
#new-section-slide(
  config: (:),
  title: utils.i18n-outline-title,
  level: 1,
  numbered: true,
  ..args,
  body,
)
```
用给定标题开启一个新的 section，实现上就是转调 `outline-slide`。它已通过 `config-common(new-section-slide-fn: ..)` 注册，因此通常由 `= 标题` 自动触发，无需手动调用。

---

```typst
#ending-slide(config: (:), title: none, body)
```
用于结束页。给出 `title` 时会用 `self.colors.tertiary` 的色块显示它，同时放置一个不可见的标题，供页眉和演讲者备注面板取用。

---

```typst
#tblock(title: none, it)
```
Stargazer 特有的定理块，标题栏使用 `self.colors.primary-dark`，正文使用淡化后的 `self.colors.primary`。它基于 `touying-fn-wrapper-raw` 实现，因此可以正常配合 `#pause`、`#uncover` 等动画函数使用。

## 演讲者备注

Stargazer 定义了自己的 `notes` 函数，并通过 `config-common(notes-fn: notes)` 注册，因此第二屏幕和 only-notes 视图中的备注面板会沿用主题的配色。它建立在 `touying-notes` 之上，你也可以传入自己的实现来覆盖它：

```typst
#show: stargazer-theme.with(
  config-common(notes-fn: my-notes),
)
```

详见[演讲者备注](../tutorials/speaker-notes.md)。


## 示例

```example
#import "@preview/touying:0.7.4": *
#import themes.stargazer: *

#import "@preview/numbly:0.1.0": numbly

#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Stargazer in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

#outline-slide()

= Section A

== Subsection A.1

#tblock(title: [Theorem])[
  A simple theorem.

  $ x_(n+1) = (x_n + a / x_n) / 2 $
]

== Subsection A.2

A slide without a title but with *important* information.

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

