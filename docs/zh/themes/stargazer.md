---
sidebar_position: 6
---

# Stargazer 主题

这个主题原本来自 [Coekjan](https://github.com/Coekjan/) 创作的 [touying-buaa](https://github.com/Coekjan/touying-buaa) 主题，美观大方，很适合日常使用。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.0": *
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
- `alpha`: 幻灯片的透明度，默认为 `20%`。
- `title`: 显示在页眉的内容，默认为 `utils.display-current-heading()`，也可以传入形如 `self => self.info.title` 的函数。
- `progress-bar`: 是否显示 slide 底部的进度条，默认为 `true`。
- `footer-columns`: 底部三栏 Footer 的宽度，默认为 `(25%, 25%, 1fr, 5em)`。
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
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: components.side-by-side,
  // stargazer theme
  title: auto,
  footer: auto,
  align: horizon,
)[
  ...
]
```
默认拥有标题和页脚的普通 slide 函数，其中 `title` 默认为当前 section title，页脚为您设置的页脚。

---

```typst
#outline-slide[
  ...
]
```
用于加入大纲页。

---

```typst
#focus-slide[
  ...
]
```
用于引起观众的注意力。背景色为 `self.colors.primary-dark`。

---

```typst
#new-section-slide(short-title: auto, title)
```
用给定标题开启一个新的 section。


## 示例

```example
#import "@preview/touying:0.7.0": *
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

