---
sidebar_position: 4
---

# 代码风格

## 简单风格

如果我们只是需要简单使用，我们可以直接在标题下输入内容，就像是在编写正常 Typst 文档一样。这里的标题有着分割页面的作用，同时我们也能正常地使用 `#pause` 等命令实现动画效果。

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.simple.register(s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/f5bdbf8f-7bf9-45fd-9923-0fa5d66450b2)

并且你可以使用空标题 `==` 创建一个新页，这个技巧也有助于清除上一个标题的继续应用。

PS：我们可以使用 `#slides-end` 记号来标志 `#show: slides` 的结束。


## 块风格

很多时候，仅仅使用简单风格并不能实现我们需要的所有功能，为了更强大的功能和更清晰的结构，我们同样可以使用 `#slide[...]` 形式的块风格，其中 `#slide` 函数需要使用 `#let (slide,) = utils.slides(s)` 语法进行解包，才能正常在 `#show: slides` 后使用。

例如上面的例子就可以改造成

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.simple.register(s)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Title

== First Slide

#slide[
  Hello, Touying!

  #pause

  Hello, Typst!
]
```

这样做的好处有很多：

1. 很多时候，我们不只是需要默认的 `#slide[...]`，还需要 `#focus-slide[...]` 这些特殊的 `slide` 函数；
2. 不同主题的 `#slide[...]` 函数可能有比默认更多的参数，例如 university 主题的 `#slide[...]` 函数就会有着 `subtitle` 参数；
3. 只有 `slide` 函数才可以通过回调风格的内容块来使用 `#only` 和 `#uncover` 函数实现复杂的动画效果。
4. 能有着更清晰的结构，通过辨别 `#slide[...]` 块，我们可以很容易地分辨出 slides 的具体分页效果。


## 约定优于配置

你可能注意到了，在使用 simple 主题时，我们使用一级标题会自动创建一个 section slide，这是因为 simple 主题注册了一个 `s.methods.touying-new-section-slide` 方法，因此 touying 会默认调用这个方法。

如果我们不希望它自动创建这样一个 section slide，我们可以将这个方法删除：

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.simple.register(s)
#(s.methods.touying-new-section-slide = none)
#let (init, slides) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/17a89a59-9491-4e1f-95c0-09a22105ab35)

如你所见，这样就只会剩下两页，而默认的 section slide 就会消失了。

同理，我们也可以注册一个新的 section slide：

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.simple.register(s)
#(s.methods.touying-new-section-slide = (self: none, section, ..args) => {
  self = utils.empty-page(self)
  (s.methods.touying-slide)(self: self, section: section, {
    set align(center + horizon)
    set text(size: 2em, fill: s.colors.primary, style: "italic", weight: "bold")
    section
  }, ..args)
})
#let (init, slides, touying-outline) = utils.methods(s)
#show: init

#let (slide,) = utils.slides(s)
#show: slides

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

![image](https://github.com/touying-typ/touying/assets/34951714/5305efda-0cd4-42eb-9f2e-89abc30b6ca2)

同样地，我们也可以修改 `s.methods.touying-new-subsection-slide` 来对 `subsection` 做同样的事。

实际上，除了 `s.methods.touying-new-section-slide`，另一个特殊的 `slide` 函数就是 `s.methods.slide` 函数，它会在简单风格里没有显示使用 `#slide[...]` 的情况下默认被调用。

同时，由于 `#slide[...]` 被注册在了 `s.slides = ("slide",)` 里，因此 `section`，`subsection` 和 `title` 参数会被自动传入，而其他的如 `#focus-slide[...]` 则不会自动传入这三个参数。

:::tip[原理]

实际上，你也可以不使用 `#show: slides` 和 `utils.slides(s)`，而是只使用 `utils.methods(s)`，例如

```typst
#import "@preview/touying:0.3.1": *

#let s = themes.simple.register(s)
#let (init, touying-outline, slide) = utils.methods(s)
#show: init

#slide(section: [Title], title: [First Slide])[
  Hello, Touying!

  #pause

  Hello, Typst!
]
```

这时候需要手动传入 `section`、`subsection` 和 `title`，但是会有更好的性能，适合需要更快的性能的情况，例如超过数十数百页的情形。

:::