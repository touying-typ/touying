---
sidebar_position: 6
---

# 讲义模式

讲义模式将每张逻辑幻灯片的所有动画子幻灯片合并为单页，便于生成可打印或可分发的演示文稿版本。

## 启用讲义模式

```typst
config-common(handout: true)
```

将其放在主题设置中：

```example
#import "@preview/touying:0.8.0": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-common(handout: true),
)

= Title

== Animated Slide

First item.

#pause

Second item (won't generate a separate page in handout mode).

#pause

Third item.
```

默认情况下，讲义模式只保留每张幻灯片的**最后一个**子幻灯片。

也可以改用 `config-common(export-mode: "handout")` 来设置讲义模式，这样还可以在命令行上通过 `--input export-mode=handout` 直接指定，完全不需要修改源文件。参见[输出模式](../output-modes)。

## 选择保留哪个子幻灯片

你可以使用 `handout-subslides` 指定讲义输出中保留特定的子幻灯片：

```typst
// 只保留第一个子幻灯片（适用于"之前"快照）
config-common(handout: true, handout-subslides: 1)

// 保留第一个和最后一个子幻灯片
config-common(handout: true, handout-subslides: (1, -1))

// 用字符串表示范围（与 `only`/`uncover` 语法相同）
config-common(handout: true, handout-subslides: "1-2")

// 保留每个 waypoint 的最后一个子幻灯片
config-common(handout: true, handout-subslides: "waypoints")
```

`"waypoints"` 为每个 [waypoint](./waypoints) 保留一页，显示该 waypoint 的最终状态，这样讲义可以跟随动画的各个阶段，而不包含中间步骤。它也可以作为数组的一个元素，例如 `(1, "waypoints")`。没有 waypoint 的幻灯片保留其最后一个子幻灯片。

也可以单独指定 waypoint。单独的标签（如 `<intro>`）表示该 waypoint 的*最后一个*子幻灯片，即其内容完全显示时的状态，因此 `handout-subslides: (<intro>, <result>)` 为每个 waypoint 保留一页。如需第一个子幻灯片，请使用 `get-first(<intro>)`。范围标记会保留它们所覆盖的所有子幻灯片：`from-wp(<intro>)` 保留从该 waypoint 起到幻灯片结束的部分，`until-wp(<intro>)` 保留它之前的所有部分，`not-wp(not-wp(<intro>))` 恰好保留这一个 waypoint 的所有子幻灯片。

## 仅在讲义中显示的幻灯片

使用 `<touying:handout>` 标签创建**仅在讲义模式下**显示、在正常演示时隐藏的幻灯片：

```typst
== Extra Notes for Handout <touying:handout>

This slide is included when `handout: true` but invisible otherwise.
```

## 仅在某一模式下显示的内容

`#handout-only[..]`、`#presentation-only[..]`、`#slides-only[..]` 和 `#article-only[..]` 可以让一段内容只出现在适合它的模式里。详见[输出模式](../output-modes)。

## 工作流建议

一种常见的工作流是：演示时保持 `handout: false`（默认值），导出分发用的 PDF 时切换为 `handout: true`：

```typst
// 演示时
#show: my-theme.with(config-common(handout: false))

// 构建讲义 PDF 时
#show: my-theme.with(config-common(handout: true))
```

如果不想改动源文件，也可以用上面提到的 `--input export-mode=handout` 直接导出讲义。
