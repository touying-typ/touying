---
sidebar_position: 2
---

# Metropolis 主题


这个主题的灵感来自 Matthias Vogelgesang 创作的 [Metropolis beamer](https://github.com/matze/mtheme) 主题，由 [Enivex](https://github.com/Enivex) 改造而来。

这个主题美观大方，很适合日常使用，并且你最好在电脑上安装 Fira Sans 和 Fira Math 字体，以取得最佳效果。


## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.6.3": *
#import themes.metropolis: *

#import "@preview/numbly:0.1.0": numbly

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.city,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
```

其中 `metropolis-theme` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `align`: 幻灯片的对齐方式，默认为 `horizon`。
- `header`: 显示在页眉的内容，默认为 `utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%))`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉右侧的内容，默认为 `self => self.info.logo`。
- `footer`: 展示在页脚的内容，默认为 `[]`，也可以传入形如 `self => self.info.author` 的函数。
- `footer-right`: 展示在页脚右侧的内容，默认为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。
- `footer-progress`: 是否显示 slide 底部的进度条，默认为 `true`。

并且 Metropolis 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

Metropolis 默认使用了

```typc
config-colors(
  primary: rgb("#eb811b"),
  primary-light: rgb("#d6c6b7"),
  secondary: rgb("#23373b"),
  neutral-lightest: rgb("#fafafa"),
  neutral-dark: rgb("#23373b"),
  neutral-darkest: rgb("#23373b"),
)
```

颜色主题，你可以通过 `config-colors()` 对其进行修改。

## slide 函数族

Metropolis 主题提供了一系列自定义 slide 函数：

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
  // metropolis theme
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
#import "@preview/touying:0.6.3": *
#import themes.metropolis: *

#import "@preview/numbly:0.1.0": numbly

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.city,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()

= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 1)

= First Section

---

A slide without a title but with some *important* information.

== A long long long long long long long long long long long long long long long long long long long long long long long long Title

=== sdfsdf

A slide with equation:

$ x_(n+1) = (x_n + a/x_n) / 2 $

#lorem(200)

= Second Section

#focus-slide[
  Wake up!
]

== Simple Animation

We can use `#pause` to #pause display something later.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.

#speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)`
]

#show: appendix

= Appendix

---

Please pay attention to the current slide number.
```

