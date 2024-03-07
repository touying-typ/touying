---
sidebar_position: 3
---

# 节与小节

## 结构

与 Beamer 相同，Touying 同样有着 section 和 subsection 的概念。

一般而言，1 级、2 级和 3 级标题分别用来对应 section、subsection 和 title，例如 dewdrop 主题。

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.dewdrop.register(s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Section

== Subsection

=== Title

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/1574e74d-25c1-418f-a84f-b974f42edae5)

但是很多时候我们并不需要 subsection，因此也会使用 1 级和 2 级标题来分别对应 section 和 title，例如 university 主题。

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.university.register(s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Section

== Title

Hello, Touying!
```

![image](https://github.com/touying-typ/touying/assets/34951714/9dd77c98-9c08-4811-872e-092bbdebf394)

实际上，我们可以通过 `slides` 函数的 `slide-level` 参数来控制这里的行为。`slide-level` 代表着嵌套结构的复杂度，从 0 开始计算。例如 `#show: slides.with(slide-level: 2)` 等价于 `section`，`subsection` 和 `title` 结构；而 `#show: slides.with(slide-level: 1)` 等价于 `section` 和 `title` 结构。


## 目录

在 Touying 中显示目录很简单：

```typst
#import "@preview/touying:0.3.1": *

#let (init, slides, alert, touying-outline) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides.with(slide-level: 2)

= Section

== Subsection

=== Title

==== Table of contents

#touying-outline()
```

![image](https://github.com/touying-typ/touying/assets/34951714/3cc09550-d3cc-40c2-a315-22ca8173798f)

其中 `touying-oultine()` 的定义为：

```typst
#let touying-outline(enum-args: (:), padding: 0pt) = { .. }
```

你可以通过 `enum-args` 修改内部 enum 的参数。

如果你对目录有着复杂的自定义需求，你可以使用

```typst
#states.touying-final-sections(sections => ..)
```

正如 dewdrop 主题所做的那样。