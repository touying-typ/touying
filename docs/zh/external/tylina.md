---
sidebar_position: 1
---

# Tylina

[Tylina](https://tylina.github.io/) 是 Touying 最推荐的 AI 原生、文档优先、所见即所得编辑与演示工具。它同时提供网页版和桌面版，并始终以普通 `.typ` 文件作为规范源码。

> [在 Tylina Web 中打开 Touying 的 simple 示例](https://tylina.github.io/app/?repo=https%3A%2F%2Fgithub.com%2Ftouying-typ%2Ftouying&provider=github&ref=main&load=dependencies&main=examples%2Fsimple.typ&file=examples%2Fsimple.typ&view=slides)

这个链接会导入 GitHub 仓库，在编译器需要时按需获取依赖，选中 `examples/simple.typ`，并直接进入幻灯片视图。网页版通过 WebAssembly 在本地编译，工作副本保存在浏览器中。

## 为什么推荐配合 Touying 使用？

- 直接在排版页面上编辑，也可以用源码透镜或分栏视图精确控制源码。
- 在同一个工作区管理缩略图和演讲者备注、调整页面顺序并放映。
- 打开完整的 GitHub/GitLab 仓库，或者只按需加载当前文件使用的依赖。
- 使用理解文档的 AI：在网页版连接自己的模型，或在桌面版连接 ACP Agent，再通过共享工具编辑、编译和检查工作区。
- 浏览模板，并直接导出 PDF 或 PowerPoint。

## 可编辑 PowerPoint 导出

打开 Tylina 的“导出”工具，选择 **PPTX**，再按用途选择模式。两种模式都会保留演讲者备注。

| 模式 | 适合场景 | 取舍 |
| --- | --- | --- |
| **可编辑（实验性）** | 继续在 PowerPoint 中修改。文字、简单行内公式、受支持的图片和形状，以及受支持的外部或页内链接会转换为原生 PowerPoint 对象。 | 复杂内容会按原顺序保留在矢量回退层中。字体替换和 PowerPoint 的文字度量可能改变换行，因此不保证像素级一致，也不是所有元素都可编辑。 |
| **视觉保真** | 尽量保持 Typst 的原始版式并直接放映。 | 每页会作为一张渲染图写入，文字和单个元素不可编辑。 |

对于横向演示文稿，Tylina Web 还可能直接显示“导出为 PPTX”操作；需要选择模式或查看转换摘要时，请使用完整的“导出”工具。

## 复用网页链接

示例 URL 用 `repo` 和 `ref` 指定仓库版本，`main` 指定编译入口，`file` 指定初始打开的文件，`view=slides` 直接进入幻灯片视图。使用 `load=dependencies` 可以快速按需导入；如果需要完整仓库和 Git 工作流，则改用 `load=all`。

[Gistd](./gistd.md) 仍适合轻量的只读分享链接；如果需要完整的可编辑工作区、放映工具或 PowerPoint 导出，应优先选择 Tylina。
