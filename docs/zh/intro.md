---
sidebar_position: 1
---

# Touying 介绍

[Touying](https://github.com/touying-typ/touying) 是为 [Typst](https://typst.app/) 开发的强大幻灯片/演示文稿包。Touying 类似于 LaTeX 的 Beamer，但得益于 Typst 的现代语法和极速编译，体验更为出色。在本文档中，我们使用 **slides** 指代整套幻灯片，**slide** 指代单张幻灯片，**subslide** 指代动画步骤所产生的子页面。

## 为什么使用 Touying？

- **相较于 PowerPoint** — Touying 遵循「内容与样式分离」的理念。你只需编写带有轻量标记的纯文本，主题会自动处理视觉设计。这对于包含代码块、数学公式和定理环境的科研类演示文稿尤为高效。
- **相较于 Markdown Slides** — Typst 提供了精细的排版控制能力（页眉、页脚、自定义布局以及一流的数学支持），这是基于 Markdown 的工具难以实现的。Touying 还提供了 `#pause` 和 `#meanwhile` 标记，让渐进式动画在代码优先的工作流中自然流畅。
- **相较于 Beamer** — Touying 的编译速度以毫秒计，而非秒乃至数十秒。其语法更为简洁，创建或修改主题也更加直接。在功能上，Touying 与 Beamer 高度对标，并额外提供了针对 CeTZ/Fletcher 图表的 `touying-reducer` 等便利功能。
- **相较于 Polylux** — Touying 实现 `#pause` 时不依赖 `counter` 和 `locate`，从而避免了这些原语带来的性能损耗。Touying 还提供了更丰富的主题工具集以及统一的配置 API，让你以最少的改动即可切换主题。

## 名称来源

「Touying」取自中文「投影」（tóuyǐng），意为"投射/放映"——正如 LaTeX 世界里德文单词 *Beamer* 意为投影仪一样。

## 在哪里编写幻灯片

你有两种主要选择：

| 选项 | 说明 |
|------|------|
| **[Typst Web App](https://typst.app/)** | 基于浏览器的编辑器，无需安装；打开 `typst.app`，创建新项目即可开始编写。支持实时预览和协作。 |
| **[Tinymist for VS Code](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)** | 功能完整的 Typst LSP 扩展。提供语法高亮、自动补全、错误诊断以及内置幻灯片预览面板。 |

两种方式均会自动从 Typst 包注册表下载 Touying，无需单独安装。

## Universe

厌倦了[内置主题](https://touying-typ.github.io/themes/)？

[Typst Universe](https://typst.app/universe/search/?q=touying) 上有着 Touying 用户上传的多种多样的主题，多浏览一下，说不定你会喜欢。

## 画廊

Touying 提供了一个[画廊](https://github.com/touying-typ/touying/wiki)，社区成员可在此分享自己的幻灯片。欢迎你贡献自己的作品！

## 贡献

Touying 是免费、开源且社区驱动的项目。欢迎访问 [GitHub](https://github.com/touying-typ/touying) 提交 issue、发起 PR，或加入 [touying-typ](https://github.com/touying-typ) 组织。

## License

Touying is released under the [MIT license](https://github.com/touying-typ/touying/blob/main/LICENSE).