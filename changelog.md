# Changelog

## v0.5.0

这一个重大的破坏性版本更新。Touying 去除了许多错误决策下的历史包袱，重新设计了许多功能。这个版本的目标是让 Touying 更加易用，更加灵活，更加强大。

**重大的变化包括：**

- 避免闭包和 OOP 语法，这样做的优势在于让 Touying 的配置更加简单，且可以使用 document comments 为 slide 函数提供更多的自动补全信息。
  - 原有的 `#let slide(self: none, ..args) = { .. }` 现在变为了 `#let slide(..args) = touying-slide-wrapper(self => { .. })`，其中 `self` 会被自动注入。
  - 我们可以使用 `config-xxx` 语法来配置 Touying，例如 `#show: university-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`。
- `touying-slide` 函数不再包含 `section`、`subsection` 和 `title` 参数，这些参数会被作为 `self.headings` 以不可见的 1，2 或 3 级等 heading（可以通过 slide-level 配置）自动插入到 slide 页面中。
  - 我们可以利用 Typst 提供的强大的 heading 来支持 numbering、outline 和 bookmark 等功能。
  - 在 `#slide[= XXX]` 这样 slide 函数内部的 heading 会通过 offset 参数将其变为 `slide-level + 1` 级的 heading。
  - 我们可以利用 heading 的 label 来控制很多东西，例如支持 `touying:hidden` 等特殊 label，或者实现 short heading，亦或者实现 `#touying-recall()` 再现某个 slide。
- Touying 现在支持在任意位置正常地使用 set 和 show 规则，而不再需要在特定位置使用。

一个简单的使用例子如下，更多的示例可以在 `examples` 目录下找到：

```typst
#import "@preview/touying:0.5.0": *
#import themes.university: *

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

#set heading(numbering: "1.1")

#title-slide()

= The Section

== Slide Title

#lorem(40)
```

**主题迁移指南：**

可以到 `themes` 目录下查看具体主题的变化。大体来说，如果你想迁移已有的主题，你应该：

1. 将 `register` 函数重命名为 `xxx-theme`，并去除 `self` 参数。
2. 添加一个 `show: touying-slides.with(..)` 的配置。
  1. 将原有的 `self.methods.colors` 更改为 `config-colors(primary: rgb("#xxxxxx"))`。
  2. 将原有的 `self.page-args` 更改为 `config-page()`。
  3. 将原有的 `self.methods.slide = slide` 更改为 `config-methods(slide: slide)`
  4. 将原有的 `self.methods.new-section-slide = new-section-slide` 更改为 `config-methods(new-section-slide: new-section-slide)`
  5. 将原有的 `self.xxx-footer` 这样的主题私有变量更改为 `config-store(footer: [..])`，后续你可以通过 `self.store.footer` 来获取。
  6. 将原有的 `header` 和 `footer` 移到 `slide` 函数中配置，而不是在 `xxx-theme` 函数中配置。
  7. 你可以在 `xxx-theme` 中直接使用 set 或 show 规则，或者也可以通过 `config-methods(init: (self: none, body) => { .. })` 来配置，这样你能充分利用 `self` 参数。
3. 对于 `states.current-section-with-numbering`，你可以使用 `utils.display-current-heading(level: 1)` 来代替。
  1. 如果你仅要获取上一个标题，无所谓是 section 还是 subsection，你可以使用 `utils.display-previous-heading()` 来代替。
4. `alert` 函数可以通过 `config-methods(alert: utils.alert-with-primary-color)` 来代替。
5. 我们不再需要 `touying-outline()` 函数，你可以直接使用 `components.adaptive-columns(outline())` 来代替。或者考虑使用 `components.progressive-outline()` 或 `components.custom-progressive-outline()`。
6. 将 `context states.slide-counter.display() + " / " + states.last-slide-number` 替换为 `context utils.slide-counter.display() + " / " + utils.last-slide-number`。即我们不再使用 `states`，而是使用 `utils`。
7. 删除 `slides` 函数，我们不再需要这个函数。因为我们不应该隐式注入 `title-slide()`，而是应该显式地使用 `#title-slide()`。如果你实在需要，你可以考虑在 `xxx-theme` 函数中加入。
8. 将原来的 `#let slide(self: none, ..args) = { .. }` 变为了 `#let slide(..args) = touying-slide-wrapper(self => { .. })`。其中 `self` 会被自动注入。
  1. 将具体的参数配置更改为 `self = utils.merge-dicts(self, config-page(fill: self.colors.neutral-lightest))` 方式。
  2. 去除 `self = utils.empty-page(self)`，你可以使用 `config-common(freeze-slide-counter: true)` 和 `config-page(margin: 0em)` 来代替。
  3. 将 `(self.methods.touying-slide)()` 更改为 `touying-slide()`。
9. 你可以通过配置 `config-common(subslide-preamble: self => text(1.2em, weight: "bold", utils.display-current-heading(depth: self.slide-level)))` 来实现给 slide 插入可视的 heading。
10. 最后，别忘了给你的函数们加上 document comments，这样你的用户就能获得更好的自动补全提示，尤其是在使用 Tinymist 插件时。


**其他变化：**

- feat: 实现了 fake frozen states support，你现在可以正常地使用 `numbering` 和 `#pause`。这个行为可以通过 `config-common()` 里的 `enable-frozen-states-and-counters`，`frozen-states` 和 `frozen-counters` 控制。
- feat: 实现了 `label-only-on-last-subslide` 功能，可以让 `@equation` 和 `@figure` 在有 `#pause` 动画的情况下正在工作，避免非 unique label 警告。
- feat: 添加了 `touying-recall(<label>)` 函数，用于重现某个 slide。
- feat: 实现了 `nontight-list-enum-and-terms` 功能，默认开启。强制让 list, enum 和 terms 的 `tight` 参数为 `false`。你可以通过 `#set list(spacing: 1em)` 来控制间距大小。
- feat: 将 `list` 替换为 `terms` 实现，以实现 `align-list-marker-with-baseline`，默认关闭。 
- feat: 实现了 `scale-list-items` 功能，`scale-list-items: 0.8` will scale the list items by 0.8.
- feat: 支持直接在数学公式里使用 `#pause` 和 `#meanwhile`，如 `$x + pause y$`。
- feat: 为大部分布局函数实现了 `#pause` 和 `#meanwhile` 支持，如 grid 和 table 函数。
- feat: 添加了 `#show: appendix` 支持，其本质是 `#show: touying-set-config.with((appendix: true))`。
- feat: 加入了 `<touying:hidden>`, `<touying:unnumbered>`, `<touying:unoutlined>`, `<touying:unbookmarked>` 特殊 label，用于更简单地控制 heading 的行为。
- feat: 加入简易的 `utils.short-heading` 支持，可以用 label 来实现 short-heading，例如将 `<sec:my-section>` 显示为 `My Section`。
- feat: 加入了 `#components.adaptive-columns()`，实现尽量占据一个页面的 adaptive columns。通常与 `outline()` 函数一起使用。
- feat: 加入了 `#show: magic.bibliography-as-footnote.with(bibliography("ref.bib"))`，可以让 bibliography 在 footnote 中显示。
- feat: 加入了 `custom-progressive-outline`, `mini-slides` 等 components。
- feat: 删除 `touying-outline()`，你可以直接使用 `outline()`。
- fix: 更换了未来可能会不兼容的代码，例如 `type(s) == "string"` 和 `locate(loc => { .. })` 等。
- fix: 修复了一些 bugs。


## v0.4.2

- theme(metropolis): decoupled text color with `neutral-dark` (Breaking change)
- feat: add mark-style uncover, only and alternatives
- feat: add warning for styled block for slides
- feat: add warning for touying-temporary-mark
- feat: add markup-text for speaker-note
- fix: fix bug of slides


## v0.4.1

### Features

- feat: support builtin outline and bookmark
- feat: support speaker note for dual-screen
- feat: add touying-mitex function

### Fixes

- fix: add outline-slide for dewdrop theme
- fix: fix regression of default value "auto" for repeat

### Miscellaneous Improvements

- feat: add list support for `touying-outline` function
- feat: add auto-reset-footnote
- feat: add `freeze-in-empty-page` for better page counter
- feat: add `..args` for register method to capture unused arguments


## v0.4.0

### Features

- **feat:** support `#footnote[]` for all themes.
- **feat:** access subslide and repeat in footer and header by `self => self.subslide`.
- **feat:** support numbered theorem environments by [ctheorems](https://typst.app/universe/package/ctheorems).
- **feat:** support numbering for sections and subsections.

### Fixes

- **fix:** make nested includes work correctly. 
- **fix:** disable multi-page slides from creating the same section multiple times.

## Breaking changes

- **refactor:** remove `self.padding` and add `self.full-header` `self.full-footer` config.


## v0.3.3

- **template:** move template to `touying-aqua` package, make Touying searchable in [Typst Universe Packages](https://typst.app/universe/search?kind=packages)
- **themes:** fix bugs in university and dewdrop theme
- **feat:** make set-show rule work without `setting` parameter
- **feat:** make `composer` parameter more simpler
- **feat:** add `empty-slide` function

## v0.3.2

- **fix critical bug:** fix `is-sequence` function, make `grid` and `table` work correctly in touying
- **theme:** add aqua theme, thanks for pride7
- **theme:** make university theme more configurable
- **refactor:** don't export variable `s` by default anymore, it will be extracted by `register` function (**Breaking Change**)
- **meta:** add `categories` and `template` config to `typst.toml` for Typst 0.11


## v0.3.1

- fix some typos
- fix slide-level bug
- fix bug of pdfpc label


## v0.3.0

### Features

- better show-slides mode.
- support align and pad.

### Documentation

- Add more detailed documentation.

### Refactor

- simplify theme.

### Fix

- fix many bugs.

## v0.2.1

### Features

- **Touying-reducer**: support cetz and fletcher animation
- **university theme**: add university theme

### Fix

- fix footer progress in metropolis theme
- fix some bugs in simple and dewdrop themes
- fix bug that outline does not display more than 4 sections


## v0.2.0

- **Object-oriented programming:** Singleton `s`, binding methods `utils.methods(s)` and `(self: obj, ..) => {..}` methods.
- **Page arguments management:** Instead of using `#set page(..)`, you should use `self.page-args` to retrieve or set page parameters, thereby avoiding unnecessary creation of new pages.
- **`#pause` for sequence content:** You can use #pause at the outermost level of a slide, including inline and list.
- **`#pause` for layout functions:** You can use the `composer` parameter to add yourself layout function like `utils.side-by-side`, and simply use multiple pos parameters like `#slide[..][..]`.
- **`#meanwhile` for synchronous display:** Provide a `#meanwhile` for resetting subslides counter.
- **`#pause` and `#meanwhile` for math equation:** Provide a `#touying-equation("x + y pause + z")` for math equation animations.
- **Slides:** Create simple slides using standard headings.
- **Callback-style `uncover`, `only` and `alternatives`:** Based on the concise syntax provided by Polylux, allow precise control of the timing for displaying content.
  - You should manually control the number of subslides using the `repeat` parameter.
- **Transparent cover:** Enable transparent cover using oop syntax like `#let s = (s.methods.enable-transparent-cover)(self: s)`.
- **Handout mode:** enable handout mode by `#let s = (s.methods.enable-handout-mode)(self: s)`.
- **Fit-to-width and fit-to-height:** Fit-to-width for title in header and fit-to-height for image.
  - `utils.fit-to-width(grow: true, shrink: true, width, body)`
  - `utils.fit-to-height(width: none, prescale-width: none, grow: true, shrink: true, height, body)`
- **Slides counter:** `states.slide-counter.display() + " / " + states.last-slide-number` and `states.touying-progress(ratio => ..)`.
- **Appendix:** Freeze the `last-slide-number` to prevent the slide number from increasing further.
- **Sections:** Touying's built-in section support can be used to display the current section title and show progress.
  - `section` and `subsection` parameter in `#slide` to register a new section or subsection.
  - `states.current-section-title` to get the current section.
  - `states.touying-outline` or `s.methods.touying-outline` to display a outline of sections.
  - `states.touying-final-sections(sections => ..)` for custom outline display.
  - `states.touying-progress-with-sections((current-sections: .., final-sections: .., current-slide-number: .., last-slide-number: ..) => ..)` for powerful progress display.
- **Navigation bar**: Navigation bar like [here](https://github.com/zbowang/BeamerTheme) by `states.touying-progress-with-sections(..)`, in `dewdrop` theme.
- **Pdfpc:** pdfpc support and export `.pdfpc` file without external tool by `typst query` command simply.
