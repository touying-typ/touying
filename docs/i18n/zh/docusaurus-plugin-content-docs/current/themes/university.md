---
sidebar_position: 4
---

# University 主题

![image](https://github.com/touying-typ/touying/assets/34951714/4095163c-0c16-4760-b370-8adc1cdd7e6c)

这个美观的主题来自 [Pol Dellaiera](https://github.com/drupol)。

## 初始化

你可以通过下面的代码来初始化：

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides
```

其中 `register` 接收参数:

- `aspect-ratio`: 幻灯片的长宽比为 "16-9" 或 "4-3"，默认为 "16-9"。
- `progress-bar`: 是否显示 slide 顶部的进度条，默认为 `true`。

并且 University 主题会提供一个 `#alert[..]` 函数，你可以通过 `#show strong: alert` 来使用 `*alert text*` 语法。

## 颜色主题

University 默认使用了

```typst
#let store = (store.methods.colors)(
  self: store,
  primary: rgb("#04364A"),
  secondary: rgb("#176B87"),
  tertiary: rgb("#448C95"),
)
```

颜色主题，你可以通过 `#let store = (store.methods.colors)(self: store, ..)` 对其进行修改。

## slide 函数族

University 主题提供了一系列自定义 slide 函数：

```typst
#title-slide(logo: none, authors: none, ..args)
```

`title-slide` 会读取 `self.info` 里的信息用于显示，你也可以为其传入 `logo` 参数和 array 类型的 `authors` 参数。

---

```typst
#slide(
  repeat: auto,
  setting: body => body,
  composer: utils.side-by-side,
  section: none,
  subsection: none,
  // university theme
  title: none,
  subtitle: none,
  header: none,
  footer: auto,
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
#matrix-slide(columns: ..., rows: ...)[
  ...
][
  ...
]
```
可以参考 [文档](https://polylux.dev/book/themes/gallery/university.html)。


## `slides` 函数

`slides` 函数拥有参数

- `title-slide`: 默认为 `true`。
- `slide-level`: 默认为 `1`。

可以通过 `#show: slides.with(..)` 的方式设置。

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/58971045-0b0d-46cb-acc2-caf766c2432d)


## 示例

```typst
#import "@preview/touying:0.3.1": *

#let store = themes.university.register(store, aspect-ratio: "16-9")
#let store = (store.methods.info)(
  self: store,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(store)
#show: init

#let (slide, title-slide, focus-slide, matrix-slide) = utils.slides(store)
#show: slides.with(title-slide: false)

#title-slide(authors: ([Author A], [Author B]))

= The Section

== Slide Title

#slide[
  #lorem(40)
]

#slide(subtitle: emph[What is the problem?])[
  #lorem(40)
]

#focus-slide[
  *Another variant with primary color in background...*
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

