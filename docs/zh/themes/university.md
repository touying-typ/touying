---
sidebar_position: 4
---

# University 主题

这个美观的主题来自 [Pol Dellaiera](https://github.com/drupol)。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.7.4": *
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
    contact: [contact\@mail.com],
    logo: emoji.school,
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
```

其中 `university-theme` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `align`: 幻灯片的对齐方式，默认为 `top`。
- `progress-bar`: 是否显示 slide 顶部的进度条，默认为 `true`。
- `header`: 显示在页眉的内容，默认为 `utils.display-current-heading(level: 2, style: auto)`，也可以传入形如 `self => self.info.title` 的函数。
- `header-right`: 展示在页眉右侧的内容，默认为 `self => box(utils.display-current-heading(level: 1)) + h(.3em) + self.info.logo`，即当前一级标题加上 logo。
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
#title-slide(config: (:), extra: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `extra` 参数显示额外的信息。`..args` 里的具名参数会覆盖 `self.info` 中的同名字段，因此也可以直接传入 `logo` 或 array 类型的 `authors`。

---

```typst
#slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
)[
  ...
]
```
默认拥有页眉和页脚的普通 slide 函数。`#slide` 本身没有 `title` 参数：页眉由主题的 `header` 参数决定，默认显示当前二级标题。`align` 默认为 `auto`，即沿用主题的 `align` 参数（默认 `top`）。

---

```typst
#new-section-slide(config: (:), level: 1, numbered: true, body)
```

用给定标题开启一个新的 section。它已通过 `config-common(new-section-slide-fn: ..)` 注册，因此通常由 `= 标题` 自动触发，无需手动调用。

### Focus Slide

```typst
#focus-slide(background-img: ..., background-color: ...)[
  ...
]
```

用于引起观众的注意力。`background-color` 和 `background-img` 默认都是 `none`，此时背景色取 `self.colors.primary`。

### Matrix Slide

```typst
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```
可以参考 [文档](https://polylux.dev/book/themes/gallery/university.html)。

## 演讲者备注

University 定义了自己的 `notes` 函数，并通过 `config-common(notes-fn: notes)` 注册，因此第二屏幕和 only-notes 视图中的备注面板会沿用主题的配色。它建立在 `touying-notes` 之上，你也可以传入自己的实现来覆盖它：

```typst
#show: university-theme.with(
  config-common(notes-fn: my-notes),
)
```

详见[演讲者备注](../tutorials/speaker-notes.md)。


## 示例

```example
#import "@preview/touying:0.7.4": *
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
    contact: [contact\@mail.com],
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

