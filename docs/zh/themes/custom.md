---
sidebar_position: 7
---

# 定制主题

如果内置主题都不完全符合你的需求，有两种方案可供选择：

1. **扩展现有主题** — 将主题文件复制到本地并进行修改。
2. **从头构建新主题** — 实现你自己的 `xxx-theme` 函数。

这两种方式均在[构建你自己的主题](../tutorials/build-your-own-theme.md)教程中有详细介绍。

## 快速调整

对于对现有主题的微小调整，你不需要创建单独的主题文件。可以直接内联覆盖各项设置：

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  // Override the primary color
  config-colors(primary: rgb("#1a6b8a")),
  // Change the footer content
  footer: self => self.info.author,
  config-info(
    title: [My Presentation],
    author: [Author Name],
    date: datetime.today(),
  ),
)

#title-slide()

= Section

== Slide

Content with the custom color.
```

## 将主题复制到本地

若需要进行更深层的结构性修改，可以将主题源文件复制到项目中：

1. 从 Touying 仓库的 `themes/` 目录下载对应文件（例如 `themes/metropolis.typ`）。
2. 将文件顶部的导入从 `#import "../src/exports.typ": *` 改为 `#import "@preview/touying:0.7.4": *`。
3. 在项目中导入本地副本，而不是内置主题。

```typst
#import "@preview/touying:0.7.4": *
#import "metropolis.typ": *   // your local copy

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(title: [Title]),
)
```

现在你可以自由编辑 `metropolis.typ`，而不会影响其他项目。

## 自定义演讲者备注面板

主题不只决定幻灯片长什么样，也决定[演讲者备注](../tutorials/speaker-notes.md)面板长什么样 —— 第二屏幕和 only-notes 视图都由 `config-common(notes-fn: ..)` 指定的函数绘制。自 touying 0.8.0 起，所有内置主题都写了自己的 `notes` 函数并注册了它，因此备注面板与主题风格保持一致。

自己写一个时请建立在 `touying-notes` 之上，它负责版式，把样式留给你：

- `header`: 面板顶部的横条，高度会自适应内容；传 `none` 可以完全去掉它。
- `header-fill`: 横条的填充，可以是颜色，也可以是 `rect` 或 `image`。
- `fill`: 面板其余部分的填充。
- `note-setting`: 作用在备注正文（面板的主要内容）上的 setting 函数。
- `preview-setting`: 作用在 `show-only-notes` 模式下那张缩略幻灯片上的 setting 函数。

备注面板不使用 `config-page(..)`：背景请直接传给 `fill` 和 `header-fill`。

更完整的走查见[创建自己的主题 · 自定义 Notes](../tutorials/build-your-own-theme.md#自定义-notes)。

```example
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *

#let my-notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(1em, text(
    fill: self.colors.neutral-lightest,
    utils.display-current-heading(depth: self.slide-level),
  )),
  header-fill: self.colors.primary,
  fill: self.colors.neutral-lightest,
  note-setting: note => pad(1.5em, text(size: .8em, note)),
  ..args,
)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-common(notes-fn: my-notes, show-notes-on-second-screen: right),
  config-info(title: [My Presentation]),
)

== Slide

Content.

#speaker-note[Remember to slow down here.]
```

## 让特殊 slide 的标题可被发现

页眉和备注面板的标题都是通过 `utils.display-current-heading` 从当前标题读出来的。而标题页、大纲页、结束页这类特殊 slide 往往没有真正的 heading，于是它们的标题就"消失"了。

内置主题的做法是在这类 slide 上放一个隐藏的 heading：

```typst
place(hide(heading(
  level: self.slide-level,
  title,
  bookmarked: false,
  outlined: false,
  numbering: none,
)))
```

`hide` 让它不可见，`place` 让它不占版面空间，`outlined: false` 与 `bookmarked: false` 让它不进入大纲和 PDF 书签 —— 但 `utils.display-current-heading` 仍然能找到它。aqua、dewdrop、metropolis、stargazer 的 `outline-slide`，以及 stargazer 的 `ending-slide`，都用了这个模式。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#let thanks-slide(config: (:), title: [Thanks!]) = touying-slide-wrapper(self => {
  let body = {
    place(hide(heading(
      level: self.slide-level,
      title,
      bookmarked: false,
      outlined: false,
      numbering: none,
    )))
    align(center + horizon, text(2em, weight: "bold", title))
  }
  touying-slide(self: self, config: config, body)
})

#show: simple-theme.with(aspect-ratio: "16-9")

== A Slide

Content.

#thanks-slide()
```

## 支持 Article 模式

Article 模式让同一份源文件既能输出幻灯片，也能输出连续排版的文章。用 `config-common(export-mode: "article")` 开启，用 `article-theme` 指定排版文章时使用的主题 —— 默认是 `auto`，即 touying 内置的 `themes.article`。

```typst
#show: simple-theme.with(
  config-common(
    export-mode: "article",
    article-theme: themes.article.article-theme.with(numbering: "1.1"),
  ),
)
```

`themes.article` 是一个不依赖幻灯片框架的普通 A4 文章主题，它既可以这样配对使用，也可以单独用来排论文和报告；你当然也可以换成任何其他文章主题。

幻灯片主题和文章主题之间通过 `config-article(available-fields: ..)` 传递字段，它是一个从配置路径到文章主题参数名的映射。此外还有两个写作用的标记：

- `#article-text[..]`：写在一页幻灯片之后，在文章输出中替换掉这页的内容，方便你为要点写一段散文。
- `#article-only[..]`：只在文章输出中出现的内容，不会替换任何幻灯片，适合放附录、方法细节等。

```example
#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(
    export-mode: "article",
    article-theme: themes.article.article-theme.with(numbering: "1.1"),
  ),
  config-article(
    available-fields: (title: "info.title", author: "info.author"),
  ),
  config-info(title: [My Presentation], author: [Author Name]),
)

= Section

== Slide

- a bullet for the audience

#article-text[
  A prose paragraph that replaces the slide's bullet points in the article.
]

#article-only[
  == Appendix

  Only in the article.
]
```

## 需要访问 `self` 的辅助函数

主题里的辅助组件（例如 stargazer 的 `tblock`）常常需要读取 `self.colors`。这时请优先使用 `touying-fn-wrapper-raw`：它像 `#alert` 一样就地展开，不会打断 `#pause` / `#uncover` 等动画结构，因此包出来的组件可以正常参与动画。

回调的第一个参数必须写成 `(self: none) => ..`：

```typst
#let _tblock(self: none, title: none, it) = { /* .. */ }

#let tblock(title: none, it) = touying-fn-wrapper-raw(
  _tblock.with(title: title, it),
)
```
