---
sidebar_position: 9
---

# 创建自己的主题

使用 Touying 创建一个自己的主题是一件略显复杂的事情，因为我们引入了许多的概念。不过请放心，如果您真的用 Touying 创建了一个自己的主题，也许您就可以深切地感受到 Touying 提供的便利的功能的和强大的可定制性。您可以参考 [主题的源代码](https://github.com/touying-typ/touying/tree/main/themes)，主要需要实现的就是：

- 自定义 `xxx-theme` 函数；
- 自定义颜色主题，即 `config-colors()`；
- 自定义 header；
- 自定义 footer；
- 自定义 `slide` 方法；
- 自定义特殊 slide 方法，如 `title-slide` 和 `focus-slide` 方法；

为了演示如何使用 Touying 创建一个自己的主题，我们不妨来一步一步地创建一个简洁美观的 Bamboo 主题。


## 修改已有主题

如果你想在本地修改一个 Touying 内部的 themes，而不是自己从零开始创建，你可以选择通过下面的方式实现：

1. 将 `themes` 目录下的 [主题代码](https://github.com/touying-typ/touying/tree/main/themes) 复制到本地，例如将 `themes/university.typ` 复制到本地 `university.typ` 中。
2. 将 `university.typ` 文件顶部的 `#import "../src/exports.typ": *` 命令替换为 `#import "@preview/touying:0.7.0": *`

然后就可以通过

```typst
#import "@preview/touying:0.7.0": *
#import "university.typ": *

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
```

的方式导入和使用主题了。


## 导入

取决于这个主题是你自己的，还是 Touying 的一部分，你可以用两种方式导入：

如果只是你自己使用，你可以直接导入 Touying：

```typst
#import "@preview/touying:0.7.0": *
```

如果你希望这个主题作为 Touying 的一部分，放置在 Touying `themes` 目录下，那你应该将上面的导入语句改为

```typst
#import "../src/exports.typ": *
```

并且要在 Touying 的 `themes/themes.typ` 里加上

```
#import "bamboo.typ"
```


## register 函数和 init 方法

接下来，我们会区分 `bamboo.typ` 模板文件和 `main.typ` 文件，后者有时会被省略。

一般而言，我们制作 slides 的第一步，就是确定好字体大小和页面长宽比，因此我们需要注册一个初始化方法：

```example
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let bamboo-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
    ),
    ..args,
  )

  body
}

// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(aspect-ratio: "16-9")

= First Section

== First Slide

A slide with a title and an *important* information.
```

如您所见，我们创建了一个 `bamboo-theme` 函数，并传入了一个 `aspect-ratio` 参数来设定页面长宽比。我们还加上了 `set text(size: 20pt)` 来设置文字大小。你也可以在这里放置一些额外的全局样式设置，例如 `set par(justify: true)` 等。如果你需要使用到 `self`，你可以考虑使用 `config-methods(init: (self: none, body) => { .. })` 来注册一个 `init` 方法。

如您所见，后续在 `main.typ` 中，我们会通过 `#show: bamboo-theme.with(aspect-ratio: "16-9")` 来应用我们的样式设置，而 `bamboo` 内部又是使用 `show: touying-slides.with()` 进行了对应的配置。


## 颜色主题

为您的 slides 挑选一个美观的颜色主题，是做好一个 slides 的关键所在。Touying 提供了内置的颜色主题支持，以尽量抹平不同主题之间的 API 差异。Touying 提供了两个维度的颜色选择，第一个维度是 `neutral`、`primary`、`secondary` 和 `tertiary`，用于区分色调，其中最常用的就是 `primary` 主题色；第二个维度是 `default`、`light`、`lighter`、`lightest`、`dark`、`darker`、`darkest`，用于区分明度。

由于我们是 Bamboo 主题，因此这里的主题色 `primary` 我们挑选了一个与竹子相近的颜色 `rgb("#5E8B65")`，并加入了中性色 `neutral-lightest`，`neutral-darkest`，分别作为背景色和字体颜色。

正如下面的代码所示，我们可以使用 `config-colors()` 方法修改颜色主题。其本质就是 `self.colors += (..)` 的一个包装。

```typst
#let bamboo-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-common(
      slide-fn: slide,
    ),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    ..args,
  )

  body
}
```

像这样添加了颜色主题后，我们就可以通过 `self.colors.primary` 这样的方式获取到这个颜色。

并且有一点值得注意，用户可以随时在 `main.typ` 里通过 `config-colors()` 或

```typst
#show: touying-set-config.with(config-colors(
  primary: blue,
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
))
```

这种随时更换颜色主题的功能，正是 Touying 强大可定制性的体现。


## 自定义 Alert 方法

一般而言，我们都需要提供一个 `#alert[..]` 函数给用户使用，其用途与 `#strong[..]` 类似，都是用于强调当前文本。一般 `#alert[..]` 会将文本颜色修改为主题色，这样看起来会更美观，这也是我们接下来要实现的目标。

我们在 `register` 函数里加上一句

```typst
config-methods(alert: (self: none, it) => text(fill: self.colors.primary, it))
```

这句代码的意思就是将文本颜色修改为 `self.colors.primary`，而这里的 `self` 正是通过参数 `self: none` 传进来的，这样我们才能实时地获取到 `primary` 主题色。

我们也可以简单地使用简写。

```typst
config-methods(alert: utils.alert-with-primary-color)
```


## 自定义 Header 和 Footer

在这里，我认为您已经阅读过页面布局章节了，因此我们知道应该给 slides 加上 header 和 footer。

首先，我们先加入 `config-store(title: none)`，也就是说，我们将当前 slide 的标题作为一个成员变量 `self.store.title`，保存在 `self` 里面，这样方便我们在 header 里使用，以及后续修改。同理，我们还创建了一个 `config-store(footer: footer)`，并将 `bamboo-theme` 函数的 `footer: none` 参数保存起来，用作左下角的 footer 展示。

然后值得注意的就是，我们的 header 其实是一个形如 `let header(self) = { .. }` 的参数为 `self` 的 content 函数，而不是一个单纯的 content，这样我们才能从最新的 `self` 内部获取到我们需要的信息，例如 `self.store.title`。而 footer 也是同理。

里面使用到的 `components.cell` 其实就是 `#let cell = block.with(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)`，而 `show: components.cell` 也就是 `components.cell(body)` 的简写，footer 的 `show: pad.with(.4em)` 也是同理。

另一点值得注意的是，`utils` 模块里放置了很多和计数器、状态有关的内容和方法，例如 `utils.display-current-heading(level: 1)` 用于显示当前的 `section`，而 `context utils.slide-counter.display() + " / " + utils.last-slide-number` 用于显示当前页数和总页数。

以及我们发现我们会使用 `utils.call-or-display(self, self.store.footer)` 这样的语法来显示 `self.store.footer`，这是用于应付 `self.store.footer = self => {..}` 这种情况，这样我们就能统一 content 函数和 content 的显示。

为了让 header 和 footer 正确显示，并且与正文有足够的间隔，我们需要设置 margin，如 `config-page(margin: (top: 4em, bottom: 1.5em, x: 2em))`。

而我们还需要自定义一个 `slide` 方法，其中接收 `#let slide(title: auto, ..args) = touying-slide-wrapper(self => {..})`，回调函数中 `self` 是回调函数所必须的参数，用于获取最新的 `self`；而第二个 `title` 则是用于更新 `self.store.title`，以便在 header 中显示出来；第三个 `..args` 是用于收集剩余的参数，并传到 `touying-slide(self: self, ..args)` 里，这也是让 Touying `slide` 功能正常生效所必须的。并且，我们需要在 `bamboo-theme` 函数里使用 `config-methods(slide: slide)` 注册这个方法。

```example
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    utils.display-current-heading(level: 1)
    linebreak()
    set text(size: 1.5em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )

  body
}


// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(aspect-ratio: "16-9")

= First Section

== First Slide

A slide with a title and an *important* information.
```


## 自定义特殊 Slide

我们在上面的基础 slide 的基础上，进一步加入一些特殊的 slide 函数，例如 `title-slide`，`focus-slide` 以及自定义 `slides` 方法。

对于 `title-slide` 方法，首先，我们可以通过 `let info = self.info + args.named()` 获取到 `self.info` 里保存的信息，也可以用函数参数里传入的 `args.named()` 来更新信息，便于后续以 `info.title` 的方式使用。具体的页面内容 `body`，每个 theme 都会有所不同，这里就不再过多赘述。

对于 `new-section-slide` 方法，也是同理，不过唯一要注意的是我们在 `config-methods()` 中注册了 `new-section-slide-fn: new-section-slide`，这样 `new-section-slide` 就会在碰到一级标题时自动被调用。

```
// bamboo.typ
#import "@preview/touying:0.7.0": *

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  if title != auto {
    self.store.title = title
  }
  // set page
  let header(self) = {
    set align(top)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    set align(horizon)
    set text(fill: self.colors.neutral-lightest, size: .7em)
    utils.display-current-heading(level: 1)
    linebreak()
    set text(size: 1.5em)
    if self.store.title != none {
      utils.call-or-display(self, self.store.title)
    } else {
      utils.display-current-heading(level: 2)
    }
  }
  let footer(self) = {
    set align(bottom)
    show: pad.with(.4em)
    set text(fill: self.colors.neutral-darkest, size: .8em)
    utils.call-or-display(self, self.store.footer)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(
      fill: self.colors.primary,
      width: 80%,
      inset: (y: 1em),
      radius: 1em,
      text(size: 2em, fill: self.colors.neutral-lightest, weight: "bold", info.title),
    )
    set text(fill: self.colors.neutral-darkest)
    if info.author != none {
      block(info.author)
    }
    if info.date != none {
      block(utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
})

#let new-section-slide(self: none, body) = touying-slide-wrapper(self => {
  let main-body = {
    set align(center + horizon)
    set text(size: 2em, fill: self.colors.primary, weight: "bold", style: "italic")
    utils.display-current-heading(level: 1)
  }
  touying-slide(self: self, main-body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 2em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(
      primary: rgb("#5E8B65"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      title: none,
      footer: footer,
    ),
    ..args,
  )

  body
}


// main.typ
<<< #import "@preview/touying:0.7.0": *
<<< #import "bamboo.typ": *

#show: bamboo-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

= First Section

== First Slide

A slide with a title and an *important* information.

#focus-slide[
  Focus on it!
]
```


## 总结

至此，我们就已经创建了一个简洁又美观的主题了。也许你会觉得，Touying 引入的概念过于丰富了，以至于让人一时很难轻易接受。这是正常的，在强大的功能与简洁的概念之间，Touying 选择了前者。但是也正是得益于 Touying 这种大而全的统一理念，你可以很容易地在不同的主题之间抽离出共通之处，并将你学到的概念迁移到另一个主题上。亦或者，你可以很轻易地保存全局变量，或者更改已有的主题，例如全局保存主题颜色，替换掉 slides 的 header，或者添加一两个 Logo 等，这也正是 Touying 解耦的好处。