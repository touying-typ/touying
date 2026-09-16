---
sidebar_position: 7
---

# 文章模式

文章模式会把同一份源文件渲染成一篇流动的散文文档，而不是一份幻灯片。

```bash
typst compile talk.typ talk.pdf                            # 幻灯片
typst compile --input export-mode=article talk.typ talk.pdf   # 文章
```

`--input export-mode=article` 的优先级高于文件本身的设置，因此同一份源文件无需修改就能同时构建出两种输出。如果你更倾向于把模式固定写在文件里，可以在 config 中设置：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== A Section

The page belongs to the article theme now, not to the slide theme.
```

`export-mode` 接受 `"slides"`、`"presentation"`、`"handout"` 或 `"article"`。这几种模式之间的关系，参见[输出模式](../tutorials/output-modes)。

## 有什么会发生变化

- **各 section 之间不再分页。** 内容连续流动，一个 heading 只是开启一个 section，而不是开启一张幻灯片。
- **动画会被折叠。** 每张幻灯片都按它最后一个子幻灯片渲染，因此 `#pause` 和 `#uncover` 会让它们的内容保持原样出现，被遮盖的内容也会以它在末尾时的样子显示出来。
- **版式和样式属于文章主题**，而不属于幻灯片主题。诸如页眉、页脚和 16:9 页面这类幻灯片层面的样式会被去掉。
- **布局会被线性化。** 一个只用来排布内容的容器会被拉平进正文中，因为文章并不追求保留幻灯片的布局。参见[线性化布局](#线性化布局)。

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== A Section

Ordinary content. #pause This appears on a second subslide in the deck, and inline here.
```

## 选择一个文章主题

Touying 自带一个朴素的文章主题，并默认使用它。任何接受 body 的主题都可以使用，包括 Universe 上的文档类主题：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#import "@preview/arkheion:0.1.0": arkheion

#show: simple-theme.with(
  config-common(export-mode: "article", article-theme: arkheion),
)

== A Section

Rendered by arkheion rather than by touying's own article theme.
```

主题是一个作用于整篇文章的函数，因此在指定它的同时用 `.with(..)` 来配置它：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#import themes.article: article-theme

#show: simple-theme.with(
  config-common(
    export-mode: "article",
    article-theme: article-theme.with(numbering: "1.1"),
  ),
)

= A Part

== A Section

Numbered by the article theme.
```

### 把幻灯片的元数据传给它

文章主题通常需要自己的 title 和 author。`config-article(available-fields: ..)` 会把你 touying config 中的条目映射到主题自己的参数上，这样你只需要在 `config-info` 或别处写一次：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#import "@preview/arkheion:0.1.0": arkheion

#show: simple-theme.with(
  config-info(title: [Projection], author: [A. Author]),
  config-common(export-mode: "article", article-theme: arkheion),
  config-article(available-fields: (title: "info.title")),
)

== A Section

The title above came from `config-info`.
```

键是主题的参数名，值是指向 touying config 内部的一条路径。只列出主题真正接受的字段，并且只在类型能对上的情况下列出：arkheion 的 `authors` 需要一个字典数组，如果把 `config-info` 的 `author` 传给它，就会得到 `element text has no method map` 这样的报错。使用前先检查一下主题的函数签名。

如果主题没有自带的标题块，那么要么给 `config-article(title-block-fn: ..)` 传一个能返回标题块的函数，要么就在第一张幻灯片之前自己写一个 `#article-only[..]` 块。

## 为两种输出分别写内容

由于你可能想为每种输出目标写略有不同的内容，你可以通过三个函数来选择哪部分内容出现在哪里。它们在[输出模式](../tutorials/output-modes)中有完整介绍；简单来说：

- `#article-only[..]` 添加只存在于文章中的内容。即便是像 heading 或 "---" 这样会打断幻灯片的元素，也可以写在这里面。
- `#slides-only[..]` 只在输出幻灯片时显示其中的内容。
- `#article-text[..]` 会用散文**替换**它所写在的那张幻灯片。每张幻灯片只能有一个。

`#article-text` 是其中最有意思的一个。在幻灯片上效果不错的要点列表，写进文档里往往读起来很别扭，因此你可以在它们旁边写好对应的散文版本，让每种输出各取所需：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
#show: simple-theme.with(
  config-common(export-mode: "article"),
)

== Why This Matters

- terse
- bullet
- points

#article-text[
  In the article this paragraph stands in for the bullet points above, which
  never reach the page.
]
```

它替换的是它所在的整张幻灯片，因此无论这张幻灯片是由 heading 产生的，还是来自显式的 `#slide[..]` 调用，效果都一样。你把它写在哪里并不重要：写在它所替换内容的上面、下面，还是中间都可以。但每张幻灯片只允许有一个 `#article-text[..]` 块。

这里的"一张幻灯片"指的是不深于 `slide-level`（默认是 `=` 和 `==`）的 heading，因此它下面的 `===` 属于这张幻灯片内部的内容，会随其余部分一起被替换。裸的 `---` 会被忽略：它只是一个幻灯片分隔符，文章会将其丢弃。`#pagebreak()` 则是唯一真正会切分一张幻灯片的东西，因为文章在这里同样会分页。如果你的 section 使用 `#pagebreak()` 而不是 `---`，那么你就可以为每个部分各写一个 `article-text`。而在 `#article-text[..]` 或 `#article-only[..]` 内部，`---` 会被保留下来，因为这两种 body 内部本来就没有什么可以打断幻灯片的东西。

## 回放动画内容

一个带动画的图表，本质上是一张有多个子幻灯片的幻灯片，而文章只会渲染最后一个。当中间的阶段承载着论证过程时，`#touying-recall` 可以把其中某一个阶段放回正文中：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme.with(config-common(export-mode: "article"))
#import "@preview/cetz:0.4.2"
#let canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

== The Construction
#canvas(label: "fig", {
  import cetz.draw: *
  rect((0, 0), (4, 3))
  (pause,)
  circle((2, 1.5), radius: 0.8)
}, length: 20pt)

#article-text[
  First the frame is fixed:
  #touying-recall(<fig>, subslides: 1)

  Then the inscribed circle follows:
  #touying-recall(<fig>, subslides: 2)
]
```

`subslides` 用来挑选阶段。当这次调用不是所在幻灯片上的第一个元素时，传入 `base:`，因为阶段编号是从外层的内容流开始计数的。更多细节请参见该函数的文档。另一个类似的函数是 `touying-render`，它接受内容并将其渲染到某个子幻灯片状态。

## 线性化布局

文章是单栏的正文，因此任何只是为了在幻灯片上排布内容的容器，都应该被拉平进这股内容流中。幻灯片的 composer、`#columns(..)` 以及 `components.side-by-side[..][..]`，默认情况下都会被线性化。

`table` 或 `grid` 则有所不同，因为它们的结构本身可能承载着含义。默认情况下，touying 把**声明了 header 或 footer** 视为结构具有含义的证据：有的话，table 保留其结构；没有的话，就把它当作单纯的排版手段而拉平。`components.cols` 和 `side-by-side` 内部都会构建一个 grid，但并不声明 header，这就是它们会被线性化的原因。

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme.with(config-common(export-mode: "article"))
== Two Ways To Use A Table

#components.side-by-side[Left half.][Right half.]

#table(
  columns: 2,
  table.header([Element], [Kept]),
  [with a header], [yes],
  [without one], [no],
)
```

`config-article(linearize: ..)` 允许你自定义这个行为。`auto` 是上面描述的默认值，`true` 和 `false` 会全局强制该行为，而一个字典可以按元素函数（`"columns"`、`"grid"`、`"table"`）分别设置。对 `"columns"` 而言，`auto` 就等价于 `true`，因为 `#columns(..)` 本身从不承载任何结构。

figure 的 body 永远不会被拉平，因为它的 caption 赋予了其版式意义。

```typst
#show: simple-theme.with(
  config-article(linearize: (table: false, grid: auto, columns: true)),
)
```

`#article-linearize[..]` 和 `#article-keep-layout[..]` 允许你按元素覆盖全局配置。

```typst
#article-linearize[#components.side-by-side[left][right]]

#article-keep-layout[#table(columns: 2, [a], [b]) <tab:x>]
```
注意，`#article-only` 或 `#article-text` 内部的内容始终按原样保留，如果在其中写上面这两个标记，会导致 panic。

## 把内容块浮动到旁侧

为了改善阅读体验，touying 可以通过 `config-article(wrap: ..)` 自动把图片环绕排布到一侧。

没有被环绕的 figure 和 table，会被居中放在所在 section 的底部。如果想把它做成一个浮动的 figure，请改用 `article-only`/`article-text`。其余所有内容块（包括图片在内）都不受此影响，而是被放在线性化器认为它们应该在的正文位置上。

```typst
#show: simple-theme.with(
  config-common(export-mode: "article"),
  config-article(wrap: (
    width: 50%,     // how much of the text width a float takes
    align: right,   // which side it goes to
    image: true,    // raw images, on by default
    table: false,
  )),
)
```

你可以只设置一次全局的 width 和 align，再决定每个元素函数——`table`、`image`、`figure`……——是否使用环绕。

作为顶层简写，`wrap: false` 会完全关闭环绕，而 `wrap: true` 会使用默认宽度与对齐方式环绕所有可抽取的候选元素。

你也可以按元素函数覆盖这些全局默认值：

```typst
config-article(wrap: (
  image: (align: right, width: 30%),
  table: (align: left, width: 45%),
))
```

你还可以指定更复杂的元素选择规则。遗憾的是 typst 的 selector 在这里并不适用，因此你必须改用一个 predicate 来指定。

```typst
config-article(wrap: (
  image: true,
  overrides: (
    // a figure holding an image floats; one holding a table does not
    (target: el => el.func() == figure and el.body.func() == image,
     align: left, width: 35%),
  ),
))
```

注意，这个 predicate 看到的是内容树，在这个阶段一个 figure 的 `kind` 仍然是 `auto`，因此请通过 `el.body.func()` 而不是 `el.kind` 来判断。

由 [cetz](https://typst.app/universe/package/cetz) 或 [fletcher](https://typst.app/universe/package/fletcher) 这类包绘制的图形，在文章收集浮动内容时已经是 context 内容了。因此 `touying-reducer` 会用绘制它的函数（例如 `cetz.canvas`）给自己的输出打上标记，而 `graphic-marker-of` 会构建出与之匹配的 predicate：

```typst
#import "@preview/cetz:0.4.2"

config-article(wrap: (
  overrides: (
    (target: graphic-marker-of(cetz.canvas), align: left, width: 40%),
  ),
))
```

没有动画的图表不会经过 reducer，因此需要你自己用 `#graphic-marker(cetz.canvas, ..)` 来标记它，之后同样的 predicate 就能找到它。这个标记是不可见的，并且会在渲染之前被去掉——在两种输出中都是如此。

环绕排布是借助 [meander](https://typst.app/universe/package/meander) 完成的，它只会在真正有内容需要环绕的 section 中被加载。

## 值得了解的几件事

**标题幻灯片会内联渲染。** `#title-slide(..)` 和其他幻灯片一样也是一张幻灯片，因此在文章中它同样会出现，标题材料就会显示两次。把这次调用包起来，可以避免它出现在文章里：

```example
>>> #import "@preview/touying:0.8.0": *
>>> #import themes.simple: *
>>> #show: simple-theme.with(config-common(export-mode: "article"))
#slides-only(title-slide[])

== A Section

No duplicated title block above this.
```

**标记必须是可达的。** `#pause`、`#article-text` 以及其他类似的标记，都是在排版之前通过遍历文档来解析的。如果它被嵌套在一个 `#context` 块里，或者放进一个会被测量的容器中，就永远不会被遍历到，编译会以 `Unsupported mark` 结束。不要把它们包在自计数的动画函数或其他 `#context` 表达式里。

**演讲者备注不会出现。** `#speaker-note[..]` 是给演讲者视图用的。如果你想在文档里加一段旁注，请使用 `#article-only[..]`。
