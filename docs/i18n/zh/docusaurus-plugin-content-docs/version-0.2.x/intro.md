---
sidebar_position: 1
---

# Touying 介绍

[Touying](https://github.com/touying-typ/touying) 是为 Typst 开发的幻灯片/演示文稿包，在 [Polylux](https://github.com/andreasKroepelin/polylux) 的基础上开发而来。Touying 也类似于 LaTeX 的 Beamer，但是得益于 Typst，你可以拥有更快的渲染速度与更简洁的语法。后面，我们会使用 slides 指代幻灯片，slide 指代单张幻灯片，subslide 指代子幻灯片。

## 为什么使用 Touying

- 相较于 PowerPoint，Touying 并非「所示即所得的」，你可以使用一种「内容与样式分离」的方式编写你的 slides，尤其是 Typst 作为一个新兴的排版语言，提供了简洁但强大的语法，对于代码块、数学公式和定理等内容有着更好的支持。另一个优势是，在有着模板的情况下，用 Touying 编写 slides 要比 PowerPoint 快得多。因此 Touying 相较于 PowerPoint，更适合有着「科研写作」需求的用户使用。
- 相较于 Markdown Slides，Touying 所依托的 Typst 有着更强大的排版控制能力，例如页眉、页脚、布局和便捷的自定义函数，而这是 Markdown 很难具备、或者说很难做好的能力。并且 Touying 提供了 `#pause` 和 `#meanwhile` 标记，提供了更为便捷的动态 slides 能力。
- 相较于 Beamer，Touying 有着更快的编译速度、更简洁的语法，以及更简单的自定义主题的能力。相较于 Beamer 动辄几秒几十秒的编译时间，Touying 的编译速度基本上能够维持在几毫秒几十毫秒。并且 Touying 的语法相较于 Beamer 更为简洁，也更容易更改模板主题，以及创建你自己的模板。在功能上，Touying 支持了 Beamer 大部分的能力，并且还提供了一些 Beamer 所没有的便利功能。
- 相较于 Polylux，Touying 提供了一种 oop 风格的语法，能够通过全局单例模拟提供「全局变量」的能力，进而可以方便地编写主题。并且 Touying 并不依赖 `counter` 和 `locate` 来实现 `#pause`，因此能有更好的性能。Touying 自身定位是一个社区驱动的项目（我们欢迎更多的人加入），并且不会过分强调维持 API 的一致性，而是选择维护多个版本的文档，因而能够提供更多新颖但强大的功能。

## 名称来源

Touying 取自中文里的「投影」，在英文中意为 project。相较而言，LaTeX 中的 beamer 就是德文的投影仪的意思。

## 关于文档

这个文档通过 [Docusaurus](https://docusaurus.io/) 驱动开发，我们将会为 Touying 维持英文和中文版本的文档，并且每个大版本维护一份文档，以便你随时可以查阅旧版本的 Touying 文档，并且可以更容易地迁移到新版本。

Docusaurus 创建新版本：

```sh
npm run docusaurus docs:version 0.y.x
```

## 贡献

Touying 是免费、开源且社区驱动的。如果你感兴趣，你可以随时访问 [GitHub](https://github.com/touying-typ/touying) 并提出 issue 或 PR，我们也同样欢迎你加入 [touying-typ](https://github.com/touying-typ) 组织。

## License

Touying is released under the [MIT license](https://github.com/touying-typ/touying/blob/main/LICENSE).