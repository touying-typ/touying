---
sidebar_position: 10
---

# 创建自己的主题

使用 Touying 创建一个自己的主题是一件略显复杂的事情，因为我们引入了许多的概念。不过请放心，如果您真的用 Touying 创建了一个自己的主题，也许您就可以深切地感受到 Touying 提供的便利的功能的和强大的可定制性。您可以参考 [主题的源代码](https://github.com/touying-typ/touying/tree/main/themes)，主要需要实现的就是：

- 自定义 `register` 函数，初始化全局单例 `s`；
- 自定义 `init` 方法；
- 自定义颜色主题，即修改 `self.colors` 成员变量；
- 自定义 `alert` 方法，可选；
- 自定义 header；
- 自定义 footer；
- 自定义 `slide` 方法；
- 自定义特殊 slide 方法，如 `title-slide` 和 `focus-slide` 方法；
- 自定义 `slides` 方法，可选；

为了演示如何使用 Touying 创建一个自己的主题，我们不妨来一步一步地创建一个简洁美观的 Bamboo 主题。


## 导入

取决于这个主题是你自己的，还是 Touying 的一部分，你可以用两种方式导入：

如果只是你自己使用，你可以直接导入 Touying：

```typst
#import "@preview/touying:0.3.1": *
```

如果你希望这个主题作为 Touying 的一部分，放置在 Touying `themes` 目录下，那你应该将上面的导入语句改为

```typst
#import "../utils/utils.typ"
#import "../utils/states.typ"
#import "../utils/components.typ"
```

并且要在 Touying 的 `themes/themes.typ` 里加上

```
#import "bamboo.typ"
```


## register 函数和 init 方法

接下来，我们会区分 `bamboo.typ` 模板文件和 `main.typ` 文件，后者有时会被省略。

一般而言，我们制作 slides 的第一步，就是确定好字体大小和页面长宽比，因此我们需要注册一个初始化方法：

```typst
// bamboo.typ
#import "@preview/touying:0.3.1": *

#let register(
  aspect-ratio: "16-9",
  self,
) = {
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
  )
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}

// main.typ
#import "@preview/touying:0.3.1": *
#import "bamboo.typ"

#let s = bamboo.register(s, aspect-ratio: "16-9")
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide,) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]
```

如您所见，我们创建了一个 `register` 函数，并传入了一个 `aspect-ratio` 参数来设定页面长宽比。您应该已经知道了，在 Touying 中，我们不应该使用 `set page(..)` 来设置页面参数，而是应该使用 `  self.page-args += (..)` 这种语法来设置，具体内容可以参考页面布局章节。

除此之外，我们还注册了一个 `self.methods.init` 方法，它可以用来进行一些全局的样式设置，例如在此处，我们加上了 `set text(size: 20pt)` 来设置文字大小。你也可以在这里放置一些额外的全局样式设置，例如 `set par(justify: true)` 等。由于 `init` 函数被放置到了 `self.methods` 里，是一个方法，而非普通函数，因此我们需要加上 `self: none` 参数才能正常使用。

如您所见，后续在 `main.typ` 中，我们会通过 `#show: init` 来应用 `init` 方法里面的全局样式设置，其中 `init` 函数是通过 `utils.methods(s)` 绑定并解包而来的。

如果您多加注意，您会发现 `register` 函数最后有一行独立的 `self`，这其实是代表了将修改后的 `self` 作为返回值返回，后续会被保存在 `#let s = ..` 中，因此这一行是不可或缺的。


## 颜色主题

为您的 slides 挑选一个美观的颜色主题，是做好一个 slides 的关键所在。Touying 提供了内置的颜色主题支持，以尽量抹平不同主题之间的 API 差异。Touying 提供了两个维度的颜色选择，第一个维度是 `neutral`、`primary`、`secondary` 和 `tertiary`，用于区分色调，其中最常用的就是 `primary` 主题色；第二个维度是 `default`、`light`、`lighter`、`lightest`、`dark`、`darker`、`darkest`，用于区分明度。

由于我们是 Bamboo 主题，因此这里的主题色 `primary` 我们挑选了一个与竹子相近的颜色 `rgb("#5E8B65")`，并加入了中性色 `neutral-lightest`，`neutral-darkest`，分别作为背景色和字体颜色。

正如下面的代码所示，我们可以使用 `self = (self.methods.colors)(self: self, ..)` 方法修改颜色主题。其本质就是 `self.colors += (..)` 的一个包装。

```typst
#let register(
  aspect-ratio: "16-9",
  self,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
  )
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}
```

像这样添加了颜色主题后，我们就可以通过 `self.colors.primary` 这样的方式获取到这个颜色。

并且有一点值得注意，用户可以随时在 `main.typ` 里通过

```typst
#let s = (s.methods.colors)(self: s, primary: rgb("#3578B9"))
```

这样的方式修改主题色，其中这句语句需要放在 `register(s)` 之后，以及 `utils.methods(s)` 之前。

这种随时更换颜色主题的内容，正是 Touying 强大可定制性的体现。


## 实战：自定义 Alert 方法

一般而言，我们都需要提供一个 `#alert[..]` 函数给用户使用，其用途与 `#strong[..]` 类似，都是用于强调当前文本。一般 `#alert[..]` 会将文本颜色修改为主题色，这样看起来会更美观，这也是我们接下来要实现的目标。

我们在 `register` 函数里加上一句

```typst
self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
```

这句代码的意思就是将文本颜色修改为 `self.colors.primary`，而这里的 `self` 正是通过参数 `self: none` 传进来的，这样我们才能实时地获取到 `primary` 主题色。


## 自定义 Header 和 Footer

在这里，我认为您已经阅读过页面布局章节了，因此我们知道应该给 slides 加上 header 和 footer。

首先，我们先加入 `self.bamboo-title = []`，也就是说，我们将当前 slide 的标题作为一个成员变量 `self.bamboo-title`，保存在 `self` 里面，这样方便我们在 header 里使用，以及后续修改。同理，我们还创建了一个 `self.bamboo-footer`，并将 `register` 函数的 `footer: []` 参数保存起来，用作左下角的 footer 展示。

然后值得注意的就是，我们的 header 其实是一个形如 `let header(self) = { .. }` 的参数为 `self` 的 content 函数，而不是一个单纯的 content，这样我们才能从最新的 `self` 内部获取到我们需要的信息，例如 `self.bamboo-title`。而 footer 也是同理。

里面使用到的 `components.cell` 其实就是 `#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)`，而 `show: components.cell` 也就是 `components.cell(body)` 的简写，footer 的 `show: pad.with(.4em)` 也是同理。

另一点值得注意的是，`states` 模块里放置了很多和计数器、状态有关的内容，例如 `states.current-section-title` 用于显示当前的 `section`，而 `states.slide-counter.display() + " / " + states.last-slide-number` 用于显示当前页数和总页数。

以及我们发现我们会使用 `utils.call-or-display(self, self.bamboo-footer)` 这样的语法来显示 `self.bamboo-footer`，这是用于应付 `self.bamboo-footer = (self) => {..}` 这种情况，这样我们就能统一 content 函数和 content 的显示。

为了让 header 和 footer 正确显示，并且与正文有足够的间隔，我们还设置了上下 margin 和左右 padding，如 `self.page-args += (margin: (top: 4em, bottom: 1.5em, x: 0em))` 和 `self.padding = (x: 2em, y: 0em)`。左右 margin 为 `0em` 是为了让 header 能占满页面宽度，正文的左右间距就依靠左右 padding `2em` 来实现。

而我们还需要自定义一个 `slide` 方法，其中接收 `slide(self: none, title: auto, ..args)`，第一个 `self: none` 是一个方法所必须的参数，用于获取最新的 `self`；而第二个 `title` 则是用于更新 `self.bamboo-title`，以便在 header 中显示出来；第三个 `..args` 是用于收集剩余的参数，并传到 `(self.methods.touying-slide)(self: self, ..args)` 里，这也是让 Touying `slide` 功能正常生效所必须的。并且，我们需要在 `register` 函数里使用 `self.methods.slide = slide` 注册这个方法。

```typst
// bamboo.typ
#import "@preview/touying:0.3.1": *

#let slide(self: none, title: auto, ..args) = {
  if title != auto {
    self.bamboo-title = title
  }
  (self.methods.touying-slide)(self: self, ..args)
}

#let register(
  aspect-ratio: "16-9",
  footer: [],
  self,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  // variables for later use
  self.bamboo-title = []
  self.bamboo-footer = footer
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    states.current-section-title
    linebreak()
    set text(size: 1.5em)
    utils.call-or-display(self, self.bamboo-title)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.bamboo-footer)
    h(1fr)
    states.slide-counter.display() + " / " + states.last-slide-number
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 4em, bottom: 1.5em, x: 0em),
  )
  self.padding = (x: 2em, y: 0em)
  // register methods
  self.methods.slide = slide
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}


// main.typ
#import "@preview/touying:0.3.1": *
#import "bamboo.typ"

#let s = bamboo.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide,) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/d33bcda7-c032-4b11-b392-5b939d9a0a47)


## 自定义特殊 Slide

我们在上面的基础 slide 的基础上，进一步加入一些特殊的 slide 函数，例如 `title-slide`，`focus-slide` 以及自定义 `slides` 方法。

对于 `title-slide` 方法，首先，我们调用了 `self = utils.empty-page(self)`，这个函数可以清除 `self.page-args.header` 和 `self.page-args.footer`，以及将 `margin` 和 `padding` 都设为 `0em`，得到一个空白页的效果。然后，我们可以通过 `let info = self.info + args.named()` 获取到 `self.info` 里保存的信息，也可以用函数参数里传入的 `args.named()` 来更新信息，便于后续以 `info.title` 的方式使用。具体的页面内容 `body`，每个 theme 都会有所不同，这里就不再过多赘述。而在最后，我们调用了 `(self.methods.touying-slide)(self: self, repeat: none, body)`，其中的 `repeat: none` 表面这个页面不需要动画效果，而传入 `body` 参数会将 `body` 的内容显示出来。

对于 `new-section-slide` 方法，也是同理，不过唯一要注意的是我们在 `(self.methods.touying-slide)(self: self, repeat: none, section: section, body)` 的参数里面多传入了一个 `section: section`，这是用来声明新建一个 `section` 的。另一点需要注意的是，我们除了 `self.methods.new-section-slide = new-section-slide`，还注册了 `self.methods.touying-new-section-slide = new-section-slide`，这样 `new-section-slide` 就会在碰到一级标题时自动被调用。

对于 `focus-slide` 方法，大部分内容也基本一致，不过值得注意的是，我们通过 `self.page-args += (..)` 更新了页面的背景颜色。

最后，我们还更新了 `slides(self: none, title-slide: true, slide-level: 1, ..args)` 方法，其中 `title-slide` 为 `true` 时，在使用 `#show: slides` 后会自动创建一个 `title-slide`；而 `slide-level: 1` 指明了一级标题和二级标题分别对应 `section` 和 `title`。

```
// bamboo.typ
#import "@preview/touying:0.3.1": *

#let slide(self: none, title: auto, ..args) = {
  if title != auto {
    self.bamboo-title = title
  }
  (self.methods.touying-slide)(self: self, ..args)
}

#let title-slide(self: none, ..args) = {
  self = utils.empty-page(self)
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
    )
    set text(fill: self.colors.neutral-darkest)
    if info.author != none {
      block(info.author)
    }
    if info.date != none {
      block(if type(info.date) == datetime { info.date.display(self.datetime-format) } else { info.date })
    }
  }
  (self.methods.touying-slide)(self: self, repeat: none, body)
}

#let new-section-slide(self: none, section) = {
  self = utils.empty-page(self)
  let body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", style: "italic")
    section
  }
  (self.methods.touying-slide)(self: self, repeat: none, section: section, body)
}

#let focus-slide(self: none, body) = {
  self = utils.empty-page(self)
  self.page-args += (
    fill: self.colors.primary,
    margin: 2em,
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon + center, body))
}

#let slides(self: none, title-slide: true, slide-level: 1, ..args) = {
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  aspect-ratio: "16-9",
  footer: [],
  self,
) = {
  // color theme
  self = (self.methods.colors)(
    self: self,
    primary: rgb("#5E8B65"),
    neutral-lightest: rgb("#ffffff"),
    neutral-darkest: rgb("#000000"),
  )
  // variables for later use
  self.bamboo-title = []
  self.bamboo-footer = footer
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    states.current-section-title
    linebreak()
    set text(size: 1.5em)
    utils.call-or-display(self, self.bamboo-title)
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.bamboo-footer)
    h(1fr)
    states.slide-counter.display() + " / " + states.last-slide-number
  }
  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    margin: (top: 4em, bottom: 1.5em, x: 0em),
  )
  self.padding = (x: 2em, y: 0em)
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.slides = slides
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    body
  }
  self
}


// main.typ
#import "@preview/touying:0.3.1": *
#import "bamboo.typ"

#let s = bamboo.register(s, aspect-ratio: "16-9", footer: self => self.info.institution)
#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Authors],
  date: datetime.today(),
  institution: [Institution],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, title-slide, focus-slide) = utils.slides(s)
#show: slides

= First Section

== First Slide

#slide[
  A slide with a title and an *important* information.
]

#focus-slide[
  Focus on it!
]
```

![image](https://github.com/touying-typ/touying/assets/34951714/03c5ad02-8ff4-4068-9664-d9cfad79baaf)


## 总结

至此，我们就已经创建了一个简洁又美观的主题了。也许你会觉得，Touying 引入的概念过于丰富了，以至于让人一时很难轻易接受。这是正常的，在强大的功能与简洁的概念之间，Touying 选择了前者。但是也正是得益于 Touying 这种大而全的统一理念，你可以很容易地在不同的主题之间抽离出共通之处，并将你学到的概念迁移到另一个主题上。亦或者，你可以很轻易地保存全局变量，或者更改已有的主题，例如全局保存主题颜色，替换掉 slides 的 header，或者添加一两个 Logo 等，这也正是 Touying 解耦与面向对象编程带来的好处。