---
sidebar_position: 5
---

# 演讲者备注与讲义模式

## 演讲者备注

演讲者备注让你可以为幻灯片附加私人提示或讲话要点，而不在屏幕上显示给观众。

### 添加备注

在幻灯片内任意位置使用 `#speaker-note[…]`：

```typst
== 我的幻灯片

这里是可见内容。

#speaker-note[
  + 提醒观众上一张幻灯片的内容。
  + 关键点是 X。
  + 询问是否有问题。
]
```

备注默认不在主 PDF 输出中渲染。它们会导出到 `.pdfpc` 文件，供 [pdfpc](https://pdfpc.github.io/) 使用（参见 [pdfpc 指南](../external/pdfpc)）。

### 在第二块屏幕上显示备注

启用双屏模式，演讲者备注显示在第二块显示器上，同时显示下一张幻灯片的预览：

```typst
#show: my-theme.with(
  config-common(show-notes-on-second-screen: right),
)
```

支持的值：`right`（右侧）、`bottom`（底部）或 `none`（默认，不显示）。

### 全屏备注模式

生成仅显示备注的视图，带有幻灯片缩略图：

```typst
#show: my-theme.with(
  config-common(show-only-notes: true),
)
```

此模式适用于生成单独的演讲者 PDF。

## 讲义模式

讲义模式通过只渲染每个动画幻灯片的一个子幻灯片来生成单页文档——适合分发给观众。

### 启用讲义模式

```typst
#show: my-theme.with(
  config-common(handout: true),
)
```

默认渲染每张幻灯片的**最后一个**子幻灯片（显示完全展示状态）。

### 选择讲义中显示哪个子幻灯片

```typst
// 始终显示第一个子幻灯片
config-common(handout: true, handout-subslides: 1)

// 显示第 2 个子幻灯片
config-common(handout: true, handout-subslides: 2)

// 显示第 1 和第 3 个子幻灯片（各成单独一页）
config-common(handout: true, handout-subslides: (1, 3))

// 使用与 #only / #uncover 相同的范围语法
config-common(handout: true, handout-subslides: "1,3")
```

### 仅讲义幻灯片

使用 `<touying:handout>` 标签标记仅在讲义模式中出现的幻灯片：

```typst
== 额外细节 <touying:handout>

此幻灯片在演示中不可见，但出现在讲义中。
```

或使用 `#handout-only[…]` 函数：

```typst
#handout-only[
  此内容仅出现在讲义中。
]
```

## 组合备注和讲义模式

常见工作流是从单一源文件生成两个 PDF：

1. **演示 PDF** — 正常模式，无配置覆盖。
2. **讲义 PDF** — 在单独的入口文件中添加 `config-common(handout: true)`。

```typst
// handout.typ
#import "main.typ": *

// 仅覆盖讲义设置
#show: my-theme.with(config-common(handout: true))
#include "content.typ"
```
