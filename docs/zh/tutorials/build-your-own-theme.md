---
sidebar_position: 7
---

# 构建自己的主题

Touying 的架构使创建可复用的可配置主题变得简单。本教程从头开始构建一个完整的"Bamboo"主题，并解释每个步骤。你可以将其作为自己主题的模板。

## 主题架构

Touying 主题是一个普通的 Typst 文件，它：

1. 导入 Touying 的公共 API。
2. 定义幻灯片函数（`slide`、`title-slide`、`focus-slide` 等）。
3. 公开一个 `xxx-theme` 函数，用户通过 `#show: xxx-theme.with(…)` 调用。

`xxx-theme` 函数内部调用 `touying-slides.with(…)` 来注册所有配置。

## 修改现有主题

获得自定义外观最快的方式是复制现有主题并进行调整：

1. 从[主题目录](https://github.com/touying-typ/touying/tree/main/themes)复制相关文件——例如 `themes/university.typ`——到项目中命名为 `university.typ`。
2. 将文件顶部的导入从 `#import "../src/exports.typ": *` 改为 `#import "@preview/touying:0.6.2": *`。
3. 导入你的本地副本：

```typst
#import "@preview/touying:0.6.2": *
#import "university.typ": *

#show: university-theme.with(…)
```

## 构建 Bamboo 主题

### 第一步 — `slide` 函数

每个主题都需要一个默认的 `slide` 函数。它包装 `touying-slide-wrapper`，以便 Touying 自动注入 `self`：

```typst
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = align(top + left,
    pad(x: 1em, y: 0.5em,
      text(fill: self.colors.neutral-darkest, weight: "bold",
        utils.display-current-heading(depth: self.slide-level),
      )
    )
  )
  let footer(self) = align(bottom,
    pad(x: 1em, y: 0.5em,
      grid(
        columns: (1fr, auto),
        utils.call-or-display(self, self.store.footer),
        context utils.slide-counter.display() + " / " + utils.last-slide-number,
      )
    )
  )
  let self = utils.merge-dicts(
    self,
    config-page(header: header, footer: footer),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})
```

### 第二步 — 特殊幻灯片函数

```typst
/// 标题幻灯片。冻结幻灯片计数器使其不计入编号。
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary),
    config,
  )
  let info = self.info + args.named()
  touying-slide(self: self,
    align(center + horizon,
      text(fill: white, {
        text(size: 1.5em, weight: "bold", info.title)
        if info.subtitle != none { linebreak(); text(0.9em, info.subtitle) }
        v(1em)
        text(0.8em, info.author)
      })
    )
  )
})

/// 对比背景的焦点幻灯片。
#let focus-slide(config: (:), background: auto, foreground: white, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: if background == auto { self.colors.primary } else { background }),
    config,
  )
  set text(fill: foreground, size: 1.5em)
  touying-slide(self: self, align(center + horizon, body))
})
```

### 第三步 — 主题注册函数

`bamboo-theme` 函数是用户调用的。它使用 `touying-slides.with(…)` 合并所有配置：

```typst
/// Bamboo 主题。
///
/// - aspect-ratio (string): `"16-9"` 或 `"4-3"`，默认 `"16-9"`。
/// - footer (content, function): 页脚内容。
/// - primary (color): 主色调。
#let bamboo-theme(
  aspect-ratio: "16-9",
  footer: none,
  primary: rgb("#5c7a4e"),
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (top: 3em, bottom: 2em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, fill: self.colors.neutral-darkest)
        show heading: set text(fill: self.colors.primary)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: primary,
      neutral-lightest: rgb("#fafafa"),
      neutral-darkest: rgb("#1a1a1a"),
    ),
    config-store(footer: footer),
    ..args,
  )
  body
}
```

## 关键概念

### `config-store`

主题通常需要存储用户提供的值（如 `footer`）供后续在幻灯片函数中使用。`config-store(key: value, …)` 保存任意值；通过 `self.store.key` 访问：

```typst
config-store(footer: footer)
// 之后在幻灯片函数内：
utils.call-or-display(self, self.store.footer)
```

### `utils.call-or-display`

接受静态值或函数 `self => content`。这让用户可以传入字符串/内容或动态函数：

```typst
// 静态
footer: [我的会议]

// 动态（访问当前幻灯片信息）
footer: self => self.info.institution
```

### `utils.display-current-heading`

返回当前标题内容，适用于动态页眉：

```typst
utils.display-current-heading(level: 1)         // 章节标题
utils.display-current-heading(depth: self.slide-level) // 最近的标题
```

### 幻灯片计数器

```typst
context utils.slide-counter.display()  // 当前幻灯片编号
utils.last-slide-number                // 幻灯片总数
```

### 进度条

```typst
components.progress-bar(
  height: 3pt,
  self.colors.primary,
  self.colors.primary.lighten(60%),
)
```

## 添加文档注释

Touying 主题使用 `///` 文档字符串，以便 Tinymist 显示内联帮助。为每个导出函数遵循以下模式：

```typst
/// 默认幻灯片函数。
///
/// 示例：
/// ```typst
/// #slide[内容]
/// ```
///
/// - config (dictionary): 单张幻灯片配置。
/// - repeat (int, auto): 子幻灯片数量，通常用 `auto`。
/// - composer (function, array): 列布局。
/// - bodies (array): 幻灯片内容块。
#let slide(config: (:), repeat: auto, composer: auto, ..bodies) = …
```

## 向 Touying 贡献主题

如果你希望将主题包含在 Touying 中：

1. 将其放在 `themes/your-theme.typ`。
2. 在 `themes/themes.typ` 中添加 `#import "your-theme.typ"`。
3. 将顶部导入改为 `#import "../src/exports.typ": *`。
4. 在 `tests/themes/your-theme/` 下添加测试。
5. 在 `docs/en/themes/your-theme.md`（及中文翻译）下添加文档。
6. 在 GitHub 上提交 Pull Request。
