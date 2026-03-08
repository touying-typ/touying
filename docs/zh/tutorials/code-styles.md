---
sidebar_position: 1
---

# 代码风格

## 简单风格

如果我们只是需要简单使用，我们可以直接在标题下输入内容，就像是在编写正常 Typst 文档一样。这里的标题有着分割页面的作用，同时我们也能正常地使用 `#pause` 等命令实现动画效果。

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

并且你可以使用空标题 `== <touying:hidden>` 创建一个新页，这个技巧也有助于清除上一个标题的继续应用。

如果我们需要维持当前标题，仅仅是想加入一个新页，我们可以使用 `#pagebreak()`，亦或者直接使用 `---` 来分割页面，后者在 Touying 中被解析为 `#pagebreak()`。

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== First Slide

Hello, Touying!

---

Hello, Typst!
```

## 块风格

很多时候，仅仅使用简单风格并不能实现我们需要的所有功能，为了更强大的功能和更清晰的结构，我们同样可以使用 `#slide[...]` 形式的块风格。

例如上面的例子就可以改造成

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(aspect-ratio: "16-9")

= Title

== First Slide

#slide[
  Hello, Touying!

  #pause

  Hello, Typst!
]
```

以及 `#empty-slide[]` 可以创建一个没有 header 和 footer 的空 Slide。

这样做的好处有很多：

1. 很多时候，我们不只是需要默认的 `#slide[...]`，还需要 `#focus-slide[...]` 这些特殊的 `slide` 函数；
2. 不同主题的 `#slide[...]` 函数可能有比默认更多的参数，例如 metropolis 主题的 `#slide[...]` 函数就会有着 `align` 参数可以设置对齐方式；
3. 只有 `slide` 函数才可以通过回调风格的内容块来使用 `#only` 和 `#uncover` 函数实现复杂的动画效果。
4. 能有着更清晰的结构，通过辨别 `#slide[...]` 块，我们可以很容易地分辨出 slides 的具体分页效果。


## 约定优于配置

你可能注意到了，在使用 simple 主题时，我们使用一级标题会自动创建一个 section slide，这是因为 simple 主题注册了一个 `config-common(slide-fn: slide, new-section-slide-fn: new-section-slide)` 函数，因此 touying 会默认调用这个函数。

如果我们不希望它自动创建这样一个 section slide，我们可以将这个方法删除：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: none),
)

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```

如你所见，这样就只会剩下两页，而默认的 section slide 就会消失了。

同理，我们也可以注册一个新的 section slide：

```example
#import "@preview/touying:0.6.2": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: section => {
    touying-slide-wrapper(self => {
      touying-slide(
        self: self,
        {
          set align(center + horizon)
          set text(size: 2em, fill: self.colors.primary, style: "italic", weight: "bold")
          utils.display-current-heading(level: 1)
        },
      )
    })
  }),
)

= Title

== First Slide

Hello, Touying!

#pause

Hello, Typst!
```