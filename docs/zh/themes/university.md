---
sidebar_position: 4
---

# University 主题

这个美观的主题来自 [Pol Dellaiera](https://github.com/drupol)。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.6.2": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `progress-bar`: 是否显示 slide 顶部的进度条，默认为 `true`。
- `header`: 显示在页眉的内容，默认为 `utils.display-current-heading(level: 2)`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉右侧的内容，默认为 `self => self.info.logo`。
- `footer-columns`: 底部三栏 Footer 的宽度，默认为 `(25%, 1fr, 25%)`。
- `footer-a`: 第一栏，默认为 `self => self.info.author`。
- `footer-b`: 第二栏，默认为 `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`。
- `footer-c`: 第三栏，默认为

```typst
self => {
  h(1fr)
  utils.display-info-date(self)
  h(1fr)
  context utils.slide-counter.display() + " / " + utils.last-slide-number
  h(1fr)
}
```

## 颜色主题

University 默认使用了

```typc
config-colors(
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
)
```

颜色主题，你可以通过 `config-colors()` 对其进行修改。

## slide 函数族

University 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(logo: none, authors: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `logo` 参数和 array 类型的 `authors` 参数。

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: components.side-by-side,
  // university theme
  title: none,
)[
  ...
]
```
默认拥有标题和页脚的普通 slide 函数，其中 `title` 默认为当前 section title，页脚为您设置的页脚。

---

```typst
#focus-slide(background-img: ..., background-color: ...)[
  ...
]
```
用于引起观众的注意力。默认背景色为 `self.colors.primary`。

---

```typst
#new-section-slide(short-title: auto, title)
```
用给定标题开启一个新的 section。

---

```typst
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```
可以参考 [文档](https://polylux.dev/book/themes/gallery/university.html)。


## 示例

```example
#import "@preview/touying:0.6.2": *
#import themes.university: *

#import "@preview/numbly:0.1.0": numbly

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide(authors: ([Author A], [Author B]))

= The Section

== Slide Title

#lorem(40)

#focus-slide[
  Another variant with primary color in background...
]

#matrix-slide[
  left
][
  middle
][
  right
]

#matrix-slide(columns: 1)[
  top
][
  bottom
]

#matrix-slide(columns: (1fr, 2fr, 1fr), ..(lorem(8),) * 9)
```

